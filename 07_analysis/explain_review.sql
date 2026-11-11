-- ============================================================
-- UNICORN – EXPLAIN REVIEW 
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Den geschätzten Ausführungsplan der regionalen
Umsatz- und Wachstumsanalyse untersuchen.

Stakeholder-Frage:
Wo sollten wir den Fokus für weiteres Wachstum setzen?

Verwendete Tabellen:
- customers
- orders
- order_details
- product

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Grain:
Eine Zeile in der Base entspricht einer Bestellposition
(order_details.order_details_id).

Aufbau:
1. base            – Canonical Join und Filterung
2. per_region_year – Umsatzaggregation nach Region und Jahr
3. with_prev       – Vorjahresvergleich mit LAG()
4. Final SELECT    – Umsatz und Vorjahreswachstum

Prüfumfang:
- Ausführungsplan von Query 2 aus trend_and_ranking.sql
- Geschätzte Kosten und Zeilenzahlen
- JOIN-, Scan-, Aggregations- und Sortieroperationen

Nachweise:
- explain_review.csv
- explain_review.md

Wichtig:
EXPLAIN liefert geschätzte Kosten und Zeilenzahlen,
keine tatsächlichen Laufzeiten.
Die Originaldaten bleiben unverändert.
*/

-- ============================================================
-- EXPLAIN – QUERY 1: TOP-3-KUNDEN JE REGION
-- ============================================================

EXPLAIN
WITH base AS (

    -- Eine Zeile je Bestellposition im Business Scope.
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

    WHERE o.order_date >= DATE '2017-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')),

-- ============================================================
-- LAYER 2 – PER_CUSTOMER
-- Umsatz je Kunde und Versandregion aggregieren.
-- ============================================================

per_customer AS (

    SELECT
        shipping_region,
        customer_id,
        SUM(order_sales)::numeric AS customer_revenue

    FROM base

    GROUP BY
        shipping_region,
        customer_id),

-- ============================================================
-- LAYER 3 – RANKED
-- Top-Kunden innerhalb jeder Region bestimmen.
-- ============================================================

ranked AS (

    SELECT
        shipping_region,
        customer_id,
        customer_revenue,

        ROW_NUMBER() OVER (
            PARTITION BY shipping_region
            ORDER BY
                customer_revenue DESC NULLS LAST,
                customer_id ASC
        ) AS rank_in_region

    FROM per_customer)

-- ============================================================
-- FINAL SELECT
-- Drei umsatzstärkste Kunden je Region ausgeben.
-- ============================================================

SELECT
    shipping_region,
    customer_id,
    ROUND(customer_revenue, 2) AS customer_revenue,
    rank_in_region

FROM ranked

WHERE rank_in_region <= 3

ORDER BY
    shipping_region,
    rank_in_region;

/*
Ergebnisinterpretation:
Die Abfrage zeigt je Versandregion die drei umsatzstärksten Kunden
im Zeitraum 2017–2018 innerhalb des definierten Business Scope.
Der Umsatz wird je Kunde und Region über beide Jahre summiert.

Rang 1 kennzeichnet den höchsten Kundenumsatz der jeweiligen Region.
Bei Umsatzgleichstand entscheidet die Kunden-ID über die Reihenfolge.
Bei vier Regionen mit mindestens drei Kunden werden zwölf Zeilen ausgegeben.

Das Ranking bewertet den Umsatz, nicht die Profitabilität der Kunden.
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

EXPLAIN
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
          'Standard Class')),


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
        shipping_region),


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

    FROM per_region_year)


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
            2)

        -- Kein Vorjahr, fehlende Umsatzwerte oder Jahreslücke:
        -- keine belastbare Wachstumsrate ausweisen.
        ELSE NULL
    END AS yoy_growth_pct

FROM with_prev

ORDER BY
    shipping_region,
    year;

-- ============================================================
-- DATENBANKVERSION – REPRODUZIERBARKEIT
-- ============================================================

SELECT version();

/*
EXPLAIN-Review – Query 2

Zweck:
Ausführungsplan für den Jahresumsatz und das
Vorjahreswachstum je Region untersuchen.

Datenbankversion: PostgreSQL 15.19

Planexport: explain_review.csv
Dokumentation: explain_review.md

Hinweis:
EXPLAIN zeigt geschätzte Kosten und Zeilenzahlen.
Tatsächliche Laufzeiten werden nicht gemessen.
*/







