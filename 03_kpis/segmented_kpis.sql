-- ============================================================
-- UNICORN – SEGMENTIERTE KPI-ANALYSE
-- Rabattstufe und Gewinnstatus
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Untersuchen, wie sich Umsatz, Gewinn und Gewinnmarge
nach Rabattstufe und Gewinnstatus unterscheiden.

Die Analyse ergänzt die fünf Haupt-KPIs und liefert
Hinweise für profitables Wachstum.

Stakeholder-Frage:
Wo sollten wir den Fokus für weiteres Wachstum setzen?

Berechnungslogik:
Bestellpositionen werden nach Rabattstufe und Gewinnstatus
gruppiert.

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Rabattstufen:
- Kein Rabatt: 0 %
- Niedriger Rabatt: mehr als 0 % bis einschließlich 20 %
- Hoher Rabatt: mehr als 20 % bis einschließlich 100 %

Die Grenze von 20 % ist eine analytische Festlegung.
NULL-Werte und ungültige Rabatte werden separat ausgewiesen.
*/

WITH kategorisierte_positionen AS (
    SELECT
        od.order_sales,
        od.order_profits,

        CASE
            WHEN od.order_discount IS NULL
                THEN 'Unbekannt'
            WHEN od.order_discount < 0
              OR od.order_discount > 1
                THEN 'Ungueltiger Rabatt'
            WHEN od.order_discount = 0
                THEN 'Kein Rabatt'
            WHEN od.order_discount <= 0.20
                THEN 'Niedriger Rabatt'
            ELSE 'Hoher Rabatt'
        END AS rabattstufe,

        CASE
            WHEN od.order_profits IS NULL
                THEN 'Unbekannt'
            WHEN od.order_profits > 0
                THEN 'Gewinn'
            WHEN od.order_profits < 0
                THEN 'Verlust'
            ELSE 'Gewinn gleich null'
        END AS gewinnstatus

    FROM order_details AS od

    JOIN orders AS o
        ON od.order_id = o.order_id

    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'))

SELECT
    rabattstufe,
    gewinnstatus,
    COUNT(*) AS anzahl_positionen,
    ROUND(SUM(order_sales)::numeric,
        2) AS umsatz,
    ROUND(SUM(order_profits)::numeric,
        2) AS gewinn,
    ROUND((SUM(order_profits)
            / NULLIF(SUM(order_sales), 0) * 100
        )::numeric,2) AS gewinnmarge_prozent

FROM kategorisierte_positionen

GROUP BY
    rabattstufe,
    gewinnstatus

ORDER BY
    CASE rabattstufe
        WHEN 'Kein Rabatt' THEN 1
        WHEN 'Niedriger Rabatt' THEN 2
        WHEN 'Hoher Rabatt' THEN 3
        ELSE 4
    END,
    gewinnstatus;

/*
Ergebnis:
Ohne Rabatt gibt es keine verlustbringenden Bestellpositionen.
4.717 Positionen erzielen Gewinn, 76 weisen einen Gewinn von null auf.

Bei niedrigem Rabatt erzielen 3.219 Positionen Gewinn,
während 517 Positionen Verluste verursachen.
Weitere 75 Positionen weisen einen Gewinn von null auf.

Bei hohem Rabatt sind 1.347 von insgesamt 1.393 Positionen
verlustbringend. Das entspricht rund 96,70 %.
Die Verlustpositionen verursachen einen Verlust von 138.511.
Dem stehen Gewinne von 4.538 gegenüber.
Insgesamt ergibt sich in dieser Rabattstufe ein Verlust von 133.973.

Bezug zur Stakeholder-Frage:
Hohe Rabatte gehen in diesem Datensatz überwiegend mit Verlusten einher.
Für profitables Wachstum sollte daher untersucht werden,
bei welchen Produkten und unter welchen Bedingungen hohe Rabatte
wirtschaftlich sinnvoll sind.

Die Auswertung zeigt einen Zusammenhang, aber keinen Nachweis,
dass Rabatte allein die Verluste verursachen.
*/

-- ============================================================
-- GESCHÄFTSREGEL – ÜBERSICHT NACH RABATTSTUFE
-- ============================================================

/*
Fragestellung:
Wie unterscheiden sich Umsatz, Gewinn und Gewinnmarge
zwischen den Rabattstufen?

Relevanz:
Die Übersicht zeigt, ob die Gewinne innerhalb einer Rabattstufe
die dort auftretenden Verluste ausgleichen.

Geschäftsregel:
Kein Rabatt: 0 %
Niedriger Rabatt: mehr als 0 % bis einschließlich 20 %
Hoher Rabatt: mehr als 20 % bis einschließlich 100 %

Die Grenze von 20 % ist eine analytische Festlegung.
Die Einteilung entspricht der vorherigen Abfrage.
Ausgewertet werden Bestellpositionen innerhalb des
definierten Business Slice.
*/

WITH rabattgruppen AS (
    SELECT
        od.order_sales,
        od.order_profits,
        CASE
            WHEN od.order_discount IS NULL
                THEN 'Unbekannt'
            WHEN od.order_discount < 0
              OR od.order_discount > 1
                THEN 'Ungueltiger Rabatt'
            WHEN od.order_discount = 0
                THEN 'Kein Rabatt'
            WHEN od.order_discount <= 0.20
                THEN 'Niedriger Rabatt'
            ELSE 'Hoher Rabatt'
        END AS rabattstufe
    FROM order_details AS od
    JOIN orders AS o
        ON od.order_id = o.order_id
    WHERE o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class'))
SELECT
    rabattstufe,
    COUNT(*) AS anzahl_positionen,
    ROUND(SUM(order_sales)::numeric, 2) AS umsatz,
    ROUND(SUM(order_profits)::numeric, 2) AS gewinn,
    ROUND((SUM(order_profits)
            / NULLIF(SUM(order_sales), 0) * 100)::numeric,2
    ) AS gewinnmarge_prozent
FROM rabattgruppen
GROUP BY
    rabattstufe
ORDER BY
    CASE rabattstufe
        WHEN 'Kein Rabatt' THEN 1
        WHEN 'Niedriger Rabatt' THEN 2
        WHEN 'Hoher Rabatt' THEN 3
        ELSE 4
    END,
    rabattstufe;
/*
Ergebnis:
Ohne Rabatt erzielen 4.793 Bestellpositionen einen Umsatz
von 1.085.310 und einen Gewinn von 320.074.
Die Gewinnmarge beträgt 29,49 %.

Bei niedrigem Rabatt erzielen 3.811 Positionen einen Umsatz
von 856.045 und einen Gewinn von 103.855.
Die Gewinnmarge beträgt 12,13 %.

Bei hohem Rabatt erzielen 1.393 Positionen einen Umsatz
von 365.894, verursachen jedoch insgesamt einen Verlust
von 133.973. Die Gewinnmarge beträgt -36,62 %.
Die Gewinne einzelner Positionen gleichen die Verluste
innerhalb dieser Rabattstufe somit nicht aus.

Bezug zur Stakeholder-Frage:
Die Rabattstufe mit hohem Rabatt ist ein wichtiger Ansatzpunkt
für die Untersuchung profitablen Wachstums.
Zusätzlicher Umsatz in dieser Gruppe bedeutet nicht automatisch
zusätzlichen Gewinn. Vor einer Ausweitung sollten Produkte,
Kosten und Rabattbedingungen genauer untersucht werden.

Die Ergebnisse beschreiben einen Zusammenhang.
Sie belegen nicht, dass Rabatte allein die Verluste verursachen.

Prüfung:
Anzahl, Umsatz und Gewinn je Rabattstufe stimmen mit den
zusammengefassten Werten der ersten Auswertung überein.
Der Gesamtumsatz über alle Rabattstufen beträgt 2.307.249.
*/