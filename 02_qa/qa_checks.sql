-- ============================================================
-- UNICORN – DATENQUALITÄTSPRÜFUNGEN
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die Datenqualität der vier Unicorn-Tabellen systematisch
prüfen und mögliche Auffälligkeiten dokumentieren.

Tabellen:
- customers
- orders
- order_details
- product

Prüfumfang:
- Zeilenanzahl und Eindeutigkeit der IDs
- Fehlende und leere Werte
- Kategorien und Wertebereiche
- Zeitliche und numerische Plausibilität
- Beziehungen zwischen den Tabellen
- Weitere Datenauffälligkeiten

Dokumentation:
Die Ergebnisse, Auffälligkeiten und Einschränkungen
werden in qa_findings.md zusammengefasst.
*/

-- =====================================================
-- 1. QA CHECKS – CUSTOMERS
-- =====================================================

-- 1.1 Anzahl der Kunden prüfen
SELECT COUNT(*) AS total_customers
FROM customers;

/*
Ergebnis:
Die Tabelle customers enthält 795 Zeilen.

Interpretation:
Laut Datenmodell steht eine Zeile für einen Kunden.
Die Anzahl dient als Ausgangspunkt für die weiteren QA-Prüfungen.
*/

-- 1.2 Kunden-IDs auf Eindeutigkeit prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM customers;

/*
Ergebnis:
Die Tabelle customers enthält 795 Zeilen
und 795 verschiedene customer_id-Werte.

Interpretation:
Da die Anzahl der Zeilen und der eindeutigen customer_id-Werte
gleich ist, kommt keine customer_id doppelt vor.
Die customer_id ist damit eindeutig.
*/

-- 1.3 Fehlende Werte in wichtigen Kundenfeldern prüfen
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR TRIM(customer_name) = ''
   OR customer_segment IS NULL
   OR TRIM(customer_segment) = '';

 /*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
In den geprüften Feldern customer_id, customer_name
und customer_segment wurden keine fehlenden Werte gefunden.

Auch customer_name und customer_segment enthalten
keine leeren oder nur aus Leerzeichen bestehenden Werte.

Datenqualität:
Für die geprüften Kundenfelder wurde kein Problem festgestellt.
*/

-- 1.4 Vorhandene Kundensegmente prüfen
SELECT DISTINCT customer_segment
FROM customers
ORDER BY customer_segment;

/*
Ergebnis:
Es gibt drei Kundensegmente:
- Consumer
- Corporate
- Home Office

Interpretation:
Die Segmentwerte sind einheitlich geschrieben
und es wurden keine auffälligen oder zusätzlichen
Kategorien gefunden.

Datenqualität:
Für customer_segment wurde bei dieser Prüfung
kein Datenproblem festgestellt.
*/

-- =====================================================
-- 2. QA CHECKS – ORDERS
-- =====================================================

-- 2.1 Anzahl der Bestellungen prüfen
SELECT COUNT(*) AS total_orders
FROM orders;

/*
Ergebnis:
Die Tabelle orders enthält 5.013 Zeilen.

Interpretation:
Laut Datenmodell steht eine Zeile für eine Bestellung.
Die Anzahl dient als Ausgangspunkt für die weiteren QA-Prüfungen.
*/

-- 2.2 Bestell-IDs auf Eindeutigkeit prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids
FROM orders;

/*
Ergebnis:
Die Tabelle orders enthält 5.013 Zeilen
und 5.013 verschiedene order_id-Werte.

Interpretation:
Da die Anzahl der Zeilen und der eindeutigen order_id-Werte
gleich ist, kommt keine order_id doppelt vor.
Die order_id ist damit eindeutig.

Datenqualität:
Bei der Prüfung auf doppelte Bestell-IDs
wurde kein Problem festgestellt.
*/

-- 2.3 Fehlende Werte in wichtigen Bestellfeldern prüfen
SELECT *
FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL
   OR shipping_city IS NULL
   OR shipping_state IS NULL
   OR shipping_region IS NULL
   OR shipping_country IS NULL
   OR shipping_postal_code IS NULL
   OR shipping_date IS NULL
   OR shipping_mode IS NULL;

/*
Ergebnis:
Die Abfrage liefert 6 Bestellungen mit fehlenden Werten.

Bei allen 6 Bestellungen fehlt nur die Postleitzahl
(shipping_postal_code).

Alle 6 Bestellungen betreffen Burlington, Vermont.
In den anderen geprüften Feldern wurden keine NULL-Werte gefunden.

Interpretation:
Die Tabelle orders ist weitgehend vollständig.
Die einzige gefundene Datenlücke betrifft
shipping_postal_code bei 6 Bestellungen.

Datenqualität:
Die 6 Bestellungen können weiterhin über Stadt,
Bundesstaat und Region analysiert werden.
Eine Analyse auf Postleitzahl-Ebene ist für diese
Bestellungen jedoch nicht vollständig möglich.
*/

-- 2.4 Vorhandene Versandländer prüfen
SELECT DISTINCT shipping_country
FROM orders
ORDER BY shipping_country;

/*
Ergebnis:
Es gibt nur ein Versandland:
- United States

Interpretation:
Alle Bestellungen im Datensatz stammen aus den United States.
Es wurden keine weiteren Versandländer gefunden.

Datenqualität:
Für shipping_country wurde bei dieser Prüfung
kein Datenproblem festgestellt.
*/

-- 2.5 Vorhandene Versandarten prüfen
SELECT DISTINCT shipping_mode
FROM orders
ORDER BY shipping_mode;

/*
Ergebnis:
Es gibt vier Versandarten:
- First Class
- Same Day
- Second Class
- Standard Class

Interpretation:
Die Versandarten sind einheitlich geschrieben
und es wurden keine zusätzlichen oder offensichtlich
ungültigen Werte gefunden.

Datenqualität:
Für shipping_mode wurde bei dieser Prüfung
kein Datenproblem festgestellt.
*/

-- 2.6 Datumsbereich der Bestellungen prüfen
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) FILTER (
        WHERE order_date < DATE '2015-01-01'
           OR order_date >= DATE '2019-01-01'
    ) AS orders_outside_date_range
FROM orders;

/*
Ergebnis:
Die Bestellungen reichen vom 03.01.2015
bis zum 30.12.2018.

Es wurden 0 Bestellungen außerhalb
des Zeitraums 2015–2018 gefunden.

Interpretation:
Der vorhandene Datumsbereich entspricht dem
festgelegten Analysezeitraum 2015–2018.

Datenqualität:
Es wurden keine Bestellungen außerhalb des
erwarteten Zeitraums festgestellt.
*/

-- 2.7 Auffällige Postleitzahlen prüfen
SELECT
    order_id,
    shipping_city,
    shipping_state,
    shipping_postal_code,
    LENGTH(shipping_postal_code::text) AS postal_code_length
FROM orders
WHERE shipping_postal_code IS NULL
   OR LENGTH(shipping_postal_code::text) <> 5
ORDER BY shipping_state, shipping_city;

/*
Ergebnis:
Die Abfrage findet insgesamt 219 Bestellungen
mit fehlenden oder vierstelligen Postleitzahlen.

Davon enthalten 213 Bestellungen eine
vierstellige shipping_postal_code.

Bei weiteren 6 Bestellungen fehlt
die Postleitzahl vollständig (NULL).

Interpretation:
Die vierstelligen Postleitzahlen könnten darauf
hinweisen, dass führende Nullen bei der Speicherung
verloren gegangen sind.

Ob dies tatsächlich der Fall ist, lässt sich
anhand dieser Prüfung allein nicht bestätigen.

Datenqualität:
Die betroffenen Bestellungen bleiben erhalten.

Analysen auf Postleitzahl-Ebene können dadurch
eingeschränkt oder fehlerhaft sein.

Die ursprünglichen Werte werden nicht verändert.
*/

-- 2.8 Beziehung orders → customers prüfen
SELECT DISTINCT o.customer_id
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Alle customer_id-Werte aus orders sind auch
in der Tabelle customers vorhanden.

Damit kann jede Bestellung einem vorhandenen
Kunden zugeordnet werden.

Datenqualität:
Die Beziehung orders → customers ist vollständig.
Bei dieser Prüfung wurde kein Problem festgestellt.
*/

-- 2.9 Kunden ohne Bestellung prüfen
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

/*
Ergebnis:
Die Abfrage findet 2 Kunden ohne Bestellung.

Interpretation:
Die Tabelle customers enthält Kunden,
für die im vorhandenen Datensatz keine Bestellung vorliegt.

Das ist nicht automatisch ein Datenfehler,
sollte aber bei späteren Kundenanalysen berücksichtigt werden.

Datenqualität:
Kundenanalysen können unterschiedliche Ergebnisse liefern,
je nachdem, ob Kunden ohne Bestellung einbezogen werden.
*/

-- =====================================================
-- 3. QA CHECKS – ORDER_DETAILS
-- =====================================================

-- 3.1 Anzahl der Bestellpositionen prüfen
SELECT COUNT(*) AS total_order_details
FROM order_details;

/*
Ergebnis:
Die Tabelle order_details enthält 9.997 Zeilen.

Interpretation:
Eine Zeile entspricht einer Bestellposition,
also einem Produkt innerhalb einer Bestellung.

Die Anzahl dient als Ausgangspunkt
für die weiteren QA-Prüfungen.
*/

-- 3.2 Bestellpositions-IDs auf Eindeutigkeit prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_details_id) AS unique_order_detail_ids
FROM order_details;

/*
Ergebnis:
Die Tabelle order_details enthält 9.997 Zeilen
und 9.997 verschiedene order_details_id-Werte.

Interpretation:
Da die Anzahl der Zeilen und der eindeutigen
order_details_id-Werte gleich ist,
kommt keine order_details_id doppelt vor.

Die order_details_id ist damit eindeutig.

Datenqualität:
Bei der Prüfung auf doppelte Bestellpositions-IDs
wurde kein Problem festgestellt.
*/

-- 3.3 Fehlende Werte in wichtigen Bestellpositionsfeldern prüfen
SELECT *
FROM order_details
WHERE order_details_id IS NULL
   OR order_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR order_discount IS NULL
   OR order_sales IS NULL
   OR order_profits IS NULL
   OR order_profit_ratio IS NULL;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
In den geprüften Feldern wurden keine fehlenden Werte gefunden.
Alle Bestellpositionen sind in diesen Spalten vollständig ausgefüllt.

Datenqualität:
Bei der Prüfung auf fehlende Werte wurde
kein Datenproblem festgestellt.
*/

-- 3.4 Mengen und Rabatte auf ungültige Werte prüfen
SELECT *
FROM order_details
WHERE quantity <= 0
   OR order_discount < 0
   OR order_discount > 1;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Alle Mengen sind größer als 0.
Die Rabatte liegen im erwarteten Bereich
zwischen 0 und 1.

Datenqualität:
Bei dieser Prüfung wurden keine ungültigen
Mengen oder Rabattwerte gefunden.
*/

-- 3.5 Negative Gewinne prüfen
SELECT COUNT(*) AS negative_profit_rows
FROM order_details
WHERE order_profits < 0;

/*
Ergebnis:
Die Abfrage findet 1.864 Bestellpositionen
mit negativem Gewinn.

Das entspricht rund 18,65 % aller
9.997 Bestellpositionen.

Interpretation:
Ein negativer Gewinn bedeutet, dass bei diesen
Bestellpositionen ein Verlust entstanden ist.

Negative Gewinne sind nicht automatisch ein Datenfehler.
Sie sind jedoch für die spätere Profitabilitätsanalyse
besonders relevant.

Datenqualität:
Die negativen Gewinne werden nicht verändert oder entfernt.
Sie werden als wichtiges Finding für die weitere Analyse
dokumentiert.
*/

-- 3.6 Beziehung order_details → orders prüfen
SELECT DISTINCT od.order_id
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Alle order_id-Werte aus order_details sind auch
in der Tabelle orders vorhanden.

Damit kann jede Bestellposition einer vorhandenen
Bestellung zugeordnet werden.

Datenqualität:
Die Beziehung order_details → orders ist vollständig.
Bei dieser Prüfung wurde kein Problem festgestellt.
*/

-- 3.7 Beziehung order_details → product prüfen
SELECT DISTINCT od.product_id
FROM order_details AS od
LEFT JOIN product AS p
    ON od.product_id = p.product_id
WHERE p.product_id IS NULL;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Alle product_id-Werte aus order_details sind auch
in der Tabelle product vorhanden.

Damit kann jede Bestellposition einem vorhandenen
Produkt zugeordnet werden.

Datenqualität:
Die Beziehung order_details → product ist vollständig.
Bei dieser Prüfung wurde kein Problem festgestellt.
*/

-- 3.8 Doppelte Kombinationen aus order_id und product_id prüfen
SELECT
    order_id,
    product_id,
    COUNT(*) AS anzahl
FROM order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Jede Kombination aus order_id und product_id
kommt nur einmal in order_details vor.

Das entspricht dem erwarteten Grain der Tabelle:
Eine Zeile steht für ein Produkt innerhalb einer Bestellung.

Datenqualität:
Bei dieser Prüfung wurden keine doppelten Kombinationen
aus Bestellung und Produkt gefunden.
*/

-- =====================================================
-- 4. QA CHECKS – PRODUCT
-- =====================================================

-- 4.1 Anzahl der Produkte prüfen
SELECT COUNT(*) AS total_products
FROM product;

/*
Ergebnis:
Die Tabelle product enthält 1.850 Zeilen.

Interpretation:
Eine Zeile entspricht einem Produkt.

Die Anzahl dient als Ausgangspunkt
für die weiteren QA-Prüfungen.
*/

-- 4.2 Produkt-IDs auf Eindeutigkeit prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM product;

/*
Ergebnis:
Die Tabelle product enthält 1.850 Zeilen
und 1.850 verschiedene product_id-Werte.

Interpretation:
Da die Anzahl der Zeilen und der eindeutigen
product_id-Werte gleich ist,
kommt keine product_id doppelt vor.

Die product_id ist damit eindeutig.

Datenqualität:
Bei der Prüfung auf doppelte Produkt-IDs
wurde kein Problem festgestellt.
*/

-- 4.3 Fehlende Werte in wichtigen Produktfeldern prüfen
SELECT *
FROM product
WHERE product_id IS NULL
   OR product_name IS NULL
   OR TRIM(product_name) = ''
   OR product_category IS NULL
   OR TRIM(product_category) = ''
   OR product_subcategory IS NULL
   OR TRIM(product_subcategory) = ''
   OR product_manufacturer IS NULL
   OR TRIM(product_manufacturer) = '';

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
In den geprüften Produktfeldern wurden keine
NULL-Werte oder leeren Textfelder gefunden.

Datenqualität:
Die geprüften Produktdaten sind vollständig ausgefüllt.
Bei dieser Prüfung wurde kein Datenproblem festgestellt.
*/

-- 4.4 Vorhandene Produktkategorien prüfen
SELECT DISTINCT product_category
FROM product
ORDER BY product_category;

/*
Ergebnis:
Es gibt drei Produktkategorien:
- Furniture
- Office Supplies
- Technology

Interpretation:
Die Kategorien sind einheitlich geschrieben
und es wurden keine zusätzlichen oder offensichtlich
ungültigen Kategorien gefunden.

Datenqualität:
Für product_category wurde bei dieser Prüfung
kein Datenproblem festgestellt.
*/

-- 4.5 Herstellerwert "Other" prüfen
SELECT COUNT(*) AS other_manufacturer_rows
FROM product
WHERE product_manufacturer = 'Other';

/*
Ergebnis:
Die Abfrage findet 356 Produkte
mit dem Herstellerwert "Other".

Interpretation:
Der Wert "Other" ist kein fehlender Wert,
nennt jedoch keinen konkreten Hersteller.

Dadurch können spätere Analysen nach Hersteller
weniger genau sein.

Datenqualität:
Der Wert "Other" wird nicht verändert oder entfernt.
Er wird als relevantes Finding für die weitere Analyse
dokumentiert.
*/

-- 4.6 Anzahl der Unterkategorien und Herstellerwerte prüfen
SELECT
    COUNT(DISTINCT product_subcategory) AS unique_subcategories,
    COUNT(DISTINCT product_manufacturer) AS unique_manufacturers
FROM product;

/*
Ergebnis:
Es gibt 17 verschiedene Produkt-Unterkategorien
und 183 verschiedene Herstellerwerte.

Interpretation:
Die Produktdaten enthalten mehrere Unterkategorien
und Herstellerwerte, die für spätere Vergleiche
verwendet werden können.

Dabei ist zu beachten, dass der Herstellerwert "Other"
in den 183 Herstellerwerten enthalten ist.

Datenqualität:
Die Anzahl der unterschiedlichen Werte ist plausibel.
Bei dieser Prüfung wurde kein zusätzliches Datenproblem festgestellt.
*/