-- ============================================================
-- UNICORN – PARAMETRISIERTER REPORTING STACK
-- ============================================================

/*
Datenquellen: customers, orders, order_details, product
Verantwortlich: Suryandi
SQL-Dialekt: PostgreSQL

Stakeholder-Frage:
Wo sollten wir den Fokus für weiteres Wachstum setzen?

Business Scope:
Bestellungen von 2015 bis 2018
Versandland: United States
Region: über parameters.region_filter wählbar (Standard: all)
Versandarten: First Class, Same Day,
Second Class und Standard Class

Aufbau:
0. parameters     – Regionsauswahl
1. base           – Canonical Join + Cleaning
2. Aggregationen  – Umsatz- und Gewinnsummen
3. Vorjahreswerte – Vergleich mit LAG()
4. reporting      – Gemeinsame Aggregatstruktur
5. Final SELECT   – KPI-Berechnung, Sortierung und Rundung

Ergebnisarten:
region_year   – Region und Jahr: Umsatzwachstum
category_total – Kategorie: Umsatz und Gewinnmarge, 2015–2018
segment_year  – Kundensegment und Jahr: Umsatzwachstum
segment_total – Kundensegment: Gesamtumsatz, 2015–2018

Wichtig:
Die Ergebnisarten betrachten dieselbe Datenbasis aus
unterschiedlichen Perspektiven. Ihre Umsätze dürfen
nicht über alle Ergebnisarten hinweg addiert werden.

NULL bedeutet:
Kennzahl nicht vorgesehen oder Vergleich nicht berechenbar.
Bei Gesamtzeilen ist order_year NULL, da sie 2015–2018 umfassen.
*/

-- ============================================================
-- FILTERSTEUERUNG
-- Anschließend folgen Base, Aggregationen und KPI-Ausgabe.
-- ============================================================

-- ============================================================
-- PARAMETER – Eine Zeile mit dem gewünschten Regionsfilter.
-- Zulässig: all, Central, East, South, West (Schreibweise beachten).
-- all deaktiviert nur den Regionsfilter; der Business Scope bleibt gültig.
-- Beispiel: 'West' statt 'all' für die Auswertung der Region West.
-- ============================================================
WITH parameters AS (
    SELECT 'all'::text AS region_filter
),

-- ============================================================
-- BASE – Join und Cleaning; eine Zeile je Bestellposition.
-- ============================================================
base AS (

    SELECT
        od.order_details_id,
        od.order_id,
        od.product_id,
        od.quantity,
        od.order_discount,
        od.order_sales,
        od.order_profits,
        od.order_profit_ratio,

        o.customer_id,
        o.order_date,
        o.shipping_city,
        o.shipping_state,
        o.shipping_region,
        o.shipping_country,
        o.shipping_postal_code,

        -- BIGINT in Text umwandeln, damit UNKNOWN darstellbar ist.
        COALESCE(
            o.shipping_postal_code::text,
            'UNKNOWN'
        ) AS shipping_postal_code_clean,

        o.shipping_date,
        o.shipping_mode,

        c.customer_name,
        c.customer_segment,

        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.product_manufacturer,

        -- Prüft die exakte Übereinstimmung.
        -- Fehlende Herstellerwerte werden nicht gesondert geprüft.
        CASE
            WHEN p.product_manufacturer = p.product_name
                THEN 'CHECK'
            ELSE 'OK'
        END AS manufacturer_quality_flag

    FROM order_details AS od

    JOIN orders AS o
        ON od.order_id = o.order_id

    JOIN customers AS c
        ON o.customer_id = c.customer_id

    JOIN product AS p
        ON od.product_id = p.product_id

    -- Genau eine Parameterzeile: Der CROSS JOIN vervielfacht keine Positionen.
    CROSS JOIN parameters AS prm

    WHERE (prm.region_filter = 'all'
           OR o.shipping_region = prm.region_filter)
      AND o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')),

-- ============================================================
-- LAYER 2 – AGGREGATIONEN
-- ============================================================

-- Grain: Eine Region in einem Kalenderjahr.
-- ------------------------------------------------------------
-- region_yearly_sales: Summiert Umsatz und zählt Positionen je Region und Jahr.
-- ------------------------------------------------------------
region_yearly_sales AS (

    SELECT
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer),

-- Grain: Eine Produktkategorie über 2015–2018.
-- ------------------------------------------------------------
-- category_totals: Summiert Umsatz und Gewinn je Kategorie über 2015–2018.
-- ------------------------------------------------------------
category_totals AS (

    SELECT
        product_category,
        SUM(order_sales)::numeric AS total_sales,
        SUM(order_profits)::numeric AS total_profits,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count,
        COUNT(*) FILTER (
            WHERE order_profits IS NULL
        ) AS missing_profit_count

    FROM base

    GROUP BY
        product_category),

-- Grain: Ein Kundensegment in einem Kalenderjahr.
-- ------------------------------------------------------------
-- segment_yearly_sales: Summiert Umsatz und zählt Positionen je Segment und Jahr.
-- ------------------------------------------------------------
segment_yearly_sales AS (

    SELECT
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer),

-- Grain: Ein Kundensegment über 2015–2018.
-- Additive Kennzahlen werden aus den Jahressummen übernommen.
-- ------------------------------------------------------------
-- segment_totals: Fasst die Jahresaggregate je Segment über 2015–2018 zusammen.
-- ------------------------------------------------------------
segment_totals AS (

    SELECT
        customer_segment,
        SUM(total_sales) AS total_sales,
        SUM(position_count)::bigint AS position_count,
        SUM(missing_sales_count)::bigint AS missing_sales_count

    FROM segment_yearly_sales

    GROUP BY
        customer_segment),

-- ============================================================
-- LAYER 3 – VORJAHRESWERTE
-- ============================================================

-- ------------------------------------------------------------
-- region_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Region und Jahr.
-- ------------------------------------------------------------
region_previous_sales AS (

    SELECT
        shipping_region,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM region_yearly_sales),

-- ------------------------------------------------------------
-- segment_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Segment und Jahr.
-- ------------------------------------------------------------
segment_previous_sales AS (

    SELECT
        customer_segment,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM segment_yearly_sales),

-- ============================================================
-- LAYER 4 – GEMEINSAME ERGEBNISSTRUKTUR
-- UNION ALL erhält die getrennten Auswertungsperspektiven.
-- ============================================================

-- ------------------------------------------------------------
-- reporting: Vereinheitlicht Aggregate; Grain: Ergebnisart, Dimension und ggf. Jahr.
-- ------------------------------------------------------------
reporting AS (

    -- KPI 1: Umsatzwachstum nach Region
    SELECT
        'region_year'::text AS report_type,
        shipping_region AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,


        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM region_previous_sales

    UNION ALL

    -- KPI 2 und 3: Kategorieumsatz und Gewinnmarge
    SELECT
        'category_total'::text AS report_type,
        product_category AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        total_profits,


        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        missing_profit_count

    FROM category_totals

    UNION ALL

    -- KPI 4: Gesamtumsatz nach Kundensegment
    SELECT
        'segment_total'::text AS report_type,
        customer_segment AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        NULL::numeric AS total_profits,
        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_totals

    UNION ALL

    -- KPI 5: Umsatzwachstum nach Kundensegment
    SELECT
        'segment_year'::text AS report_type,
        customer_segment AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,


        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_previous_sales)

-- ============================================================
-- FINAL SELECT
-- Berechnet abgeleitete KPIs ohne neue Aggregationen.
-- Rundung erst für die Ausgabe.
-- ============================================================

SELECT
    report_type,
    dimension_value,
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_profits, 2) AS total_profits,
    -- Marge aus Summen; fehlende Eingangswerte ergeben keine Marge.
    CASE
        WHEN report_type = 'category_total'
         AND missing_sales_count = 0
         AND missing_profit_count = 0
        THEN ROUND(total_profits / NULLIF(total_sales, 0) * 100, 2)
        ELSE NULL
    END AS profit_margin_percent,
    previous_year,
    ROUND(previous_year_sales, 2) AS previous_year_sales,
    -- Nur direkte Vorjahre vergleichen; NULLIF schützt vor Division durch 0.
    CASE
        WHEN report_type IN ('region_year', 'segment_year')
         AND previous_year = order_year - 1
         AND missing_sales_count = 0
         AND previous_missing_sales_count = 0
        THEN ROUND(
            (total_sales - previous_year_sales)
            / NULLIF(previous_year_sales, 0) * 100, 2
        )
        ELSE NULL
    END AS sales_growth_percent,
    position_count,
    missing_sales_count,
    missing_profit_count

FROM reporting

ORDER BY
    CASE report_type
        WHEN 'region_year' THEN 1
        WHEN 'category_total' THEN 2
        WHEN 'segment_total' THEN 3
        WHEN 'segment_year' THEN 4
    END,
    dimension_value,
    order_year NULLS LAST;

/*
Ergebnisprüfung – Regionsfilter all:

Die Ausgabe enthält 34 Zeilen und 12 Spalten.

Jede der vier Ergebnisarten umfasst für sich
9.997 Bestellpositionen und einen Gesamtumsatz
von 2.307.249.

Die Ausgabe enthält:
- 16 Region-Jahr-Ergebnisse
- 3 Kategorie-Gesamtergebnisse
- 3 Segment-Gesamtergebnisse
- 12 Segment-Jahr-Ergebnisse

Interpretation:
Der Parameterwert all deaktiviert den Regionsfilter.
Alle vier Regionen werden berücksichtigt.

Die Kontrollsummen stimmen zwischen den
vier Ergebnisarten überein.
Es fehlen keine Umsatzwerte.

Die verschiedenen Ergebnisarten dürfen nicht
miteinander addiert werden, da sie dieselbe
Datenbasis unterschiedlich darstellen.

Die Originaldaten bleiben unverändert.
*/