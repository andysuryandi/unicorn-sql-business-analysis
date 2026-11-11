-- ============================================================
-- UNICORN - TREND UND RANKING
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Verwendete Tabellen:
- customers
- orders
- order_details
- product

Arbeitsstand:
Beide Queries ausgeführt und anhand der CSV-Exporte geprüft.

Aufbau:
Query 1: base -> per_customer -> ranked -> Final SELECT
Query 2: base -> per_region_year -> with_prev -> Final SELECT

Land und Versandarten entsprechen dem Reporting-Stack unter `06_reporting_stack/`.
Postleitzahl- und Herstellerfelder werden hier nicht benötigt.
Die Cleaning-Regeln des Stacks ändern keine Umsatzwerte und
schließen keine Zeilen aus; der Vier-Tabellen-Join bleibt erhalten.
*/

-- ============================================================
-- QUERY 1 - TOP-3-KUNDEN JE REGION NACH UMSATZ, 2017-2018
-- Output: shipping_region, customer_id, customer_revenue,
--         rank_in_region
-- Grain: Eine Zeile je ausgewähltem Kunden und Versandregion.
-- Erwartung: 12 Zeilen (4 Regionen mit jeweils 3 Kunden).
-- ============================================================

-- base: Bestellpositionen im festgelegten Business Scope auswählen.
WITH base AS (
    SELECT
        o.shipping_region,
        c.customer_id,
        od.order_sales
    FROM order_details AS od
    JOIN orders AS o
        ON od.order_id = o.order_id
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    JOIN product AS p
        ON od.product_id = p.product_id
    -- Vor der Aggregation filtern: Ranking für 2017-2018,
    -- kein Ranking über die gesamte Kundenhistorie.
    WHERE o.order_date >= DATE '2017-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'
      )
),

-- per_customer: Umsatz je Kunde und Versandregion summieren.
per_customer AS (
    SELECT
        shipping_region,
        customer_id,
        SUM(order_sales)::numeric AS customer_revenue
    FROM base
    -- SUM ignoriert NULL. Vollständige Umsatzwerte sind eine
    -- QA-Voraussetzung; fehlende Werte nicht als Nullumsatz deuten.
    GROUP BY shipping_region, customer_id
),

-- ranked: Innerhalb jeder Region eindeutige Rangplätze vergeben.
ranked AS (
    SELECT
        shipping_region,
        customer_id,
        customer_revenue,
        -- ROW_NUMBER liefert genau drei Kunden je Region,
        -- sofern mindestens drei Kunden vorhanden sind.
        -- customer_id löst Umsatzgleichstände reproduzierbar auf.
        ROW_NUMBER() OVER (
            PARTITION BY shipping_region
            ORDER BY customer_revenue DESC NULLS LAST, customer_id ASC
        ) AS rank_in_region
    FROM per_customer
)

-- FINAL SELECT: Erst nach Berechnung der Fensterfunktion filtern.
SELECT
    shipping_region,
    customer_id,
    ROUND(customer_revenue, 2) AS customer_revenue,
    rank_in_region
FROM ranked
WHERE rank_in_region <= 3
ORDER BY shipping_region, rank_in_region;
/*
Ergebnisprüfung – Query 1:

Die exportierte Ausgabe enthält 12 Zeilen und 4 Spalten.
Jede der vier Regionen enthält genau drei unterschiedliche
Kunden mit den Rangplätzen 1, 2 und 3.

Die Kundenumsätze sind innerhalb jeder Region absteigend
sortiert. Die erwartete Ausgabestruktur ist damit erfüllt.

Beobachtung:
Kunde 731 in Central weist mit 18.336,00 den höchsten
ausgewiesenen Kundenumsatz unter den zwölf Ergebnissen auf.
Daraus lässt sich keine Aussage über den Gesamtumsatz
oder das Wachstum einer Region ableiten.

Prüfgrenze:
Die CSV bestätigt die Ausgabestruktur und Sortierung.
Die Umsatzsummen und der Zeitraum wurden anhand dieses
Exports nicht unabhängig gegen die Quelldaten geprüft.
*/

-- ============================================================
-- QUERY 2 – UMSATZ UND VORJAHRESWACHSTUM JE REGION
-- ============================================================

/*
Zweck:
Zeigt die jährliche Umsatzentwicklung je Versandregion
für den Zeitraum 2015–2018.

Aufbau:
base → per_region_year → with_prev → Final SELECT

Grain der Ausgabe:
Eine Zeile je Kalenderjahr und Versandregion.

Erwartete Ausgabe:
16 Zeilen = 4 Jahre × 4 Regionen.

Spalten:
year, shipping_region, revenue,
prev_year_revenue, yoy_growth_pct

Business Scope:
United States; First Class, Same Day,
Second Class und Standard Class.

Die Join- und Filterlogik entspricht dem Reporting-Stack.
Postleitzahl- und Herstellerfelder werden hier nicht benötigt.
*/


-- ============================================================
-- LAYER 1 – BASE
-- Eine Zeile je Bestellposition im definierten Scope.
-- ============================================================

WITH base AS (

    SELECT
        o.order_date,
        o.shipping_region,
        od.order_sales

    FROM order_details AS od

    JOIN orders AS o
        ON od.order_id = o.order_id

    JOIN customers AS c
        ON o.customer_id = c.customer_id

    JOIN product AS p
        ON od.product_id = p.product_id

    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'
      )
),


-- ============================================================
-- LAYER 2 – PER_REGION_YEAR
-- Summiert Umsatz je Jahr und Region und zählt fehlende Werte.
-- ============================================================

per_region_year AS (

    SELECT
        EXTRACT(YEAR FROM order_date)::integer AS year,
        shipping_region,
        SUM(order_sales)::numeric AS revenue,

        -- SUM ignoriert NULL-Werte.
        -- Der Zähler verhindert Wachstumsraten auf lückenhafter Basis.
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        EXTRACT(YEAR FROM order_date)::integer,
        shipping_region
),


-- ============================================================
-- LAYER 3 – WITH_PREV
-- Ergänzt die Werte der vorherigen vorhandenen Jahreszeile.
-- ============================================================

with_prev AS (

    SELECT
        year,
        shipping_region,
        revenue,
        missing_sales_count,

        -- Jede Region wird ausschließlich mit sich selbst verglichen.
        LAG(year) OVER (
            PARTITION BY shipping_region
            ORDER BY year
        ) AS prev_year,

        LAG(revenue) OVER (
            PARTITION BY shipping_region
            ORDER BY year
        ) AS prev_year_revenue,

        LAG(missing_sales_count) OVER (
            PARTITION BY shipping_region
            ORDER BY year
        ) AS prev_missing_sales_count

    FROM per_region_year
)


-- ============================================================
-- FINAL SELECT
-- Berechnet das Wachstum; rundet erst für die Ausgabe.
-- ============================================================

SELECT
    year,
    shipping_region,
    ROUND(revenue, 2) AS revenue,
    ROUND(prev_year_revenue, 2) AS prev_year_revenue,

    CASE
        -- LAG liefert die vorherige vorhandene Zeile.
        -- Nur unmittelbar aufeinanderfolgende Jahre vergleichen.
        WHEN prev_year = year - 1
         AND missing_sales_count = 0
         AND prev_missing_sales_count = 0

        THEN ROUND(
            100.0 * (revenue - prev_year_revenue)
            / NULLIF(prev_year_revenue, 0),
            2
        )

        -- Kein Vorjahr, fehlende Umsatzwerte oder Jahreslücke:
        -- keine belastbare Wachstumsrate ausweisen.
        ELSE NULL
    END AS yoy_growth_pct

FROM with_prev

ORDER BY
    shipping_region,
    year;
/*
Ergebnisprüfung – Query 2:

Die exportierte Ausgabe enthält 16 Zeilen und 5 Spalten:
vier Regionen mit jeweils vier Jahren von 2015 bis 2018.

Alle Vorjahresumsätze stimmen mit den entsprechenden
Vorjahreszeilen überein. Die zwölf Wachstumsraten wurden
anhand der exportierten Umsätze nachgerechnet und stimmen
auf zwei Nachkommastellen.

Für 2015 fehlen Vorjahresumsatz und Wachstumsrate
erwartungsgemäß, da 2014 außerhalb des Analysezeitraums liegt.

Beobachtung:
West verzeichnet 2018 mit 33,37 % das höchste relative
Umsatzwachstum, knapp vor South mit 33,16 %.
Central zeigt nach 43,31 % Wachstum im Jahr 2017
einen leichten Umsatzrückgang von 0,23 % im Jahr 2018.

Prüfgrenze:
Die Prüfung bestätigt die Konsistenz der CSV-Ergebnisse.
Ein unabhängiger Abgleich der Umsatzsummen mit den
Quelldaten wurde damit nicht durchgeführt.
*/
