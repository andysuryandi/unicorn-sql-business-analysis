-- ============================================================
-- UNICORN – KPI-ANALYSE
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die Stakeholder-Frage „Wo sollten wir den Fokus für
weiteres Wachstum setzen?“ 

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Teilfragen:
1. Welche Regionen wachsen beim Umsatz am stärksten,
   und welche stagnieren?
2. Welche Produktkategorien erzielen den höchsten Umsatz
   und welche die höchste Gewinnmarge?
3. Welche Kundensegmente tragen am meisten zum Umsatz bei,
   und gibt es Segmente, die schrumpfen?
*/

-- Jede der drei Teilfragen beleuchtet einen anderen Ansatzpunkt für Wachstum.

/*
Teilfrage 1: Der Vergleich zeigt, in welchen Regionen sich der Umsatz 
positiv entwickelt und wo Wachstum ausbleibt. 
Damit liefert er eine Grundlage, um regionale Wachstumsmöglichkeiten 
und Bereiche mit weiterem Untersuchungsbedarf zu erkennen.

Teilfrage 2: Die gemeinsame Betrachtung von Umsatz und Gewinnmarge zeigt, 
welche Produktkategorien hohe Erlöse erzielen und wie profitabel diese sind. 
Das ist relevant, weil zusätzlicher Umsatz nicht automatisch einen hohen Gewinn bedeutet. 
Die Ergebnisse helfen dabei, den Fokus auf profitables Wachstum zu richten.

Teilfrage 3: Diese Teilfrage zeigt, welche Kundensegmente das Geschäft besonders stark tragen 
und wie sich ihre Umsätze entwickeln. Dadurch lassen sich wachsende Segmente 
sowie mögliche Umsatzrisiken erkennen. Die Ergebnisse bieten Ansatzpunkte 
für eine gezieltere Kundenansprache und Kundenbindung.

Zusammen liefern die drei Teilfragen eine nachvollziehbare Datengrundlage dafür, 
wo Wachstum stattfindet, wie profitabel die Produktkategorien sind 
und welche Kundensegmente zum Wachstum beitragen. 

Für konkrete Investitionsentscheidungen müssen zusätzlich 
beispielsweise Kosten, Kapazitäten und Marktbedingungen berücksichtigt werden.
*/

/* Teilfrage 1:
Welche Regionen wachsen beim Umsatz am stärksten, und welche stagnieren?
*/

-- ============================================================
-- KPI 1: Umsatzwachstum nach Region
-- ============================================================

/*
Berechnungslogik:
orders und order_details werden über order_id verbunden.
Der Umsatz wird je Region und Jahr summiert und mit LAG() mit dem
vorherigen verfügbaren Jahr derselben Region verglichen.
Bei lückenloser Jahresfolge entspricht dies dem Vorjahresvergleich.
Im ersten verfügbaren Jahr ist das Wachstum NULL, da der Vergleich fehlt.
Bei einem Vorjahresumsatz von 0 verhindert NULLIF eine Division
durch null; das Wachstum wird dann als NULL ausgegeben.
*/

WITH jahresumsatz AS (
    SELECT
        o.shipping_region,
        EXTRACT(YEAR FROM o.order_date) AS jahr,
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
        EXTRACT(YEAR FROM o.order_date))
SELECT
    shipping_region,
    jahr,
    umsatz,
    ROUND((umsatz / NULLIF(
            LAG(umsatz) OVER (
                PARTITION BY shipping_region
                ORDER BY jahr), 0
        ) - 1) * 100,2) AS umsatzwachstum_prozent
FROM jahresumsatz
ORDER BY
    shipping_region,
    jahr;

/*
Ergebnis:
East zeigt in allen vergleichbaren Jahren ein positives Umsatzwachstum.
West erreicht 2018 ein Umsatzwachstum von 33,37 %.
South verzeichnet 2016 einen Rückgang von 31,41 %,
gefolgt von Wachstum in den Jahren 2017 und 2018.
Central verzeichnet 2018 einen leichten Rückgang von 0,23 %.

Interpretation:
West weist 2018 das stärkste Umsatzwachstum gegenüber
dem Vorjahr auf und ist damit eine interessante Region
für weitere Wachstumsanalysen.

Central zeigt 2018 eine nahezu stagnierende Umsatzentwicklung.
Hier sollte untersucht werden, welche Faktoren das
Wachstum begrenzen.

Einschränkung:
Das prozentuale Umsatzwachstum allein reicht nicht aus,
um eine Investitionsentscheidung zu treffen.
Dafür müssen auch Umsatzhöhe, Profitabilität
und weitere wirtschaftliche Faktoren berücksichtigt werden.
*/

/*
Teilfrage 2:
Welche Produktkategorien erzielen den höchsten Umsatz und welche die höchste Gewinnmarge?
*/

-- ============================================================
-- KPI 2: Umsatz nach Produktkategorie
-- ============================================================

/*
Berechnungslogik:
product und order_details werden über product_id verbunden.
Der Umsatz wird je Produktkategorie über den gesamten verfügbaren
Zeitraum summiert. Die Ausgabe ist nach Umsatz absteigend sortiert.
*/

SELECT
    p.product_category,
    ROUND(SUM(od.order_sales)::numeric, 2) AS umsatz
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
    p.product_category
ORDER BY
    umsatz DESC;

/*
Ergebnis:
Technology erzielt mit rund 839.123 den höchsten Umsatz.
Furniture folgt mit rund 743.326.

Interpretation:
Technology ist die umsatzstärkste Produktkategorie
und damit ein möglicher Ansatzpunkt für weiteres Wachstum.

Ein hoher Umsatz bedeutet jedoch nicht automatisch
eine hohe Profitabilität.
*/

-- ============================================================
-- KPI 3: Gewinnmarge nach Produktkategorie
-- ============================================================

/*
Berechnungslogik:
product und order_details werden über product_id verbunden.
Die Gewinnmarge ist SUM(Gewinn) / SUM(Umsatz) * 100 je Produktkategorie
über den gesamten verfügbaren Zeitraum, kein Mittelwert einzelner Margen.
NULLIF verhindert eine Division durch null; bei Umsatz null ist die Marge NULL.
Die Ausgabe ist nach Gewinnmarge absteigend sortiert, NULL-Werte zuletzt.
*/

SELECT
    p.product_category,
    ROUND((SUM(od.order_profits)
            / NULLIF(SUM(od.order_sales), 0) * 100
        )::numeric,2) AS gewinnmarge_prozent
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
    p.product_category
ORDER BY
    gewinnmarge_prozent DESC NULLS LAST;

/*
Ergebnis:
Technology erreicht mit 17,49 % die höchste Gewinnmarge.
Office Supplies folgt mit 17,16 %.
Furniture weist mit 2,54 % eine deutlich niedrigere
Gewinnmarge auf.

Interpretation:
Technology liegt sowohl beim Umsatz als auch
bei der Gewinnmarge vorn.

Furniture erzielt zwar einen hohen Umsatz,
weist jedoch eine vergleichsweise niedrige Gewinnmarge auf.

Damit erscheint Technology als interessanter Ansatzpunkt
für profitables Wachstum.

Einschränkung:
Die Ursachen der niedrigen Gewinnmarge bei Furniture
lassen sich aus diesem Vergleich allein nicht bestimmen.
Dafür sind weitere Analysen erforderlich.
*/

/*
Teilfrage 3:
Welche Kundensegmente tragen am meisten zum Umsatz bei, und gibt es Segmente, die schrumpfen?
*/

-- ============================================================
-- KPI 4: Umsatz nach Kundensegment
-- ============================================================

/*
Berechnungslogik:
customers enthält das Kundensegment.
Über orders werden die Kunden mit ihren Bestellpositionen
in order_details verbunden.

Der Umsatz wird je Kundensegment innerhalb des definierten
Business Slice summiert.
Die Ausgabe ist nach Umsatz absteigend sortiert.
*/

SELECT
    c.customer_segment,
    ROUND(SUM(od.order_sales)::numeric, 2) AS umsatz
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
      'Standard Class')
GROUP BY
    c.customer_segment
ORDER BY
    umsatz DESC;

/*
Ergebnis:
Consumer erzielt mit rund 1.168.676 den höchsten Umsatz.
Corporate folgt mit rund 707.561.
Home Office erreicht rund 431.012.

Interpretation:
Consumer ist das umsatzstärkste Kundensegment
und trägt am meisten zum Gesamtumsatz bei.

Die Gesamtumsätze allein zeigen jedoch nicht,
ob die einzelnen Kundensegmente wachsen oder schrumpfen.

Einschränkung:
Aus der Umsatzhöhe lässt sich nicht unmittelbar
auf die Profitabilität eines Kundensegments schließen.
*/

-- ============================================================
-- KPI 5: Umsatzwachstum nach Kundensegment
-- ============================================================

/*
Berechnungslogik:
customers, orders und order_details werden über customer_id
und order_id verbunden.

Der Umsatz wird je Kundensegment und Jahr innerhalb
des definierten Business Slice summiert.
LAG() liefert den Umsatz des vorherigen verfügbaren Jahres.
Bei lückenloser Jahresfolge entspricht dies dem Vorjahresumsatz.

Das Wachstum wird als prozentuale Veränderung berechnet.
Im ersten Jahr fehlt der Vergleichswert; das Wachstum ist NULL.
Bei einem Vorjahresumsatz von null ist es ebenfalls NULL.
*/

WITH jahresumsatz AS (
    SELECT
        c.customer_segment,
        EXTRACT(YEAR FROM o.order_date) AS jahr,
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
          'Standard Class')
    GROUP BY
        c.customer_segment,
        EXTRACT(YEAR FROM o.order_date)),
vorjahresvergleich AS (
    SELECT
        customer_segment,
        jahr,
        umsatz,
        LAG(umsatz) OVER (
            PARTITION BY customer_segment
            ORDER BY jahr
        ) AS umsatz_vorjahr
    FROM jahresumsatz)
SELECT
    customer_segment,
    jahr,
    umsatz,
    ROUND((umsatz - umsatz_vorjahr)::numeric
        / NULLIF(umsatz_vorjahr, 0) * 100,
        2) AS umsatzwachstum_prozent
FROM vorjahresvergleich
ORDER BY
    customer_segment,
    jahr;

/*
Ergebnis:
2016 verzeichnen alle drei Kundensegmente einen Umsatzrückgang.
Home Office ist mit -18,33 % am stärksten betroffen.
Consumer sinkt um 2,70 %, Corporate um 2,05 %.

2017 und 2018 wachsen alle drei Segmente.
Corporate erreicht 2017 mit 60,86 % das höchste Wachstum.
2018 wächst Home Office mit 52,67 % am stärksten,
gefolgt von Corporate mit 15,99 % und Consumer mit 11,98 %.

Im ersten Jahr 2015 ist das Umsatzwachstum NULL,
da kein Vorjahreswert vorhanden ist.

Interpretation:
Consumer trägt über den gesamten Zeitraum
am meisten zum Umsatz bei.

Home Office zeigt 2018 das stärkste prozentuale Wachstum,
allerdings ausgehend von einer kleineren Umsatzbasis.

Keines der drei Kundensegmente schrumpft im Jahr 2018.

Einschränkung:
Das hohe prozentuale Wachstum von Home Office
bedeutet nicht automatisch den größten absoluten
Umsatzzuwachs oder die höchste Profitabilität.

Für konkrete Wachstumsentscheidungen sind weitere
Analysen zu Gewinn, Kosten und Marktpotenzial erforderlich.
*/