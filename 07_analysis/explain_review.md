# Unicorn – EXPLAIN-Review

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi

Query 2 bildet den vollständigen Performance-Review. Query 1 ist als ergänzende Planbetrachtung dokumentiert. Beide Ausgaben stammen aus reinem `EXPLAIN`; tatsächliche Laufzeiten wurden damit nicht gemessen. Die Originalpläne und SQL-Anweisungen stehen jeweils unter der Einordnung.

## Query 1 – Top-3-Kunden je Region nach Umsatz (2017–2018)

Der Plan aus `outputs/explain_review_query1.csv` verwendet vier sequenzielle Scans und drei Hash Joins. Die Filter für Zeitraum, Land und Versandarten werden bereits beim Scan von `orders` angewendet. Anschließend summiert `HashAggregate` den Umsatz je Region und Kunde. Ein `Sort` ordnet die Gruppen nach Region, Umsatz absteigend und Kunden-ID. `WindowAgg` berechnet die Rangfolge und berücksichtigt die Top-3-Auswahl über die Run Condition `row_number() <= 3`. Abschließend nutzt `Incremental Sort` die bestehende Regionssortierung für die Ausgabe nach Region und Rang.

Der oberste Knoten weist `cost=880.77..1147.83` aus. Diese geschätzten Kosten enthalten die untergeordneten Arbeitsschritte und sind keine gemessenen Laufzeiten. Die weiterhin ausgewiesenen `rows=3180` bilden die Top-3-Begrenzung nicht angemessen ab; der separate Ergebnisexport `outputs/trend_and_ranking_query1.csv` enthält tatsächlich zwölf Zeilen. Diese Ergebniszahl stammt aus dem Export, nicht aus einer Laufzeitmessung des Plans.

Für die geschätzten Tabellengrößen und die Auswertung über zwei Jahre sind sequenzielle Scans und Hash Joins plausibel. Aus dem reinen `EXPLAIN` ergibt sich kein belastbarer Anlass für zusätzliche Indizes oder eine Umformulierung. Bei weiterem Optimierungsbedarf würde ich mit `EXPLAIN (ANALYZE, BUFFERS)` tatsächliche Zeilenzahlen, Laufzeiten und Pufferzugriffe prüfen.



### Tatsächliche EXPLAIN-Ausgabe

```text
Incremental Sort  (cost=880.77..1147.83 rows=3180 width=53)
  Sort Key: ranked.shipping_region, ranked.rank_in\
  Presorted Key: ranked.shipping_region
  ->  Subquery Scan on ranked  (cost=879.67..990.97 rows=3180 width=53)
        ->  WindowAgg  (cost=879.67..951.22 rows=3180 width=53)
              Run Condition: (row_number() OVER (?) <= 3)
              ->  Sort  (cost=879.67..887.62 rows=3180 width=45)
                    Sort Key: o.shipping_region, (sum(od.order_sales)) DESC NULLS LAST, c.customer_id
                    ->  HashAggregate  (cost=623.13..662.88 rows=3180 width=45)
                          Group Key: o.shipping_region, c.customer_id
                          ->  Hash Join  (cost=316.15..589.80 rows=4443 width=21)
                                Hash Cond: (od.product_id = p.product_id)
                                ->  Hash Join  (cost=249.53..511.49 rows=4443 width=29)
                                      Hash Cond: (o.customer_id = c.customer_id)
                                      ->  Hash Join  (cost=224.64..474.88 rows=4443 width=29)
                                            Hash Cond: (od.order_id = o.order_id)
                                            ->  Seq Scan on order\_details od  (cost=0.00..223.97 rows=9997 width=31)
                                            ->  Hash  (cost=196.79..196.79 rows=2228 width=28)
                                                  ->  Seq Scan on orders o  (cost=0.00..196.79 rows=2228 width=28)
                                                        Filter: ((order_date >= '2017-01-01'::date) AND (order_date < '2019-01-01'::date) AND (shipping_country = 'United States'::text) AND (shipping_mode = ANY ('{"First Class","Same Day","Second Class","Standard Class"}'::text\[])))
                                      ->  Hash  (cost=14.95..14.95 rows=795 width=8)
                                            ->  Seq Scan on customers c  (cost=0.00..14.95 rows=795 width=8)
                                ->  Hash  (cost=43.50..43.50 rows=1850 width=8)
                                      ->  Seq Scan on product p  (cost=0.00..43.50 rows=1850 width=8)
```

### Geprüfte SQL-Anweisung

```sql
EXPLAIN
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
          'Standard Class')),

-- per\_customer: Umsatz je Kunde und Versandregion summieren.
per\_customer AS (
    SELECT
        shipping_region,
        customer_id,
        SUM(order_sales)::numeric AS customer_revenue
    FROM base
    -- SUM ignoriert NULL. Vollständige Umsatzwerte sind eine
    -- QA-Voraussetzung; fehlende Werte nicht als Nullumsatz deuten.
    GROUP BY shipping\_region, customer_id),

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
    FROM per_customer)

-- FINAL SELECT: Erst nach Berechnung der Fensterfunktion filtern.
SELECT
    shipping_region,
    customer_id,
    ROUND(customer_revenue, 2) AS customer_revenue,
    rank_in_region
FROM ranked
WHERE rank_in_region <= 3
ORDER BY shipping_region, rank_in_region;
```

## Query 2 – Umsatzwachstum je Region



### Untersuchte Query

Query 2 aus `trend_and_ranking.sql` berechnet den Jahresumsatz und das Vorjahreswachstum je Versandregion für 2015–2018. Der Scope umfasst United States und die vier Versandarten First Class, Same Day, Second Class und Standard Class. Die separate Datei `explain_review.sql` enthält dieselbe Abfragelogik mit vorangestelltem `EXPLAIN`.

### Drei Beobachtungen

#### 1\. Knoten mit den höchsten geschätzten Gesamtkosten

Der oberste Knoten `Subquery Scan on with_prev` hat mit `cost=832.03..908.97` die höchsten geschätzten Gesamtkosten. Diese enthalten die Arbeit der darunterliegenden Knoten; sie messen nicht allein den Aufwand dieses Knotens. Unterhalb liegen `WindowAgg`, eine Sortierung nach Region und Jahr, `HashAggregate` und drei Hash Joins. Aus den Gesamtkosten allein lässt sich kein einzelner Laufzeitengpass ableiten. Kosten sind Schätzwerte des Planers, keine Millisekunden.

#### 2\. Angemessenheit für die Tabellengrößen

Der Plan verwendet sequenzielle Scans für alle vier Tabellen und Hash Joins für ihre Verknüpfung. Er schätzt 9.997 Zeilen für `order_details`, 795 für `customers` und 1.850 für `product`. Beim Scan von `orders` werden nach Anwendung der Filter 3.712 Zeilen geschätzt; dies ist nicht die Gesamtzahl der Bestellungen. Für kleine Tabellen und eine breite Auswertung über vier Jahre ist diese Strategie plausibel. Ein sequenzieller Scan ist hier für sich genommen kein Hinweis auf einen fehlenden Index oder ein Performanceproblem.

#### 3\. Was ich weiter untersuchen würde

Für das Aggregat und die abschließende Ausgabe schätzt der Plan 1.231 Zeilen. Die separat ausgeführte Query 2 lieferte im Ergebnisexport dagegen 16 Zeilen. Ich würde bei weiterem Untersuchungsbedarf die Aktualität der Tabellenstatistiken prüfen und mit `EXPLAIN ANALYZE` geschätzte und tatsächliche Zeilenzahlen sowie Laufzeiten vergleichen. Die Abweichung zeigt eine ungenaue Kardinalitätsschätzung, beweist aber weder veraltete Statistiken noch ein Laufzeitproblem.

### Was ich gegebenenfalls ändern würde

Auf Grundlage dieses Plans würde ich zunächst weder die Query umschreiben noch einen zusätzlichen Index anlegen. Es liegen keine gemessenen Laufzeiten vor, die eine solche Änderung begründen. Erst bei tatsächlich relevantem Laufzeitbedarf würde ich die Schätzabweichung weiter untersuchen und mögliche Änderungen anhand von Messungen bewerten.

### Nachweis und Reproduzierbarkeit

Der folgende Plan wurde unverändert aus `outputs/explain_review.csv` übernommen; lediglich die CSV-Verpackung wurde entfernt. Es handelt sich um `EXPLAIN`, nicht `EXPLAIN ANALYZE`: Der Plan enthält keine tatsächlichen Laufzeiten oder gemessenen Zeilenzahlen. Die 16 Ergebniszeilen stammen aus `outputs/trend_and_ranking_query2.csv`.

Die unten stehende Anweisung kann gegen dieselbe Unicorn-Datenbank ausgeführt werden. Plan und Kostenschätzungen können sich mit PostgreSQL-Version, Statistiken, Einstellungen und Datenstand ändern. Die verwendete Datenbankversion ist PostgreSQL 15.19 (f55ec65), 64-bit, auf aarch64-unknown-linux-gnu. Nachweis: `SELECT version();`, exportiert als `outputs/explain_review-postgreSQL_version.csv`. Compiler laut Ausgabe: gcc (Debian 10.2.1-6) 10.2.1 20210110.

### Tatsächliche EXPLAIN-Ausgabe

```text
Subquery Scan on with_prev  (cost=832.03..908.97 rows=1231 width=105)
  ->  WindowAgg  (cost=832.03..862.81 rows=1231 width=93)
        ->  Sort  (cost=832.03..835.11 rows=1231 width=49)
              Sort Key: o.shipping_region, ((EXTRACT(year FROM o.order_date))::integer)
              ->  HashAggregate  (cost=734.99..756.54 rows=1231 width=49)
                    Group Key: (EXTRACT(year FROM o.order_date))::integer, o.shipping_region
                    ->  Hash Join  (cost=334.70..660.96 rows=7403 width=17)
                          Hash Cond: (od.product_id = p.product_id)
                          ->  Hash Join  (cost=268.08..537.85 rows=7403 width=29)
                                Hash Cond: (o.customer_id = c.customer_id)
                                ->  Hash Join  (cost=243.19..493.43 rows=7403 width=37)
                                      Hash Cond: (od.order_id = o.order_id)
                                      ->  Seq Scan on order_details od  (cost=0.00..223.97 rows=9997 width=31)
                                      ->  Hash  (cost=196.79..196.79 rows=3712 width=36)
                                            ->  Seq Scan on orders o  (cost=0.00..196.79 rows=3712 width=36)
                                                  Filter: ((order_date >= '2015-01-01'::date) AND (order_date < '2019-01-01'::date) AND (shipping_country = 'United States'::text) AND (shipping_mode = ANY ('{"First Class","Same Day","Second Class","Standard Class"}'::text\[])))
                                ->  Hash  (cost=14.95..14.95 rows=795 width=8)
                                      ->  Seq Scan on customers c  (cost=0.00..14.95 rows=795 width=8)
                          ->  Hash  (cost=43.50..43.50 rows=1850 width=8)
                                ->  Seq Scan on product p  (cost=0.00..43.50 rows=1850 width=8)
```

### Geprüfte SQL-Anweisung

```sql
-- ============================================================
-- QUERY 2 – UMSATZ UND VORJAHRESWACHSTUM JE REGION
-- ============================================================

/\*
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
\*/


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
        COUNT(\*) FILTER (
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
            100.0 \* (revenue - prev_year_revenue)
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
```

