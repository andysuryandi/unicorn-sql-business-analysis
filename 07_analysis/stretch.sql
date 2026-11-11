-- ============================================================
-- UNICORN - STRETCH
-- PATH A: GLEITENDER 3-MONATS-UMSATZDURCHSCHNITT JE REGION
-- ============================================================

/*
Verantwortlich: Suryandi
SQL-Dialekt: PostgreSQL

Zweck:
Vergleicht den monatlichen Umsatz mit einem gleitenden
3-Monats-Durchschnitt, um kurzfristige Schwankungen
und längerfristige Entwicklungen besser zu unterscheiden.

Zeitraum:
Januar 2015 bis Dezember 2018.

Business Scope:
United States; First Class, Same Day,
Second Class und Standard Class.

Aufbau:
base → monthly → regions → calendar
→ monthly_complete → rolling → Final SELECT

Grain:
Eine Zeile je Kalendermonat und Versandregion.

Erwartete Ausgabe:
192 Zeilen = 48 Monate × 4 Regionen.

Umgang mit fehlenden Monaten:
Ein Monat ohne Bestellpositionen im Scope erhält Umsatz 0.
Ein Monat mit fehlenden Umsatzwerten erhält dagegen NULL.
Diese beiden Fälle werden bewusst unterschieden.

Unvollständige Fenster:
Januar 2015 verwendet einen Monat.
Februar 2015 verwendet zwei Monate.
Ab März 2015 umfasst jedes Fenster drei Kalendermonate.
Die ersten beiden Monate bleiben in der Ausgabe erhalten.
*/


-- ============================================================
-- LAYER 1 – BASE
-- Bestellpositionen im definierten Business Scope.
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
          'Standard Class')),


-- ============================================================
-- LAYER 2 – MONTHLY
-- Umsatz je Monat und Region; fehlende Umsatzwerte prüfen.
-- ============================================================

monthly AS (

    SELECT
        DATE_TRUNC('month', order_date)::date AS month_start,
        shipping_region,

        -- Eine unvollständige Monatssumme nicht als vollständig
        -- bekannten Umsatz ausweisen.
        CASE
            WHEN COUNT(*) FILTER (
                WHERE order_sales IS NULL
            ) = 0
            THEN SUM(order_sales)::numeric
            ELSE NULL
        END AS month_revenue

    FROM base

    GROUP BY
        DATE_TRUNC('month', order_date)::date,
        shipping_region),


-- ============================================================
-- LAYER 3 – REGIONS
-- Im Scope vorhandene Versandregionen bestimmen.
-- ============================================================

regions AS (

    SELECT DISTINCT
        shipping_region

    FROM base),


-- ============================================================
-- LAYER 4 – CALENDAR
-- Vollständige Monatsfolge von Januar 2015 bis Dezember 2018.
-- ============================================================

calendar AS (

    SELECT
        month_value::date AS month_start

    FROM GENERATE_SERIES(
        TIMESTAMP '2015-01-01',
        TIMESTAMP '2018-12-01',
        INTERVAL '1 month'
    ) AS months(month_value)),


-- ============================================================
-- LAYER 5 – MONTHLY_COMPLETE
-- Jede Region mit jedem Kalendermonat verbinden.
-- ============================================================

monthly_complete AS (

    SELECT
        cal.month_start,
        r.shipping_region,

        CASE
            -- Kein Aggregat vorhanden: keine Positionen im Scope.
            WHEN m.month_start IS NULL THEN 0::numeric

            -- Vorhandene Aggregate einschließlich NULL erhalten.
            ELSE m.month_revenue
        END AS month_revenue

    FROM calendar AS cal

    CROSS JOIN regions AS r

    LEFT JOIN monthly AS m
        ON cal.month_start = m.month_start
       AND r.shipping_region IS NOT DISTINCT FROM m.shipping_region),


-- ============================================================
-- LAYER 6 – ROLLING
-- Durchschnitt für aktuellen und zwei vorherige Monate.
-- ============================================================

rolling AS (

    SELECT
        month_start,
        shipping_region,
        month_revenue,

        -- Regionen getrennt betrachten.
        -- Dank vollständigem Kalender entsprechen drei Zeilen
        -- drei aufeinanderfolgenden Kalendermonaten.
        AVG(month_revenue) OVER (
            PARTITION BY shipping_region
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_average,

        -- AVG ignoriert NULL. Deshalb zusätzlich prüfen,
        -- ob im Fenster ein unbekannter Monatsumsatz vorkommt.
        COUNT(*) OVER (
            PARTITION BY shipping_region
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS months_in_window,

        COUNT(month_revenue) OVER (
            PARTITION BY shipping_region
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS known_months_in_window

    FROM monthly_complete)


-- ============================================================
-- FINAL SELECT
-- Nur vollständig bekannte Fenster berechnen; zuletzt runden.
-- ============================================================

SELECT
    month_start,
    shipping_region,
    ROUND(month_revenue, 2) AS month_revenue,

    CASE
        WHEN known_months_in_window = months_in_window
        THEN ROUND(rolling_average, 2)
        ELSE NULL
    END AS rolling_3mo_avg

FROM rolling

ORDER BY
    shipping_region,
    month_start;

/*
Ergebnisprüfung und Interpretation – Path A:

Die Ausgabe enthält 192 Zeilen: vier Regionen mit jeweils
48 lückenlosen Monaten von Januar 2015 bis Dezember 2018.
Es gibt keine doppelten Region-Monat-Kombinationen.
Alle 192 gleitenden Durchschnittswerte stimmen auf zwei
Nachkommastellen mit der Nachrechnung aus dem CSV-Export überein.

Januar 2015 berücksichtigt einen Monat, Februar zwei Monate.
Ab März umfasst das Fenster drei aufeinanderfolgende Monate;
der Jahreswechsel setzt es nicht zurück.

In West steigt der gleitende Durchschnitt von 24.808,33
im September 2018 auf 26.571,00 im Dezember, obwohl der
Monatsumsatz im Oktober zurückgeht. Die Glättung macht
die Entwicklung über einzelne Monatsschwankungen hinweg sichtbar.

In East fällt der Monatsumsatz von 44.000,00 im November 2018
auf 20.083,00 im Dezember. Der gleitende Durchschnitt sinkt
moderater von 36.244,33 auf 32.130,67. Er dämpft kurzfristige
Ausschläge, reagiert dadurch aber verzögert auf Veränderungen.

Prüfgrenze:
Geprüft wurde die rechnerische Konsistenz des CSV-Exports,
nicht dessen Übereinstimmung mit den Quelldaten.
Die Glättung erklärt keine Ursachen und ist keine Saisonbereinigung.
*/