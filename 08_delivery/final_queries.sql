-- ============================================================
-- UNICORN – FINALE ANALYSE
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Zweck:
SQL-Grundlage für die sechs finalen Business-Fragen.

Arbeitsstand:
Q1–Q6 ausgeführt und anhand der CSV-Exporte geprüft.
Ergebnisdateien liegen im Unterordner outputs/.

Business Scope:
Zeitraum: 2015–2018
United States; First Class, Same Day,
Second Class und Standard Class.

Die Datenbasis entspricht dem bisherigen Reporting-Stack.
*/


-- ============================================================
-- Q1. What is total revenue by year, and what's the
-- year-over-year growth rate?
--
-- Grain: Eine Zeile je Kalenderjahr.
-- Erwartete Ausgabe: 4 Zeilen für 2015–2018.
-- Spalten: year, revenue, prev_year_revenue, yoy_growth_pct
-- ============================================================


-- base: Bestellpositionen im festgelegten Business Scope.
WITH base AS (

    SELECT
        o.order_date,
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


-- yearly: Jahresumsatz summieren und fehlende Umsatzwerte zählen.
yearly AS (

    SELECT
        EXTRACT(YEAR FROM order_date)::integer AS year,
        SUM(order_sales)::numeric AS revenue,

        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        EXTRACT(YEAR FROM order_date)::integer
),


-- with_prev: Vorheriges Jahr und dessen Umsatz ergänzen.
with_prev AS (

    SELECT
        year,
        revenue,
        missing_sales_count,

        -- Keine Partitionierung: Gesamtunternehmen je Jahr.
        LAG(year) OVER (
            ORDER BY year
        ) AS prev_year,

        LAG(revenue) OVER (
            ORDER BY year
        ) AS prev_year_revenue,

        LAG(missing_sales_count) OVER (
            ORDER BY year
        ) AS prev_missing_sales_count

    FROM yearly
)


-- FINAL SELECT: Vorjahreswachstum berechnen und Ausgabe runden.
SELECT
    year,
    ROUND(revenue, 2) AS revenue,
    ROUND(prev_year_revenue, 2) AS prev_year_revenue,

    CASE
        -- Nur direkte Vorjahre mit vollständigen Umsatzwerten
        -- vergleichen. NULLIF schützt vor Division durch null.
        WHEN prev_year = year - 1
         AND missing_sales_count = 0
         AND prev_missing_sales_count = 0

        THEN ROUND(
            100.0 * (revenue - prev_year_revenue)
            / NULLIF(prev_year_revenue, 0),
            2
        )

        ELSE NULL
    END AS yoy_growth_pct

FROM with_prev

ORDER BY year;
/*
Ergebnisprüfung – Q1:

Die Ausgabe enthält vier Zeilen und vier Spalten
für die Jahre 2015–2018.

Alle Vorjahreswerte und die drei Wachstumsraten wurden
anhand der exportierten Jahresumsätze nachgerechnet.
Die Jahresumsätze stimmen mit der Summe der regionalen
Jahresumsätze aus trend_and_ranking.sql, Query 2, überein.

Für 2015 fehlen Vorjahresumsatz und Wachstum erwartungsgemäß.

Beobachtung:
Nach einem Umsatzrückgang von 5,42 % im Jahr 2016 wächst
der Umsatz 2017 um 29,22 % und 2018 um weitere 20,34 %.
2018 erreicht der Umsatz mit 731.549,00 den höchsten
Jahreswert im betrachteten Zeitraum, während die
Wachstumsrate gegenüber 2017 zurückgeht.

Prüfgrenze:
Die Prüfung bestätigt die rechnerische Konsistenz und
Übereinstimmung der Exporte. Ein unabhängiger Abgleich
mit den Quelldaten wurde nicht durchgeführt.
*/

-- ============================================================
-- Q2. Which region is driving the most growth in 2017–2018,
-- and by how much?
-- ============================================================

/*
Zweck:
Vergleicht den regionalen Umsatz 2018 mit 2017.

Grain:
Eine Zeile je Versandregion.

Erwartete Ausgabe:
Vier Zeilen, absteigend nach prozentualem Umsatzwachstum.

Kennzahlen:
revenue_2017       – Umsatz im Ausgangsjahr
revenue_2018       – Umsatz im Folgejahr
revenue_change     – absoluter Umsatzanstieg bzw. Rückgang
yoy_growth_pct    – prozentuales Wachstum gegenüber 2017

Entscheidung:
Für Q3 gilt die Region mit dem höchsten yoy_growth_pct
als am schnellsten wachsende Region.
revenue_change zeigt zusätzlich den absoluten Beitrag
zur Umsatzveränderung des Unternehmens.
*/


-- base: Bestellpositionen für die beiden Vergleichsjahre.
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


-- per_region_year: Umsatz je Region und Jahr aggregieren.
per_region_year AS (

    SELECT
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer AS year,

        -- Bei fehlenden Umsatzwerten keine unvollständige
        -- Jahressumme als vollständigen Umsatz ausweisen.
        CASE
            WHEN COUNT(*) FILTER (
                WHERE order_sales IS NULL
            ) = 0
            THEN SUM(order_sales)::numeric
            ELSE NULL
        END AS revenue

    FROM base

    GROUP BY
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer
),


-- region_comparison: Beide Jahresumsätze nebeneinanderstellen.
region_comparison AS (

    SELECT
        shipping_region,

        MAX(revenue) FILTER (
            WHERE year = 2017
        ) AS revenue_2017,

        MAX(revenue) FILTER (
            WHERE year = 2018
        ) AS revenue_2018

    FROM per_region_year

    GROUP BY
        shipping_region
),


-- growth: Absolute Veränderung und prozentuales Wachstum.
growth AS (

    SELECT
        shipping_region,
        revenue_2017,
        revenue_2018,
        revenue_2018 - revenue_2017 AS revenue_change,

        -- NULLIF schützt vor Division durch null.
        -- Fehlende Jahresumsätze ergeben ebenfalls NULL.
        100.0 * (revenue_2018 - revenue_2017)
        / NULLIF(revenue_2017, 0) AS yoy_growth_pct

    FROM region_comparison
)


-- FINAL SELECT: Erst für die Darstellung runden.
SELECT
    shipping_region,
    ROUND(revenue_2017, 2) AS revenue_2017,
    ROUND(revenue_2018, 2) AS revenue_2018,
    ROUND(revenue_change, 2) AS revenue_change,
    ROUND(yoy_growth_pct, 2) AS yoy_growth_pct

FROM growth

-- Nach ungerundeten Wachstumsraten sortieren.
ORDER BY
    growth.yoy_growth_pct DESC NULLS LAST,
    shipping_region;
/*
Ergebnisprüfung – Q2:

Die Ausgabe enthält vier Zeilen und fünf Spalten.
Alle absoluten Umsatzveränderungen und Wachstumsraten
wurden anhand der exportierten Jahresumsätze nachgerechnet.

Die Jahresumsätze stimmen mit den regionalen Werten
aus trend_and_ranking.sql, Query 2, überein.

Die regionalen Umsatzveränderungen ergeben zusammen
123.645,00. Dies entspricht dem Gesamtanstieg von
607.904,00 im Jahr 2017 auf 731.549,00 im Jahr 2018.

Beobachtung:
West erzielt mit 33,37 % das höchste relative Wachstum
und mit 62.560,00 auch den größten absoluten Umsatzanstieg.
South folgt beim relativen Wachstum mit 33,16 %.
East trägt absolut etwas mehr zum Wachstum bei als South.
Central verzeichnet einen leichten Umsatzrückgang.

Entscheidung:
Q3 untersucht die Top-3-Kunden der Region West
nach ihrem Gesamtumsatz im Zeitraum 2017–2018.

Prüfgrenze:
Die Prüfung bestätigt die Konsistenz der Exporte.
Sie erklärt keine Wachstumsursachen und ersetzt keinen
unabhängigen Abgleich mit den Quelldaten.
*/

-- ============================================================
-- Q3. Within that fastest-growing region, who are the top 3
-- customers in 2017–2018 by revenue?
-- ============================================================

/*
Zweck:
Ermittelt die drei umsatzstärksten Kunden in West
für den gemeinsamen Zeitraum 2017–2018.

Begründung der Regionsauswahl:
Q2 identifiziert West als Region mit dem höchsten
prozentualen Umsatzwachstum von 2017 auf 2018.
Die Regionsauswahl wird hier ausdrücklich festgehalten.

Grain:
Eine Zeile je ausgewähltem Kunden innerhalb von West.

Erwartete Ausgabe:
Drei Zeilen mit shipping_region, customer_id,
customer_name, customer_revenue und rank_in_region.

Prüfgrenze:
Hoher Gesamtumsatz bedeutet nicht automatisch,
dass diese Kunden den größten Wachstumsbeitrag leisten.
*/


-- base: Bestellpositionen in West für 2017–2018 auswählen.
WITH base AS (

    SELECT
        o.shipping_region,
        c.customer_id,
        c.customer_name,
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
      AND o.shipping_region = 'West'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'
      )
),


-- per_customer: Gesamtumsatz je Kunde und Region berechnen.
per_customer AS (

    SELECT
        shipping_region,
        customer_id,
        customer_name,

        SUM(order_sales)::numeric AS customer_revenue

    FROM base

    -- SUM ignoriert NULL-Werte.
    -- Vollständige Umsatzwerte bleiben eine QA-Voraussetzung.
    GROUP BY
        shipping_region,
        customer_id,
        customer_name
),


-- ranked: Eindeutige Rangplätze innerhalb der Region vergeben.
ranked AS (

    SELECT
        shipping_region,
        customer_id,
        customer_name,
        customer_revenue,

        -- Genau drei Kunden auswählen.
        -- Die Kunden-ID löst Umsatzgleichstände reproduzierbar auf.
        ROW_NUMBER() OVER (
            PARTITION BY shipping_region
            ORDER BY
                customer_revenue DESC NULLS LAST,
                customer_id ASC
        ) AS rank_in_region

    FROM per_customer
)


-- FINAL SELECT: Top 3 auswählen und erst jetzt runden.
SELECT
    shipping_region,
    customer_id,
    customer_name,
    ROUND(customer_revenue, 2) AS customer_revenue,
    rank_in_region

FROM ranked

WHERE rank_in_region <= 3

ORDER BY
    rank_in_region;

/*
Ergebnisprüfung – Q3:

Die Ausgabe enthält drei Zeilen und fünf Spalten.
Alle drei Kunden gehören zur Versandregion West.
Die Rangplätze 1–3 sind vollständig und die Umsätze
absteigend sortiert.

Kunden-IDs und Umsätze stimmen mit dem bereits geprüften
West-Ranking aus trend_and_ranking.sql, Query 1, überein.

Beobachtung:
Raymond Buch (623) erzielt mit 14.345,00 den höchsten
Kundenumsatz in West im Zeitraum 2017–2018.
Es folgen Edward Hooks (250) mit 7.408,00 und
Jane Waco (347) mit 7.393,00.

Prüfgrenze:
Das Ranking betrachtet den Gesamtumsatz beider Jahre.
Es zeigt nicht, welche Kunden den größten Beitrag
zum Umsatzwachstum von 2017 auf 2018 geleistet haben.
Ein unabhängiger Abgleich mit den Quelldaten wurde
nicht durchgeführt.
*/

-- ============================================================
-- Q4. Looking across all years and regions, what share of total
-- revenue is being lost to the discount program
-- (compared to a hypothetical no-discount baseline)?
-- ============================================================

/*
Zweck:
Vergleicht den tatsächlichen Umsatz mit einer hypothetischen
No-Discount-Baseline über alle Jahre und Regionen im Scope.

Zeitraum:
2015–2018.

Grain:
Eine zusammenfassende Ergebniszeile.

Annahmen:
order_sales enthält den Umsatz nach Rabatt.
order_discount ist als Anteil gespeichert, z. B. 0.20 = 20 %.

Berechnung je Bestellposition:
No-Discount-Umsatz = order_sales / (1 - order_discount)

Berechnung des Anteils:
(No-Discount-Umsatz - tatsächlicher Umsatz)
    / No-Discount-Umsatz * 100

Datenkritik:
Die Gegenrechnung hält die verkaufte Menge unverändert.
Sie misst keine kausale Rabattwirkung und zeigt nicht,
welcher Umsatz ohne Rabatt tatsächlich erreichbar wäre.

Fehlende oder ungültige Eingangswerte werden gezählt.
Bei solchen Fällen wird keine vollständige Baseline
oder Rabattquote für den gesamten Scope ausgewiesen.
*/


-- base: Bestellpositionen aller Jahre und Regionen im Scope.
WITH base AS (

    SELECT
        od.order_sales::numeric AS order_sales,
        od.order_discount::numeric AS order_discount

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


-- assessed: Eingangswerte prüfen und Positionsbaseline berechnen.
assessed AS (

    SELECT
        order_sales,
        order_discount,

        CASE
            WHEN order_sales IS NOT NULL
             AND order_sales >= 0
             AND order_discount IS NOT NULL
             AND order_discount >= 0
             AND order_discount < 1
            THEN TRUE
            ELSE FALSE
        END AS is_valid,

        CASE
            WHEN order_sales IS NOT NULL
             AND order_sales >= 0
             AND order_discount IS NOT NULL
             AND order_discount >= 0
             AND order_discount < 1
            THEN order_sales / NULLIF(1 - order_discount, 0)
            ELSE NULL
        END AS no_discount_revenue

    FROM base
),


-- totals: Summen und Anzahl nicht verwendbarer Positionen bilden.
totals AS (

    SELECT
        COUNT(*) AS position_count,

        COUNT(*) FILTER (
            WHERE NOT is_valid
        ) AS invalid_position_count,

        -- Bei fehlenden Umsatzwerten keine vollständige
        -- tatsächliche Umsatzsumme ausweisen.
        CASE
            WHEN COUNT(*) FILTER (
                WHERE order_sales IS NULL
            ) = 0
            THEN SUM(order_sales)
            ELSE NULL
        END AS actual_revenue,

        -- Keine unvollständige Baseline als Gesamtwert ausgeben.
        CASE
            WHEN COUNT(*) FILTER (
                WHERE NOT is_valid
            ) = 0
            THEN SUM(no_discount_revenue)
            ELSE NULL
        END AS hypothetical_revenue_no_discount

    FROM assessed
)


-- FINAL SELECT: Rabattbetrag und Anteil an der Baseline berechnen.
SELECT
    position_count,
    invalid_position_count,
    ROUND(actual_revenue, 2) AS actual_revenue,

    ROUND(
        hypothetical_revenue_no_discount,
        2
    ) AS hypothetical_revenue_no_discount,

    ROUND(
        hypothetical_revenue_no_discount - actual_revenue,
        2
    ) AS implied_discount_amount,

    ROUND(
        100.0
        * (hypothetical_revenue_no_discount - actual_revenue)
        / NULLIF(hypothetical_revenue_no_discount, 0),
        2
    ) AS discount_share_of_baseline_pct

FROM totals;

/*
Ergebnisprüfung – Q4:

Die Ausgabe enthält eine Zeile und sechs Spalten.
Von 9.997 Bestellpositionen wurde keine durch die
definierten Eingangsprüfungen als ungültig markiert.

Der tatsächliche Umsatz von 2.307.249,00 stimmt mit
der Summe der Jahresumsätze aus Q1 überein.

Die exportierte No-Discount-Baseline von 2.876.822,69
abzüglich des tatsächlichen Umsatzes ergibt 569.573,69.
Dieser Betrag entspricht gerundet 19,80 % der Baseline.

Beobachtung:
Unter der Annahme unveränderter Absatzmengen beträgt
der rechnerische Rabattbetrag 19,80 % des hypothetischen
Umsatzes ohne Rabatte.

Prüfgrenze:
Die Berechnung setzt voraus, dass order_sales den Umsatz
nach Rabatt und order_discount den Rabattanteil enthält.
Ohne Rabatte könnten sich Absatzmengen verändern.
Das Ergebnis belegt deshalb weder einen tatsächlich
vermeidbaren Umsatzverlust noch eine kausale Rabattwirkung.

Differenz und Prozentanteil wurden anhand des Exports
nachgerechnet. Die Baseline wurde nicht unabhängig
aus den einzelnen Quelldatensätzen rekonstruiert.
*/

-- ============================================================
-- Q5. Which product categories carry the negative-margin
-- orders most heavily?
-- ============================================================

/*
Zweck:
Zeigt den Beitrag der Produktkategorien zum Nettoverlust
von insgesamt verlustbringenden Bestellungen.

Zeitraum:
2015–2018, alle Regionen im bisherigen Business Scope.

Definition einer Bestellung mit negativer Marge:
Gesamtumsatz > 0 und Gesamtgewinn < 0.
Bei positivem Umsatz ist damit auch Gewinn / Umsatz negativ.

Vorgehen:
1. Umsatz und Gewinn je vollständiger Bestellung berechnen.
2. Bestellungen mit negativer Marge auswählen.
3. Ihre Positionen nach Produktkategorie aggregieren.

Grain der Ausgabe:
Eine Zeile je Produktkategorie, die in den ausgewählten
Verlustbestellungen vorkommt.

Interpretation:
Ein positiver net_loss_contribution zeigt einen Verlustbeitrag.
Ein negativer Wert zeigt einen positiven Gewinnbeitrag,
der Verluste anderer Kategorien innerhalb dieser
Bestellungen teilweise ausgleicht.

Prüfgrenze:
Die Auswertung beschreibt die Zusammensetzung von Verlusten.
Sie beweist nicht, dass eine Kategorie die Verluste verursacht.
*/


-- base: Bestellpositionen im gemeinsamen Business Scope.
WITH base AS (

    SELECT
        od.order_id,
        p.product_category,
        od.order_sales::numeric AS order_sales,
        od.order_profits::numeric AS order_profits

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


-- per_order: Gesamtergebnis jeder Bestellung bestimmen.
per_order AS (

    SELECT
        order_id,
        SUM(order_sales) AS order_revenue,
        SUM(order_profits) AS order_profit,

        COUNT(*) FILTER (
            WHERE order_sales IS NULL
               OR order_profits IS NULL
        ) AS missing_value_count

    FROM base

    GROUP BY
        order_id
),


-- negative_orders: Nur vollständig bewertbare Verlustbestellungen.
negative_orders AS (

    SELECT
        order_id

    FROM per_order

    WHERE order_revenue > 0
      AND order_profit < 0
      AND missing_value_count = 0
),


-- per_category: Positionen der Verlustbestellungen nach Kategorie.
per_category AS (

    SELECT
        b.product_category,
        COUNT(DISTINCT b.order_id) AS negative_order_count,
        SUM(b.order_sales) AS revenue_in_negative_orders,
        SUM(b.order_profits) AS profit_in_negative_orders

    FROM base AS b

    JOIN negative_orders AS n
        ON b.order_id = n.order_id

    GROUP BY
        b.product_category
),


-- contributions: Nettoverlust über alle Kategorien ergänzen.
contributions AS (

    SELECT
        product_category,
        negative_order_count,
        revenue_in_negative_orders,
        profit_in_negative_orders,

        -- Vorzeichen drehen: Verlust wird als positiver Beitrag gezeigt.
        -profit_in_negative_orders AS net_loss_contribution,

        -- Alle Kategorien gemeinsam ergeben den gesamten Nettoverlust
        -- der ausgewählten Bestellungen.
        -SUM(profit_in_negative_orders) OVER () AS total_net_loss

    FROM per_category
)


-- FINAL SELECT: Kategorien nach absolutem Verlustbeitrag sortieren.
SELECT
    product_category,
    negative_order_count,

    ROUND(
        revenue_in_negative_orders,
        2
    ) AS revenue_in_negative_orders,

    ROUND(
        profit_in_negative_orders,
        2
    ) AS profit_in_negative_orders,

    ROUND(
        net_loss_contribution,
        2
    ) AS net_loss_contribution,

    ROUND(
        100.0 * net_loss_contribution
        / NULLIF(total_net_loss, 0),
        2
    ) AS net_loss_contribution_pct

FROM contributions

ORDER BY
    contributions.net_loss_contribution DESC,
    product_category;
/*
Ergebnisprüfung – Q5:

Die Ausgabe enthält drei Zeilen und sechs Spalten.
Die Nettoverlustbeiträge entsprechen jeweils dem
negativen Vorzeichen des ausgewiesenen Kategoriegewinns.

Zusammen ergeben die Kategorien einen Nettoverlust
von 139.992,00 innerhalb der ausgewählten Bestellungen.
Alle drei Prozentanteile wurden nachgerechnet und
summieren sich gerundet auf 100,00 %.

Beobachtung:
Furniture trägt mit 54.975,00 beziehungsweise 39,27 %
den größten Anteil am Nettoverlust.
Office Supplies folgt mit 50.575,00 beziehungsweise
36,13 %, Technology mit 34.442,00 beziehungsweise 24,60 %.

Office Supplies kommt mit 713 Bestellungen am häufigsten
in den ausgewählten Verlustbestellungen vor.
Die höchste Häufigkeit entspricht somit nicht dem
höchsten absoluten Verlustbeitrag.

Prüfgrenze:
Betrachtet werden ausschließlich insgesamt
verlustbringende Bestellungen mit positivem Umsatz
und vollständigen Umsatz- und Gewinnwerten.

Eine Bestellung kann mehrere Kategorien enthalten.
Die Bestellanzahlen dürfen deshalb nicht über
Kategorien hinweg addiert werden.

Die Ergebnisse beschreiben nicht die Gesamtprofitabilität
der Kategorien und belegen keine kausale Rabattwirkung.
Die CSV-Prüfung bestätigt die rechnerische Konsistenz;
Bestellklassifikation, Vollständigkeit und Quelldaten
wurden dabei nicht unabhängig geprüft.
*/

-- ============================================================
-- Q6. Based on the analysis above, what one recommendation
-- would you make to the executive team?
-- ============================================================

/*
Zweck:
Liefert ergänzende Kennzahlen für eine gezielte Prüfung
der Rabatt- und Preisgestaltung bei Furniture.

Ausgangspunkt:
Furniture weist in Q5 den größten Nettoverlustbeitrag
innerhalb insgesamt verlustbringender Bestellungen auf.

Untersuchung:
Furniture-Positionen dieser Bestellungen nach
Rabattstatus aufteilen und Umsatz sowie Gewinn vergleichen.

Grain:
Eine Zeile je vorhandenem Rabattstatus.

Wichtig:
Diese Auswertung ist auf Verlustbestellungen begrenzt.
Sie bewertet weder das gesamte Rabattprogramm noch
die Gesamtprofitabilität von Furniture.

Ein Zusammenhang zwischen Rabattstatus und Gewinn
belegt keine kausale Wirkung von Rabatten.
*/


-- base: Bestellpositionen im gemeinsamen Business Scope.
WITH base AS (

    SELECT
        od.order_id,
        p.product_category,
        od.order_sales::numeric AS order_sales,
        od.order_profits::numeric AS order_profits,
        od.order_discount::numeric AS order_discount

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


-- per_order: Vollständige Bestellungen vor dem Kategoriefilter prüfen.
per_order AS (

    SELECT
        order_id,
        SUM(order_sales) AS order_revenue,
        SUM(order_profits) AS order_profit,

        COUNT(*) FILTER (
            WHERE order_sales IS NULL
               OR order_profits IS NULL
        ) AS missing_value_count

    FROM base

    GROUP BY
        order_id
),


-- negative_orders: Dieselbe Bestelldefinition wie in Q5 verwenden.
negative_orders AS (

    SELECT
        order_id

    FROM per_order

    WHERE order_revenue > 0
      AND order_profit < 0
      AND missing_value_count = 0
),


-- furniture_positions: Furniture erst nach Bestellklassifikation auswählen.
furniture_positions AS (

    SELECT
        b.order_id,
        b.order_sales,
        b.order_profits,

        CASE
            WHEN b.order_discount = 0
                THEN 'No discount'

            WHEN b.order_discount > 0
             AND b.order_discount < 1
                THEN 'Discounted'

            -- Auffällige Rabattwerte sichtbar halten.
            ELSE 'Unknown or invalid'
        END AS discount_status

    FROM base AS b

    JOIN negative_orders AS n
        ON b.order_id = n.order_id

    WHERE b.product_category = 'Furniture'
),


-- per_status: Umsatz und Gewinn je Rabattstatus zusammenfassen.
per_status AS (

    SELECT
        discount_status,
        COUNT(*) AS position_count,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(order_sales) AS revenue,
        SUM(order_profits) AS profit

    FROM furniture_positions

    GROUP BY
        discount_status
)


-- FINAL SELECT: Marge aus Summen berechnen und zuletzt runden.
SELECT
    discount_status,
    position_count,
    order_count,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,

    ROUND(
        100.0 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_pct

FROM per_status

ORDER BY
    CASE discount_status
        WHEN 'Discounted' THEN 1
        WHEN 'No discount' THEN 2
        ELSE 3
    END;

/*
Ergebnisprüfung – Q6:

Die Ausgabe enthält zwei Zeilen und sechs Spalten.
Die beiden Gewinnmargen wurden anhand der exportierten
Umsatz- und Gewinnsummen nachgerechnet und stimmen
auf zwei Nachkommastellen.

Zusammen ergeben die Gruppen 225.526,00 Umsatz und
-54.975,00 Gewinn. Beide Werte stimmen exakt mit
Furniture aus Q5 überein.

Beobachtung:
657 rabattierte Furniture-Positionen erzielen innerhalb
der ausgewählten Verlustbestellungen einen Gewinn
von -55.128,00 bei einer Marge von -24,50 %.

Die zehn nicht rabattierten Positionen erzielen
153,00 Gewinn bei einer Marge von 28,81 %.
Sie gleichen einen kleinen Teil der Verluste aus.

Empfehlung:
Sales und Controlling sollten die Rabatt- und
Preisgestaltung bei Furniture gezielt überprüfen.
Als ersten Schritt sollten sie die rabattierten Positionen
in Verlustbestellungen nach Unterkategorie und Rabatthöhe
analysieren, bevor Änderungen getestet werden.

Prüfgrenze:
Die Auswahl umfasst ausschließlich insgesamt
verlustbringende Bestellungen. Die kleine Gruppe ohne
Rabatt ist keine belastbare Kontrollgruppe.
Eine kausale Rabattwirkung ist damit nicht nachgewiesen.

Bestellungen können in beiden Rabattgruppen vorkommen.
Die Bestellanzahlen dürfen daher nicht addiert werden.

Die Prüfung bestätigt die Konsistenz der Exporte,
nicht einen unabhängigen Abgleich mit den Quelldaten.
*/



