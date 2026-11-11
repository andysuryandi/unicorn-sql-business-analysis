-- ============================================================
-- UNICORN – KPI-ZUSAMMENFASSUNG
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die fünf Haupt-KPIs aus drei Teilfragen in einer
gemeinsamen Ergebnistabelle zusammenführen.

Stakeholder-Frage:
Wo sollten wir den Fokus für weiteres Wachstum setzen?

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Berechnungslogik:
KPI 1 und 5: Umsatzwachstum je Gruppe und Jahr.
KPI 2, 3 und 4: Kennzahlen je Gruppe über den Gesamtzeitraum.

UNION ALL verbindet die fünf KPI-Ergebnisse in einer
einheitlichen Tabellenstruktur, ohne Zeilen zu entfernen.

Bei Wachstumsraten fehlt im ersten Jahr der Vorjahreswert.
Bei einem Vorjahresumsatz von null ist das Wachstum NULL.
LAG() entspricht bei lückenloser Jahresfolge
dem Vorjahresvergleich.
*/

WITH region_jahr AS (
    SELECT
        o.shipping_region,
        EXTRACT(YEAR FROM o.order_date)::integer AS jahr,
        SUM(od.order_sales)::numeric AS umsatz
    FROM orders AS o
    JOIN order_details AS od
        ON o.order_id = od.order_id
    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')
    GROUP BY
        o.shipping_region,
        EXTRACT(YEAR FROM o.order_date)),
region_vergleich AS (
    SELECT
        shipping_region, jahr, umsatz,
        LAG(umsatz) OVER (
            PARTITION BY shipping_region ORDER BY jahr
        ) AS umsatz_vorjahr
    FROM region_jahr),
produkt_kpis AS (
    SELECT
        p.product_category,
        SUM(od.order_sales)::numeric AS umsatz,
        SUM(od.order_profits) AS gewinn
    FROM product AS p
    JOIN order_details AS od
        ON p.product_id = od.product_id
    JOIN orders AS o
        ON od.order_id = o.order_id
    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')
    GROUP BY
        p.product_category),
segment_jahr AS (
    SELECT
        c.customer_segment,
        EXTRACT(YEAR FROM o.order_date)::integer AS jahr,
        SUM(od.order_sales)::numeric AS umsatz
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_details AS od
        ON o.order_id = od.order_id
    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'
      )
    GROUP BY
        c.customer_segment,
        EXTRACT(YEAR FROM o.order_date)),
segment_vergleich AS (
    SELECT
        customer_segment, jahr, umsatz,
        LAG(umsatz) OVER (
            PARTITION BY customer_segment ORDER BY jahr
        ) AS umsatz_vorjahr
    FROM segment_jahr),
summary AS (
    -- Teilfrage 1: Regionen
    SELECT
        1 AS teilfrage,
        1 AS kpi_nr,
        'Umsatzwachstum nach Region' AS kpi,
        shipping_region AS gruppe,
        jahr,
        ROUND((umsatz - umsatz_vorjahr)::numeric
            / NULLIF(umsatz_vorjahr, 0) * 100, 2) AS wert,
        '%' AS einheit
    FROM region_vergleich

    UNION ALL

    -- Teilfrage 2: Produktkategorien – Umsatz
    SELECT
        2, 2, 'Umsatz nach Produktkategorie',
        product_category, NULL::integer,
        ROUND(umsatz::numeric, 2),
        'Umsatzeinheit'
    FROM produkt_kpis

    UNION ALL

    -- Teilfrage 2: Produktkategorien – Gewinnmarge
    SELECT
        2, 3, 'Gewinnmarge nach Produktkategorie',
        product_category, NULL::integer,
        ROUND((gewinn / NULLIF(umsatz, 0) * 100)::numeric, 2),
        '%'
    FROM produkt_kpis

    UNION ALL

    -- Teilfrage 3: Kundensegmente – Gesamtumsatz
    SELECT
        3, 4, 'Umsatz nach Kundensegment',
        customer_segment, NULL::integer,
        ROUND(SUM(umsatz)::numeric, 2),
        'Umsatzeinheit'
    FROM segment_jahr
    GROUP BY customer_segment

    UNION ALL

    -- Teilfrage 3: Kundensegmente – Umsatzwachstum
    SELECT
        3, 5, 'Umsatzwachstum nach Kundensegment',
        customer_segment, jahr,
        ROUND((umsatz - umsatz_vorjahr)::numeric
            / NULLIF(umsatz_vorjahr, 0) * 100, 2),
        '%'
    FROM segment_vergleich)

SELECT
    teilfrage, kpi_nr, kpi, gruppe, jahr, wert, einheit
FROM summary
ORDER BY
    kpi_nr, gruppe, jahr;

/*
Ergebnis:

Teilfrage 1 – Regionen:
2018 zeigt West mit 33,37 % das stärkste Umsatzwachstum gegenüber
dem Vorjahr, knapp vor South mit 33,16 %.
Central stagniert 2018 mit einem leichten Rückgang von 0,23 %.
East wächst in allen vergleichbaren Jahren.

Teilfrage 2 – Produktkategorien:
Technology erzielt über den gesamten Zeitraum mit 839.123
den höchsten Umsatz und mit 17,49 % die höchste Gewinnmarge.
Office Supplies erreicht eine ähnlich hohe Marge von 17,16 %.
Furniture weist bei 743.326 Umsatz nur 2,54 % Gewinnmarge auf.
Die Ursachen dieser niedrigen Marge sollten näher untersucht werden.

Teilfrage 3 – Kundensegmente:
Consumer trägt über den gesamten Zeitraum mit 1.168.676
am meisten zum Umsatz bei.
2016 sinkt der Umsatz in allen drei Segmenten.
2017 und 2018 wachsen alle Segmente wieder.
Home Office erzielt 2018 mit 52,67 % das stärkste prozentuale
Wachstum, ausgehend von einer kleineren Umsatzbasis.

Bezug zur Stakeholder-Frage:
West und Home Office bieten aufgrund ihres Wachstums 2018
Ansatzpunkte für eine vertiefende Analyse.
Technology verbindet den höchsten Kategorieumsatz mit der
höchsten Gewinnmarge. Bei Furniture besteht Untersuchungsbedarf
hinsichtlich der niedrigen Profitabilität.
Daraus folgt noch keine direkte Investitionsempfehlung:
Zusätzlich sind Kosten, Kapazitäten und Marktbedingungen zu prüfen.

Prüfung und Hinweise:
Die 37 Ergebniszeilen decken alle fünf KPIs ab und stimmen
mit den zuvor geprüften Einzelergebnissen überein.
Die Umsätze nach Produktkategorie und Kundensegment ergeben
jeweils einen Gesamtumsatz von 2.307.249.
Leere Wachstumswerte für 2015 entstehen durch fehlende Vorjahreswerte.
Ein leeres Jahr kennzeichnet Kennzahlen über den Gesamtzeitraum.
*/