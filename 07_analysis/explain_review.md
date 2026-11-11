# Unicorn – EXPLAIN-Review

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi

Query 2 bildet den vollständigen Performance-Review. Query 1 ist als ergänzende Planbetrachtung dokumentiert. Beide Ausgaben stammen aus reinem `EXPLAIN`; tatsächliche Laufzeiten wurden damit nicht gemessen. Die Originalpläne und SQL-Anweisungen stehen jeweils unter der Einordnung.

## Query 1 – Top-3-Kunden je Region nach Umsatz (2017–2018)

Der Plan aus `outputs/explain\_review\_query1.csv` verwendet vier sequenzielle Scans und drei Hash Joins. Die Filter für Zeitraum, Land und Versandarten werden bereits beim Scan von `orders` angewendet. Anschließend summiert `HashAggregate` den Umsatz je Region und Kunde. Ein `Sort` ordnet die Gruppen nach Region, Umsatz absteigend und Kunden-ID. `WindowAgg` berechnet die Rangfolge und berücksichtigt die Top-3-Auswahl über die Run Condition `row\_number() <= 3`. Abschließend nutzt `Incremental Sort` die bestehende Regionssortierung für die Ausgabe nach Region und Rang.

Der oberste Knoten weist `cost=880.77..1147.83` aus. Diese geschätzten Kosten enthalten die untergeordneten Arbeitsschritte und sind keine gemessenen Laufzeiten. Die weiterhin ausgewiesenen `rows=3180` bilden die Top-3-Begrenzung nicht angemessen ab; der separate Ergebnisexport `outputs/trend\_and\_ranking\_query1.csv` enthält tatsächlich zwölf Zeilen. Diese Ergebniszahl stammt aus dem Export, nicht aus einer Laufzeitmessung des Plans.

Für die geschätzten Tabellengrößen und die Auswertung über zwei Jahre sind sequenzielle Scans und Hash Joins plausibel. Aus dem reinen `EXPLAIN` ergibt sich kein belastbarer Anlass für zusätzliche Indizes oder eine Umformulierung. Bei weiterem Optimierungsbedarf würde ich mit `EXPLAIN (ANALYZE, BUFFERS)` tatsächliche Zeilenzahlen, Laufzeiten und Pufferzugriffe prüfen.



### Tatsächliche EXPLAIN-Ausgabe

```text
Incremental Sort  (cost=880.77..1147.83 rows=3180 width=53)
  Sort Key: ranked.shipping\_region, ranked.rank\_in\_region
  Presorted Key: ranked.shipping\_region
  ->  Subquery Scan on ranked  (cost=879.67..990.97 rows=3180 width=53)
        ->  WindowAgg  (cost=879.67..951.22 rows=3180 width=53)
              Run Condition: (row\_number() OVER (?) <= 3)
              ->  Sort  (cost=879.67..887.62 rows=3180 width=45)
                    Sort Key: o.shipping\_region, (sum(od.order\_sales)) DESC NULLS LAST, c.customer\_id
                    ->  HashAggregate  (cost=623.13..662.88 rows=3180 width=45)
                          Group Key: o.shipping\_region, c.customer\_id
                          ->  Hash Join  (cost=316.15..589.80 rows=4443 width=21)
                                Hash Cond: (od.product\_id = p.product\_id)
                                ->  Hash Join  (cost=249.53..511.49 rows=4443 width=29)
                                      Hash Cond: (o.customer\_id = c.customer\_id)
                                      ->  Hash Join  (cost=224.64..474.88 rows=4443 width=29)
                                            Hash Cond: (od.order\_id = o.order\_id)
                                            ->  Seq Scan on order\_details od  (cost=0.00..223.97 rows=9997 width=31)
                                            ->  Hash  (cost=196.79..196.79 rows=2228 width=28)
                                                  ->  Seq Scan on orders o  (cost=0.00..196.79 rows=2228 width=28)
                                                        Filter: ((order\_date >= '2017-01-01'::date) AND (order\_date < '2019-01-01'::date) AND (shipping\_country = 'United States'::text) AND (shipping\_mode = ANY ('{"First Class","Same Day","Second Class","Standard Class"}'::text\[])))
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
        o.shipping\_region,
        c.customer\_id,
        od.order\_sales
    FROM order\_details AS od
    JOIN orders AS o
        ON od.order\_id = o.order\_id
    JOIN customers AS c
        ON o.customer\_id = c.customer\_id
    JOIN product AS p
        ON od.product\_id = p.product\_id
    -- Vor der Aggregation filtern: Ranking für 2017-2018,
    -- kein Ranking über die gesamte Kundenhistorie.
    WHERE o.order\_date >= DATE '2017-01-01'
      AND o.order\_date < DATE '2019-01-01'
      AND o.shipping\_country = 'United States'
      AND o.shipping\_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')),

-- per\_customer: Umsatz je Kunde und Versandregion summieren.
per\_customer AS (
    SELECT
        shipping\_region,
        customer\_id,
        SUM(order\_sales)::numeric AS customer\_revenue
    FROM base
    -- SUM ignoriert NULL. Vollständige Umsatzwerte sind eine
    -- QA-Voraussetzung; fehlende Werte nicht als Nullumsatz deuten.
    GROUP BY shipping\_region, customer\_id),

-- ranked: Innerhalb jeder Region eindeutige Rangplätze vergeben.
ranked AS (
    SELECT
        shipping\_region,
        customer\_id,
        customer\_revenue,
        -- ROW\_NUMBER liefert genau drei Kunden je Region,
        -- sofern mindestens drei Kunden vorhanden sind.
        -- customer\_id löst Umsatzgleichstände reproduzierbar auf.
        ROW\_NUMBER() OVER (
            PARTITION BY shipping\_region
            ORDER BY customer\_revenue DESC NULLS LAST, customer\_id ASC
        ) AS rank\_in\_region
    FROM per\_customer)

-- FINAL SELECT: Erst nach Berechnung der Fensterfunktion filtern.
SELECT
    shipping\_region,
    customer\_id,
    ROUND(customer\_revenue, 2) AS customer\_revenue,
    rank\_in\_region
FROM ranked
WHERE rank\_in\_region <= 3
ORDER BY shipping\_region, rank\_in\_region;
```

## Query 2 – Umsatzwachstum je Region



### Untersuchte Query

Query 2 aus `trend\_and\_ranking.sql` berechnet den Jahresumsatz und das Vorjahreswachstum je Versandregion für 2015–2018. Der Scope umfasst United States und die vier Versandarten First Class, Same Day, Second Class und Standard Class. Die separate Datei `explain\_review.sql` enthält dieselbe Abfragelogik mit vorangestelltem `EXPLAIN`.

### Drei Beobachtungen

#### 1\. Knoten mit den höchsten geschätzten Gesamtkosten

Der oberste Knoten `Subquery Scan on with\_prev` hat mit `cost=832.03..908.97` die höchsten geschätzten Gesamtkosten. Diese enthalten die Arbeit der darunterliegenden Knoten; sie messen nicht allein den Aufwand dieses Knotens. Unterhalb liegen `WindowAgg`, eine Sortierung nach Region und Jahr, `HashAggregate` und drei Hash Joins. Aus den Gesamtkosten allein lässt sich kein einzelner Laufzeitengpass ableiten. Kosten sind Schätzwerte des Planers, keine Millisekunden.

#### 2\. Angemessenheit für die Tabellengrößen

Der Plan verwendet sequenzielle Scans für alle vier Tabellen und Hash Joins für ihre Verknüpfung. Er schätzt 9.997 Zeilen für `order\_details`, 795 für `customers` und 1.850 für `product`. Beim Scan von `orders` werden nach Anwendung der Filter 3.712 Zeilen geschätzt; dies ist nicht die Gesamtzahl der Bestellungen. Für kleine Tabellen und eine breite Auswertung über vier Jahre ist diese Strategie plausibel. Ein sequenzieller Scan ist hier für sich genommen kein Hinweis auf einen fehlenden Index oder ein Performanceproblem.

#### 3\. Was ich weiter untersuchen würde

Für das Aggregat und die abschließende Ausgabe schätzt der Plan 1.231 Zeilen. Die separat ausgeführte Query 2 lieferte im Ergebnisexport dagegen 16 Zeilen. Ich würde bei weiterem Untersuchungsbedarf die Aktualität der Tabellenstatistiken prüfen und mit `EXPLAIN ANALYZE` geschätzte und tatsächliche Zeilenzahlen sowie Laufzeiten vergleichen. Die Abweichung zeigt eine ungenaue Kardinalitätsschätzung, beweist aber weder veraltete Statistiken noch ein Laufzeitproblem.

### Was ich gegebenenfalls ändern würde

Auf Grundlage dieses Plans würde ich zunächst weder die Query umschreiben noch einen zusätzlichen Index anlegen. Es liegen keine gemessenen Laufzeiten vor, die eine solche Änderung begründen. Erst bei tatsächlich relevantem Laufzeitbedarf würde ich die Schätzabweichung weiter untersuchen und mögliche Änderungen anhand von Messungen bewerten.

### Nachweis und Reproduzierbarkeit

Der folgende Plan wurde unverändert aus `outputs/explain\_review.csv` übernommen; lediglich die CSV-Verpackung wurde entfernt. Es handelt sich um `EXPLAIN`, nicht `EXPLAIN ANALYZE`: Der Plan enthält keine tatsächlichen Laufzeiten oder gemessenen Zeilenzahlen. Die 16 Ergebniszeilen stammen aus `outputs/trend\_and\_ranking\_query2.csv`.

Die unten stehende Anweisung kann gegen dieselbe Unicorn-Datenbank ausgeführt werden. Plan und Kostenschätzungen können sich mit PostgreSQL-Version, Statistiken, Einstellungen und Datenstand ändern. Die verwendete Datenbankversion ist PostgreSQL 15.19 (f55ec65), 64-bit, auf aarch64-unknown-linux-gnu. Nachweis: `SELECT version();`, exportiert als `outputs/explain\_review-postgreSQL\_version.csv`. Compiler laut Ausgabe: gcc (Debian 10.2.1-6) 10.2.1 20210110.

### Tatsächliche EXPLAIN-Ausgabe

```text
Subquery Scan on with\_prev  (cost=832.03..908.97 rows=1231 width=105)
  ->  WindowAgg  (cost=832.03..862.81 rows=1231 width=93)
        ->  Sort  (cost=832.03..835.11 rows=1231 width=49)
              Sort Key: o.shipping\_region, ((EXTRACT(year FROM o.order\_date))::integer)
              ->  HashAggregate  (cost=734.99..756.54 rows=1231 width=49)
                    Group Key: (EXTRACT(year FROM o.order\_date))::integer, o.shipping\_region
                    ->  Hash Join  (cost=334.70..660.96 rows=7403 width=17)
                          Hash Cond: (od.product\_id = p.product\_id)
                          ->  Hash Join  (cost=268.08..537.85 rows=7403 width=29)
                                Hash Cond: (o.customer\_id = c.customer\_id)
                                ->  Hash Join  (cost=243.19..493.43 rows=7403 width=37)
                                      Hash Cond: (od.order\_id = o.order\_id)
                                      ->  Seq Scan on order\_details od  (cost=0.00..223.97 rows=9997 width=31)
                                      ->  Hash  (cost=196.79..196.79 rows=3712 width=36)
                                            ->  Seq Scan on orders o  (cost=0.00..196.79 rows=3712 width=36)
                                                  Filter: ((order\_date >= '2015-01-01'::date) AND (order\_date < '2019-01-01'::date) AND (shipping\_country = 'United States'::text) AND (shipping\_mode = ANY ('{"First Class","Same Day","Second Class","Standard Class"}'::text\[])))
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
base → per\_region\_year → with\_prev → Final SELECT

Grain der Ausgabe:
Eine Zeile je Kalenderjahr und Versandregion.

Erwartete Ausgabe:
16 Zeilen = 4 Jahre × 4 Regionen.

Spalten:
year, shipping\_region, revenue,
prev\_year\_revenue, yoy\_growth\_pct

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
        o.order\_date,
        o.shipping\_region,
        od.order\_sales

    FROM order\_details AS od

    JOIN orders AS o
        ON od.order\_id = o.order\_id

    JOIN customers AS c
        ON o.customer\_id = c.customer\_id

    JOIN product AS p
        ON od.product\_id = p.product\_id

    WHERE o.order\_date >= DATE '2015-01-01'
      AND o.order\_date < DATE '2019-01-01'
      AND o.shipping\_country = 'United States'
      AND o.shipping\_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')),


-- ============================================================
-- LAYER 2 – PER\_REGION\_YEAR
-- Summiert Umsatz je Jahr und Region und zählt fehlende Werte.
-- ============================================================

per\_region\_year AS (

    SELECT
        EXTRACT(YEAR FROM order\_date)::integer AS year,
        shipping\_region,
        SUM(order\_sales)::numeric AS revenue,

        -- SUM ignoriert NULL-Werte.
        -- Der Zähler verhindert Wachstumsraten auf lückenhafter Basis.
        COUNT(\*) FILTER (
            WHERE order\_sales IS NULL
        ) AS missing\_sales\_count

    FROM base

    GROUP BY
        EXTRACT(YEAR FROM order\_date)::integer,
        shipping\_region),


-- ============================================================
-- LAYER 3 – WITH\_PREV
-- Ergänzt die Werte der vorherigen vorhandenen Jahreszeile.
-- ============================================================

with\_prev AS (

    SELECT
        year,
        shipping\_region,
        revenue,
        missing\_sales\_count,

        -- Jede Region wird ausschließlich mit sich selbst verglichen.
        LAG(year) OVER (
            PARTITION BY shipping\_region
            ORDER BY year
        ) AS prev\_year,

        LAG(revenue) OVER (
            PARTITION BY shipping\_region
            ORDER BY year
        ) AS prev\_year\_revenue,

        LAG(missing\_sales\_count) OVER (
            PARTITION BY shipping\_region
            ORDER BY year
        ) AS prev\_missing\_sales\_count

    FROM per\_region\_year)


-- ============================================================
-- FINAL SELECT
-- Berechnet das Wachstum; rundet erst für die Ausgabe.
-- ============================================================

SELECT
    year,
    shipping\_region,
    ROUND(revenue, 2) AS revenue,
    ROUND(prev\_year\_revenue, 2) AS prev\_year\_revenue,

    CASE
        -- LAG liefert die vorherige vorhandene Zeile.
        -- Nur unmittelbar aufeinanderfolgende Jahre vergleichen.
        WHEN prev\_year = year - 1
         AND missing\_sales\_count = 0
         AND prev\_missing\_sales\_count = 0

        THEN ROUND(
            100.0 \* (revenue - prev\_year\_revenue)
            / NULLIF(prev\_year\_revenue, 0),
            2)

        -- Kein Vorjahr, fehlende Umsatzwerte oder Jahreslücke:
        -- keine belastbare Wachstumsrate ausweisen.
        ELSE NULL
    END AS yoy\_growth\_pct

FROM with\_prev

ORDER BY
    shipping\_region,
    year;
```

