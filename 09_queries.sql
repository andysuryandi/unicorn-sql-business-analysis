-- UNICORN | Suryandi | SQL-Sammeldatei
-- Grundlage: die vorhandenen Hauptdateien des Projektarchivs.
-- Voraussetzung: customers, orders, order_details und product sind geladen
-- und ueber den aktuellen search_path erreichbar.
-- Jeder Abschnitt enthaelt eigenstaendige Abfragen; CTEs gelten je Anweisung.
-- Regionale Parameterkopien sind nicht zusaetzlich enthalten.
-- Quellenkommentare beziehen sich auf Pfade relativ zum Projekt-Hauptordner.
-- In den beiden KPI-Dateien werden Umsatzsummen vor Wachstumsberechnungen
-- explizit zu numeric konvertiert. Fachliche Filter und KPI-Definitionen bleiben erhalten.
-- Ergebnisnotizen stammen aus den Quelldateien und dokumentieren deren Datenstand.

-- ============================================================
-- QUELLE: 01_audit/exploration.sql
-- ============================================================
-- ============================================================
-- UNICORN – EXPLORATION
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19
Zeitraum: 2015–2018

Ziel:
Die Daten explorativ untersuchen und erste Muster zu
Kundensegmenten, Bestellungen, Verkaufswerten,
Produktkategorien und Kundenaktivität erkennen.

Q1: Welche unterschiedlichen Kundensegmente gibt es?
Q2: Wie viele Bestellungen gibt es pro Versandregion?
Q3: Was sind die 10 höchsten einzelnen Verkaufswerte?
Q4: Wie viele Produkte gibt es pro Produktkategorie?
Q5: Welche Kunden haben die meisten Bestellungen?
*/

-- ============================================================
-- Q1: Welche unterschiedlichen Kundensegmente gibt es?
-- ============================================================

SELECT DISTINCT
    customer_segment
FROM customers
ORDER BY customer_segment;

-- Ergebnis:
-- Es gibt 3 Kundensegmente:
-- Consumer, Corporate und Home Office.

-- ============================================================
-- Q2: Wie viele Bestellungen gibt es pro Versandregion?
-- ============================================================

SELECT
    shipping_region,
    COUNT(*) AS anzahl_bestellungen
FROM orders
GROUP BY shipping_region
ORDER BY anzahl_bestellungen DESC;

-- Ergebnis:
-- West hat mit 1611 die meisten Bestellungen.
-- South hat mit 822 die wenigsten Bestellungen.

-- ============================================================
-- Q3: Was sind die 10 höchsten einzelnen Verkaufswerte?
-- ============================================================

SELECT
    order_details_id,
    order_id,
    product_id,
    order_sales
FROM order_details
ORDER BY order_sales DESC
LIMIT 10;

-- Ergebnis:
-- Der höchste einzelne Verkaufswert beträgt 22638.
-- Die Abfrage zeigt die 10 höchsten einzelnen Verkaufswerte.

-- ============================================================
-- Q4: Wie viele Produkte gibt es pro Produktkategorie?
-- ============================================================

SELECT
    product_category,
    COUNT(*) AS anzahl_produkte
FROM product
GROUP BY product_category
ORDER BY anzahl_produkte DESC;

-- Ergebnis:
-- Office Supplies hat mit 1058 die meisten Produkte.
-- Furniture hat mit 380 die wenigsten Produkte.

-- ============================================================
-- Q5: Welche Kunden haben die meisten Bestellungen?
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS anzahl_bestellungen
FROM orders
GROUP BY customer_id
ORDER BY anzahl_bestellungen DESC
LIMIT 10;

-- Ergebnis:
-- Customer ID 260 hat mit 17 die meisten Bestellungen.
-- Die Abfrage zeigt die 10 Kunden mit den meisten Bestellungen.

-- ============================================================
-- QUELLE: 01_audit/data_check.sql
-- ============================================================
-- ============================================================
-- UNICORN – DATENÜBERBLICK UND DATENQUALITÄT
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19
Zeitraum: 2015–2018

Ziel:
Die vier Tabellen customers, orders, order_details und product
untersuchen sowie ihre Struktur, Beziehungen und
Datenqualität prüfen.
*/

-- ============================================================
-- 1. CUSTOMERS – DATENÜBERBLICK UND DATENQUALITÄT
-- ============================================================

/*
Ziel: Die Kundendaten kennenlernen und ihre Qualität prüfen.

Schritt 1: Anzahl der Kundenzeilen zählen
Schritt 2: Zehn Kundenzeilen ansehen
Schritt 3: Kunden-IDs und Anzahl der Segmente prüfen
Schritt 4: Fehlende Werte prüfen
Schritt 5: Zusammenfassung customers
*/

-- Schritt 1: Anzahl der Kundenzeilen zählen
SELECT COUNT(*) AS total_rows
FROM customers;

/* Ergebnis: Die Tabelle customers enthält 795 Zeilen.
Laut ER-Diagramm entspricht eine Zeile in customers einem Kunden.
Ob alle customer_id-Werte eindeutig sind, wird noch geprüft.
*/

-- Schritt 2: Zehn Kundenzeilen ansehen
SELECT *
FROM customers
ORDER BY customer_id
LIMIT 10;

/*
Beobachtung:
Die angezeigten Kunden-IDs reichen von 1 bis 10.
Kundennamen und Kundensegmente sind in allen zehn Zeilen vorhanden.
Die Segmente Consumer, Corporate und Home Office kommen vor.
In diesen zehn Zeilen sind keine offensichtlichen
Datenqualitätsprobleme zu erkennen.

Eine Prüfung der gesamten Tabelle folgt in Schritt 3.
*/

-- Schritt 3: Kunden-IDs und Anzahl der Segmente prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_ids,
    COUNT(DISTINCT customer_segment) AS unique_segments
FROM customers;
/*
Ergebnis:
Die Tabelle hat 795 Zeilen und 795 verschiedene Kunden-IDs.
Damit kommt keine customer_id doppelt vor.

Es gibt drei verschiedene Kundensegmente.

Ob customer_id oder andere Kundenfelder fehlende Werte enthalten,
wird in Schritt 4 separat geprüft.
*/

-- Schritt 4: Fehlende Werte prüfen
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
In customer_id, customer_name und customer_segment
wurden keine NULL-Werte gefunden.

Die Textfelder customer_name und customer_segment enthalten
auch keine leeren oder nur aus Leerzeichen bestehenden Werte.

Interpretation:
Die geprüften Kundendaten sind hinsichtlich fehlender Werte vollständig.

Datenqualität:
Für die geprüften Felder ist keine Bereinigung
fehlender oder leerer Werte erforderlich.

Einschränkung:
Die Prüfung bestätigt die Vollständigkeit der Felder,
aber nicht die inhaltliche Richtigkeit der Kundendaten.
*/

-- Schritt 5: Zusammenfassung customers
/*
Grain:
Die Tabelle customers enthält 795 Zeilen.
Eine Zeile steht für einen Kunden.

Stichprobe:
In den zehn geprüften Zeilen waren Kunden-ID, Kundenname
und Kundensegment ausgefüllt.
Die Segmente Consumer, Corporate und Home Office kamen vor.
In dieser Stichprobe wurden keine auffälligen fehlenden Werte festgestellt.

Primärschlüssel:
Die Tabelle enthält 795 Zeilen und 795 verschiedene customer_id-Werte.
Damit ist customer_id eindeutig.
Die zusätzliche Prüfung auf NULL-Werte zeigt,
dass keine customer_id fehlt.

Kundensegmente:
Es gibt insgesamt drei verschiedene Kundensegmente:
Consumer, Corporate und Home Office.

Datenqualität:
In customer_id, customer_name und customer_segment
wurden keine NULL-Werte gefunden.
customer_name und customer_segment enthalten außerdem
keine leeren oder nur aus Leerzeichen bestehenden Werte.

Fazit:
Die Tabelle customers hat einen klaren Grain und
customer_id ist eindeutig und enthält keine NULL-Werte.
Damit erfüllt die Spalte die geprüften Anforderungen
an einen Primärschlüssel.

Einschränkung:
Die bisherigen Prüfungen bestätigen die Vollständigkeit
und Eindeutigkeit der geprüften Felder.
Sie bestätigen jedoch nicht, ob Kundennamen und
Kundensegmente inhaltlich korrekt zugeordnet sind.
*/

-- ============================================================
-- 2. ORDERS – DATENÜBERBLICK UND DATENQUALITÄT
-- ============================================================

/*
Ziel: Die Bestelldaten kennenlernen und ihre Qualität prüfen.
Laut Datenbankschema (ER-Diagramm) steht eine Zeile für eine Bestellung.

Schritt 1: Anzahl der Bestellzeilen zählen
Schritt 2: Zehn Bestellzeilen ansehen
Schritt 3: Bestell-IDs und weitere Werte prüfen
Schritt 4a: Fehlende Werte prüfen
Schritt 4b: Unplausible Versanddaten prüfen
Schritt 5a: Beziehung orders → customers prüfen
Schritt 5b: Kunden ohne Bestellung prüfen
Schritt 6: Zusammenfassung orders
*/

-- Schritt 1: Anzahl der Bestellzeilen zählen
SELECT COUNT(*) AS total_rows
FROM orders;
/*
Ergebnis:
Die Tabelle orders enthält 5013 Zeilen.
Laut Datenbankschema steht jede Zeile für eine Bestellung.
Ob alle Bestell-IDs eindeutig sind, prüfen wir in Schritt 3.
*/

-- Schritt 2: Zehn Bestellzeilen ansehen
SELECT *
FROM orders
ORDER BY order_id
LIMIT 10;
/*
Ergebnis:
Die zehn angezeigten Bestellzeilen enthalten Bestell-ID, Kunden-ID,
Bestelldatum und verschiedene Versandinformationen.
In dieser Stichprobe sind alle Felder ausgefüllt.

Die Bestellungen stammen aus dem Jahr 2015.
Die Regionen East, West und South kommen vor.
Als Versandarten kommen Same Day und Standard Class vor.

Interpretation:
Die zehn Beispielzeilen zeigen keine offensichtlichen
fehlenden Werte oder unplausiblen Datumsbeziehungen.
Das Versanddatum liegt jeweils am oder nach dem Bestelldatum.

Einschränkung:
Die Ergebnisse gelten nur für die zehn angezeigten Zeilen.
Die gesamte Tabelle wird in den nächsten Schritten geprüft.
*/
-- Schritt 3: Bestell-IDs und weitere Werte prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT shipping_region) AS unique_regions,
    COUNT(DISTINCT shipping_mode) AS unique_shipping_modes
FROM orders;
/*
Ergebnis:
Die Tabelle orders enthält 5013 Zeilen und
5013 verschiedene order_id-Werte.

Es kommen 793 verschiedene Kunden-IDs vor.
Außerdem gibt es 4 verschiedene Versandregionen
und 4 verschiedene Versandarten.

Interpretation:
Da die Anzahl der Zeilen und der verschiedenen order_id-Werte
gleich ist, kommt keine order_id doppelt vor.

Es gibt mehr Bestellungen als verschiedene Kunden.
Das zeigt, dass Kunden mehrere Bestellungen haben können.

Die Tabelle customers enthält insgesamt 795 Kunden,
während in orders 793 verschiedene Kunden-IDs vorkommen.
Dieser Unterschied sollte später geprüft werden.

Einschränkung:
COUNT(DISTINCT ...) zählt keine NULL-Werte.
Ob customer_id, shipping_region oder shipping_mode
fehlende Werte enthalten, wird deshalb separat geprüft.
*/

-- Schritt 4a: Fehlende Werte in orders prüfen
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
Die Abfrage findet 6 Bestellungen mit fehlenden Werten.
Bei allen 6 Bestellungen fehlt nur die Postleitzahl
(shipping_postal_code).

Alle 6 Bestellungen betreffen Burlington im Bundesstaat Vermont.
In den anderen geprüften Spalten wurden keine NULL-Werte gefunden.

Interpretation:
Die Tabelle orders ist weitgehend vollständig.
Die einzige gefundene Datenlücke betrifft die Postleitzahl
bei 6 Bestellungen aus Burlington.

Datenqualität:
Die 6 Bestellungen können weiterhin nach Stadt, Bundesstaat
und Region ausgewertet werden.
Eine Auswertung nach Postleitzahl ist für diese Bestellungen
nicht möglich.

Einschränkung:
Die Ursache für die fehlenden Postleitzahlen ist nicht bekannt.
Die fehlenden Werte werden deshalb nicht ergänzt.
*/

-- Schritt 4b: Unplausible Versanddaten prüfen
SELECT *
FROM orders
WHERE shipping_date < order_date;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.

Interpretation:
Es wurden keine Bestellungen gefunden, bei denen das
Versanddatum vor dem Bestelldatum liegt.

Datenqualität:
Die geprüften Datumsbeziehungen sind plausibel.
*/

-- Schritt 5a: Beziehung orders → customers prüfen
SELECT DISTINCT o.customer_id
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.
Alle customer_id-Werte aus orders sind auch
in der Tabelle customers vorhanden.

Interpretation:
Jede Bestellung kann einem vorhandenen Kunden
in customers zugeordnet werden.
Es wurden keine ungültigen Kunden-IDs in orders gefunden.

Datenqualität:
Alle geprüften Bestellungen lassen sich einem
vorhandenen Kunden zuordnen.
Es wurden keine verwaisten Kundenreferenzen gefunden.

Einschränkung:
Diese Abfrage prüft nur die Richtung orders → customers.
Sie zeigt nicht, ob jeder Kunde aus customers
auch eine Bestellung in orders hat.
*/

-- Schritt 5b: Kunden ohne Bestellung prüfen
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
Die Abfrage findet 2 Kunden ohne Bestellung:
customer_id 794 – Zack Gibbens – Consumer
customer_id 795 – Loren Bowen – Corporate.

Interpretation:
Die Tabelle customers enthält 795 Kunden,
aber nur 793 davon kommen in orders vor.
Der Unterschied von 2 Kunden ist damit erklärt.

Datenqualität:
Die beiden Kunden sind in customers vorhanden,
haben aber keine zugehörige Bestellung in orders.
Das ist nicht automatisch ein Datenfehler.

Einschränkung:
Die Abfrage zeigt nur, dass diese Kunden keine Bestellung
im vorhandenen Datensatz haben.
Der Grund dafür ist nicht bekannt.
*/

-- Schritt 6: Zusammenfassung orders
/*
Grain:
Die Tabelle orders enthält 5013 Zeilen.
Eine Zeile steht für eine Bestellung.

Stichprobe:
In den zehn geprüften Bestellungen waren alle Felder ausgefüllt.
Die Bestellungen stammen aus dem Jahr 2015.
In der Stichprobe kamen verschiedene Regionen und Versandarten vor.
Das Versanddatum lag jeweils am oder nach dem Bestelldatum.

Primärschlüssel:
Die Tabelle enthält 5013 Zeilen und
5013 verschiedene order_id-Werte.
Damit ist order_id eindeutig.

Kunden und Versand:
In orders kommen 793 verschiedene Kunden-IDs vor.
Es gibt 4 verschiedene Versandregionen
und 4 verschiedene Versandarten.

Datenqualität:
Bei der Prüfung auf fehlende Werte wurden
6 Bestellungen mit fehlender Postleitzahl gefunden.
Alle 6 betreffen Burlington im Bundesstaat Vermont.
In den anderen geprüften Spalten wurden keine NULL-Werte gefunden.

Bei der Prüfung der Versanddaten wurden keine Bestellungen gefunden,
bei denen das Versanddatum vor dem Bestelldatum liegt.
Die geprüften Datumsbeziehungen sind damit plausibel.

Beziehung zu customers:
Alle customer_id-Werte aus orders sind auch
in der Tabelle customers vorhanden.
Es wurden keine ungültigen Kunden-IDs gefunden.

Von insgesamt 795 Kunden haben 2 Kunden
keine Bestellung im vorhandenen Datensatz.
Das ist nicht automatisch ein Datenfehler.

Fazit:
Die Bestell-IDs sind eindeutig und die Beziehung
von orders zu customers ist vollständig.
Als Datenlücke wurden 6 fehlende Postleitzahlen gefunden.
Bei den Versanddaten wurden keine unplausiblen
Datumsbeziehungen festgestellt.

Einschränkung:
Die Prüfungen bestätigen die Eindeutigkeit der Bestell-IDs,
die geprüften Kundenbeziehungen und plausible Versanddaten.
Bei sechs Bestellungen fehlen die Postleitzahlen.
Die inhaltliche Richtigkeit aller Angaben wurde nicht bestätigt.
*/

-- ============================================================
-- 3. ORDER_DETAILS – DATENÜBERBLICK UND DATENQUALITÄT
-- ============================================================

/*
Ziel:
Die Bestellpositionen kennenlernen und ihre Datenqualität prüfen.

Kennung und Beziehungen:
order_details_id kennzeichnet eine Bestellposition eindeutig.
order_id verweist auf orders.
product_id verweist auf product.

Schritt 1: Anzahl der Bestellpositionen zählen
Schritt 2: Zehn Bestellpositionen ansehen
Schritt 3: IDs und Anzahl der Bestellungen und Produkte prüfen
Schritt 4: Fehlende Werte prüfen
Schritt 5: Auffällige Mengen und Rabatte prüfen
Schritt 6a: Beziehung order_details → orders prüfen
Schritt 6b: Beziehung order_details → product prüfen
Schritt 7: Doppelte Kombinationen aus Bestellung und Produkt prüfen
Schritt 8: Zusammenfassung order_details
*/

-- Schritt 1: Anzahl der Bestellpositionen zählen
SELECT COUNT(*) AS total_rows
FROM order_details;
/*
Ergebnis:
Die Tabelle order_details enthält 9997 Bestellpositionen.

Zum Vergleich: Die Tabelle orders enthält 5013 Bestellungen.
Es gibt mehr Bestellpositionen als Bestellungen,
weil eine Bestellung mehrere Produkte enthalten kann.
*/

-- Schritt 2: Zehn Bestellpositionen ansehen
SELECT *
FROM order_details
ORDER BY order_details_id
LIMIT 10;
/*
Ergebnis:
Die zehn angezeigten Bestellpositionen sind vollständig ausgefüllt.
Einige order_id-Werte kommen mehrfach vor,
weil eine Bestellung mehrere Produkte enthalten kann.

Die Mengen liegen zwischen 3 und 130 Stück.
Die Rabatte liegen zwischen 0 % und 30 %.

Auffälligkeit:
Bei order_details_id 9 beträgt der Umsatz 502,
aber der Gewinn ist mit -88 negativ.
Auch die Gewinnquote ist mit -0,18 negativ.

Interpretation:
Mehrere Produkte pro Bestellung entsprechen
der Struktur der Bestelldaten.

Der negative Gewinn bei order_details_id 9 zeigt,
dass für diese Bestellposition ein Verlust ausgewiesen wird.
Das ist nicht automatisch ein Datenfehler.

Einschränkung:
Diese Beobachtungen gelten nur für die zehn angezeigten Zeilen.
Die gesamte Tabelle wird in den nächsten Schritten geprüft.
*/

-- Schritt 3: IDs und Anzahl der Bestellungen und Produkte prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_details_id) AS unique_detail_ids,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM order_details;
/*
Ergebnis:
Die Tabelle order_details enthält 9997 Zeilen und
9997 verschiedene order_details_id-Werte.

Es kommen 5013 verschiedene Bestell-IDs
und 1850 verschiedene Produkt-IDs vor.

Interpretation:
Da die Anzahl der Zeilen und der verschiedenen
order_details_id-Werte gleich ist,
kommt keine order_details_id doppelt vor.

Bestell-IDs und Produkt-IDs dürfen mehrfach vorkommen.
Eine Bestellung kann mehrere Produkte enthalten
und ein Produkt kann in mehreren Bestellungen vorkommen.

Einschränkung:
COUNT(DISTINCT ...) zählt keine NULL-Werte.
Ob fehlende Werte vorhanden sind,
wird deshalb in Schritt 4 separat geprüft.

Ob alle order_id- und product_id-Werte zu den Tabellen
orders und product passen, wird später separat geprüft.
*/

-- Schritt 4: Fehlende Werte prüfen
SELECT *
FROM order_details
WHERE order_details_id IS NULL
   OR order_id IS NULL
   OR TRIM(order_id) = ''
   OR product_id IS NULL
   OR quantity IS NULL
   OR order_discount IS NULL
   OR order_sales IS NULL
   OR order_profits IS NULL
   OR order_profit_ratio IS NULL;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.
In den geprüften Spalten wurden keine NULL-Werte gefunden.
Auch bei order_id wurden keine leeren Werte gefunden.

Interpretation:
Die geprüften Felder in order_details sind vollständig ausgefüllt.
Es wurden keine fehlenden Werte gefunden.

Datenqualität:
Bei dieser Prüfung wurde kein Datenproblem festgestellt.

Einschränkung:
Die Prüfung zeigt nur, dass keine Werte fehlen.
Sie bestätigt nicht, ob alle Werte inhaltlich korrekt sind.
*/

-- Schritt 5: Auffällige Mengen und Rabatte prüfen
SELECT *
FROM order_details
WHERE quantity <= 0
   OR order_discount < 0
   OR order_discount > 1;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.
Es wurden keine Mengen kleiner oder gleich 0 gefunden.
Auch wurden keine Rabatte unter 0 oder über 1 gefunden.

Interpretation:
Alle Mengen sind größer als 0.
Die Rabatte liegen im erwarteten Bereich
zwischen 0 und 1 (0 % bis 100 %).

Datenqualität:
Bei dieser Prüfung wurden keine auffälligen
Mengen oder ungültigen Rabattwerte gefunden.

Einschränkung:
Die Prüfung kontrolliert nur die festgelegten Grenzen.
Ungewöhnlich hohe Mengen oder hohe Rabatte innerhalb
dieser Grenzen werden damit nicht bewertet.
*/

-- Schritt 6a: Beziehung order_details → orders prüfen
SELECT DISTINCT od.order_id
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.
Alle order_id-Werte aus order_details sind auch
in der Tabelle orders vorhanden.

Interpretation:
Jede Bestellposition kann einer vorhandenen
Bestellung in orders zugeordnet werden.

Datenqualität:
Die Beziehung order_details → orders ist vollständig.
Bei dieser Prüfung wurde kein Datenproblem gefunden.

Einschränkung:
Diese Abfrage prüft nur die Beziehung über order_id.
Sie bestätigt nicht, ob alle anderen Werte
der Bestellpositionen inhaltlich korrekt sind.
*/

-- Schritt 6b: Beziehung order_details → product prüfen
SELECT DISTINCT od.product_id
FROM order_details AS od
LEFT JOIN product AS p
    ON od.product_id = p.product_id
WHERE p.product_id IS NULL;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen zurück.
Alle product_id-Werte aus order_details sind auch
in der Tabelle product vorhanden.

Interpretation:
Jede Bestellposition kann einem vorhandenen
Produkt in product zugeordnet werden.

Datenqualität:
Die Beziehung order_details → product ist vollständig.
Bei dieser Prüfung wurde kein Datenproblem gefunden.

Einschränkung:
Diese Abfrage prüft nur die Beziehung über product_id.
Sie bestätigt nicht, ob alle Produktdaten
inhaltlich korrekt sind.
*/

-- Schritt 7: Doppelte Kombinationen aus Bestellung und Produkt prüfen
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
Es wurden keine doppelten Kombinationen aus
order_id und product_id gefunden.

Interpretation:
Jede Kombination aus Bestellung und Produkt
kommt nur einmal in order_details vor.
Das entspricht dem erwarteten Grain der Tabelle.

Datenqualität:
Bei dieser Prüfung wurden keine Duplikate
auf Ebene von Bestellung und Produkt gefunden.

Einschränkung:
Diese Prüfung kontrolliert nur die Kombination
aus order_id und product_id.
Sie bestätigt nicht, ob alle Werte der
Bestellpositionen inhaltlich korrekt sind.
*/

-- Schritt 8: Zusammenfassung order_details
/*
Grain:
Die Tabelle order_details enthält 9997 Zeilen.
Eine Zeile steht für ein Produkt innerhalb einer Bestellung.
Es gibt 5013 verschiedene Bestell-IDs
und 1850 verschiedene Produkt-IDs.

Stichprobe:
In den zehn geprüften Bestellpositionen waren alle Felder ausgefüllt.
Die Mengen lagen zwischen 3 und 130 Stück
und die Rabatte zwischen 0 % und 30 %.

Bei order_details_id 9 wurde ein negativer Gewinn festgestellt.
Ein negativer Gewinn ist nicht automatisch ein Datenfehler.

Primärschlüssel:
Die Tabelle enthält 9997 Zeilen und
9997 verschiedene order_details_id-Werte.
Damit ist order_details_id eindeutig.

Datenqualität:
In den geprüften Spalten wurden keine fehlenden Werte gefunden.
Alle Mengen sind größer als 0.
Die Rabatte liegen zwischen 0 und 1 (0 % bis 100 %).

Beziehungen:
Alle order_id-Werte aus order_details sind
in der Tabelle orders vorhanden.

Alle product_id-Werte aus order_details sind
in der Tabelle product vorhanden.

Damit können alle Bestellpositionen einer vorhandenen
Bestellung und einem vorhandenen Produkt zugeordnet werden.

Duplikate:
Es wurden keine doppelten Kombinationen aus
order_id und product_id gefunden.
Damit entspricht die Tabelle dem erwarteten Grain.

Fazit:
Die Bestellpositionen sind anhand der geprüften IDs eindeutig.
In den untersuchten Feldern wurden keine fehlenden Werte,
ungültigen Mengen oder Rabatte festgestellt.

Auch bei den geprüften Tabellenbeziehungen und
Kombinationen aus Bestellung und Produkt
wurden keine Auffälligkeiten gefunden.

Der negative Gewinn bei order_details_id 9
ist eine wirtschaftliche Auffälligkeit,
aber nicht automatisch ein Datenfehler.

Einschränkung:
Die Prüfungen bestätigen die Eindeutigkeit der IDs,
die Vollständigkeit der untersuchten Felder sowie
die geprüften Mengen, Rabatte und Tabellenbeziehungen.

Die Prüfungen erfassen jedoch nicht alle möglichen
Datenqualitätsprobleme oder wirtschaftlichen Auffälligkeiten.
Die inhaltliche Richtigkeit aller Werte wurde nicht bestätigt.
*/

-- ============================================================
-- 4. PRODUCT – DATENÜBERBLICK UND DATENQUALITÄT
-- ============================================================

/*
Ziel:
Den Produktkatalog kennenlernen und seine Datenqualität prüfen.

Kennung und Beziehung:
product_id kennzeichnet ein Produkt eindeutig.
Über product_id ist die Tabelle mit order_details verbunden.
Ein Produkt kann in mehreren Bestellpositionen vorkommen.

Schritt 1: Anzahl der Produkte zählen
Schritt 2: Zehn Produkte ansehen
Schritt 3: Produkt-IDs und weitere Werte prüfen
Schritt 4: Fehlende Werte prüfen
Schritt 5a: Vorhandene Produktkategorien anzeigen
Schritt 5b: Herstellerwert "Other" prüfen
Schritt 6: Zusammenfassung product
*/

-- Schritt 1: Anzahl der Produkte zählen
SELECT COUNT(*) AS total_rows
FROM product;
/*
Ergebnis:
Die Tabelle product enthält 1850 Zeilen.
Laut Datenbankschema steht eine Zeile für ein Produkt.

Ob alle Produkt-IDs eindeutig sind,
prüfen wir in Schritt 3.
*/

-- Schritt 2: Zehn Produkte ansehen
SELECT *
FROM product
ORDER BY product_id
LIMIT 10;
/*
Ergebnis:
In den zehn angezeigten Produkten sind alle Felder ausgefüllt.
Alle zehn Produkte gehören zur Kategorie Office Supplies.

Die Unterkategorien Paper, Envelopes und Appliances kommen vor.
Bei allen zehn Produkten steht als Hersteller „Other“.

Auffälligkeit:
„Other“ ist kein fehlender Wert,
nennt aber keinen konkreten Hersteller.
Das kann eine spätere Auswertung nach Hersteller einschränken.

Einschränkung:
Diese Beobachtungen gelten nur für die zehn angezeigten Produkte.
Die gesamte Tabelle wird in den nächsten Schritten geprüft.
*/

-- Schritt 3: Produkt-IDs und weitere Werte prüfen
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(DISTINCT product_category) AS unique_categories,
    COUNT(DISTINCT product_subcategory) AS unique_subcategories,
    COUNT(DISTINCT product_manufacturer) AS unique_manufacturers
FROM product;
/*
Ergebnis:
Die Tabelle product enthält 1850 Zeilen und
1850 verschiedene product_id-Werte.

Es gibt 3 verschiedene Produktkategorien,
17 verschiedene Unterkategorien
und 183 verschiedene Herstellerwerte.

Interpretation:
Die 1850 Produktzeilen enthalten 1850 verschiedene
product_id-Werte. Damit kommt keine product_id doppelt vor.

Die 183 verschiedenen Herstellerwerte enthalten
auch die Sammelbezeichnung "Other".
Daher entsprechen sie nicht 183 konkret
identifizierbaren Herstellern.

Einschränkung:
COUNT(DISTINCT ...) zählt keine NULL-Werte.
Ob fehlende Werte vorhanden sind,
wird deshalb in Schritt 4 separat geprüft.
*/

-- Schritt 4: Fehlende Werte prüfen
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
Es wurden keine NULL-Werte oder leeren Textfelder gefunden.

Interpretation:
Die geprüften Produktdaten sind vollständig ausgefüllt.

Einschränkung:
Vollständige Werte bedeuten nicht automatisch,
dass alle Angaben inhaltlich korrekt sind.
*/

-- Schritt 5a: Vorhandene Produktkategorien anzeigen
SELECT DISTINCT product_category
FROM product
ORDER BY product_category;
/*
Ergebnis:
Es gibt 3 Produktkategorien:
Furniture, Office Supplies und Technology.

Interpretation:
Die Kategorien können später für Vergleiche
von Umsatz und Gewinn verwendet werden.
*/

-- Schritt 5b: Herstellerwert "Other" prüfen
SELECT
    COUNT(*) AS other_products
FROM product
WHERE product_manufacturer = 'Other';
/*
Ergebnis:
356 Produkte haben den Herstellerwert "Other".

Interpretation:
"Other" ist kein fehlender Wert, nennt aber keinen
konkreten Hersteller.

Datenqualität:
Bei 356 Produkten ist "Other" als Hersteller angegeben.
Damit ist der konkrete Hersteller dieser Produkte
im Datensatz nicht identifizierbar.

Dies schränkt die Aussagekraft einer Analyse
nach einzelnen Herstellern ein.

Einschränkung:
Aus den vorhandenen Daten ist nicht ersichtlich,
welche konkreten Hersteller hinter "Other" stehen.
*/

-- Schritt 6: Zusammenfassung product
/*
Grain:
Die Tabelle product enthält 1850 Zeilen.
Eine Zeile steht für ein Produkt.

Stichprobe:
In den zehn geprüften Produkten waren alle Felder ausgefüllt.
Alle zehn Produkte gehörten zur Kategorie Office Supplies.
Der Herstellerwert "Other" fiel in der Stichprobe auf.

Primärschlüssel:
product_id ist eindeutig.

Datenqualität:
Es wurden keine NULL-Werte oder leeren Textfelder gefunden.

Beziehung:
Alle in order_details verwendeten product_id-Werte
sind auch in product vorhanden.

Hersteller:
356 Produkte haben den Herstellerwert "Other".
"Other" ist kein fehlender Wert, nennt aber keinen
konkreten Hersteller.
Dadurch kann eine spätere Analyse nach Hersteller
eingeschränkt sein.

Fazit:
Die Produkt-IDs sind eindeutig und die geprüften
Produktfelder enthalten keine fehlenden oder leeren Werte.

Bei 356 Produkten ist mit "Other" jedoch kein
konkreter Hersteller angegeben. Dies schränkt
Analysen nach einzelnen Herstellern ein.

Einschränkung:
Die Prüfungen bestätigen die Eindeutigkeit der Produkt-IDs
und die Vollständigkeit der untersuchten Felder.

Die inhaltliche Richtigkeit aller Produktangaben
wurde nicht bestätigt. Zudem ist nicht bekannt,
welche konkreten Hersteller hinter "Other" stehen.
*/

-- ============================================================
-- QUELLE: 02_qa/qa_checks.sql
-- ============================================================
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

-- ============================================================
-- QUELLE: 02_qa/assertions.sql
-- ============================================================
-- ============================================================
-- UNICORN – ASSERTIONS UND DATENQUALITÄT
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Wichtige Annahmen über die Unicorn-Daten werden
mit wiederverwendbaren Assertion Queries überprüft.

Aufbau:
1. Eindeutigkeit und Vollständigkeit der Kunden-IDs
2. Erwarteter Bestellzeitraum (2015–2018)
3. Gültige Produktkategorien
4. Kurze Postleitzahlen (Baseline: 213)
5. Gültige Kundenbeziehungen

Erwartete Ergebnisse:
Assertions 1, 2, 3 und 5: 0 Auffälligkeiten.
Assertion 4: 213 kurze Postleitzahlen als dokumentierte
Baseline, sofern durch die QA-Ergebnisse bestätigt.

Hinweis:
Die Assertions dienen dazu, Abweichungen von den
geprüften Erwartungen und bekannten Datenzuständen
zu erkennen. Ein abweichendes Ergebnis ist ein
Prüfsignal und nicht automatisch ein Datenfehler.
*/

-- =====================================================
-- ASSERTION 1 – Eindeutige und vorhandene customer_id
-- =====================================================

/*
Prüfung:
Jede customer_id in customers soll vorhanden
und eindeutig sein.

Gesundes Ergebnis:
missing_customer_ids = 0
duplicate_customer_ids = 0

Wenn missing_customer_ids größer als 0 ist,
existieren fehlende Kunden-IDs.

Wenn duplicate_customer_ids größer als 0 ist,
existieren doppelte Kunden-IDs.
*/

SELECT
    COUNT(*) - COUNT(customer_id) AS missing_customer_ids,
    COUNT(customer_id) - COUNT(DISTINCT customer_id)
        AS duplicate_customer_ids
FROM customers;

-- Ergebnis 0 und 0

-- =====================================================
-- ASSERTION 2 – Erwarteter Bestellzeitraum
-- =====================================================

/*
Prüfung:
Alle Bestellungen sollen innerhalb des erwarteten
Zeitraums 2015–2018 liegen.

Gesundes Ergebnis:
0

Wenn das Ergebnis größer als 0 ist,
existieren Bestellungen außerhalb des erwarteten Zeitraums.
*/

SELECT
    COUNT(*) AS orders_outside_expected_date_range
FROM orders
WHERE order_date IS NULL
   OR order_date < DATE '2015-01-01'
   OR order_date >= DATE '2019-01-01';

-- Ergebnis 0

-- =====================================================
-- ASSERTION 3 – Gültige Produktkategorien
-- =====================================================

/*
Prüfung:
product_category darf nur die drei erwarteten
Produktkategorien enthalten:
Furniture, Office Supplies und Technology.

Gesundes Ergebnis:
0

Wenn das Ergebnis größer als 0 ist,
existieren fehlende oder unerwartete Produktkategorien.
*/

SELECT
    COUNT(*) AS unexpected_product_categories
FROM product
WHERE product_category IS NULL
   OR product_category NOT IN (
       'Furniture',
       'Office Supplies',
       'Technology');

-- Ergebnis 0

-- =====================================================
-- ASSERTION 4 – Kurze Postleitzahlen
-- =====================================================

/*
Prüfung:
Die Anzahl der nicht fehlenden shipping_postal_code-Werte
mit weniger als 5 Stellen soll der bekannten Baseline entsprechen.

Gesundes Ergebnis:
213

Wenn das Ergebnis nicht 213 ist,
hat sich die Anzahl der kurzen Postleitzahlen verändert.
*/

SELECT
    COUNT(*) AS short_postal_codes
FROM orders
WHERE shipping_postal_code IS NOT NULL
  AND LENGTH(shipping_postal_code::text) < 5;

-- Ergebnis 213

-- =====================================================
-- ASSERTION 5 – Gültige Kundenbeziehungen
-- =====================================================

/*
Prüfung:
Jede customer_id aus orders soll auch
in der Tabelle customers vorhanden sein.

Gesundes Ergebnis:
0

Wenn das Ergebnis größer als 0 ist,
existieren Bestellungen mit einer customer_id,
die keinem vorhandenen Kunden zugeordnet werden kann.
*/

SELECT
    COUNT(*) AS orders_without_valid_customer
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Ergebnis 0

-- ============================================================
-- QUELLE: 02_qa/business_slice.sql
-- ============================================================
-- ============================================================
-- UNICORN – BUSINESS SLICE
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Der Business Slice legt fest, welche Bestellungen
für die weitere Unicorn-Analyse berücksichtigt werden.

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Umgang mit fehlenden Werten:
Die 6 Bestellungen ohne shipping_postal_code
bleiben enthalten, da Auswertungen nach Stadt,
Bundesstaat und Region weiterhin möglich sind.

Erwartetes Ergebnis:
5.013 Bestellungen.
Keine der vorhandenen Bestellungen wird ausgeschlossen.
*/

-- ============================================================
-- BUSINESS SLICE – BESTELLUNGEN 2015–2018
-- ============================================================

SELECT *
FROM orders
WHERE order_date >= DATE '2015-01-01'
  AND order_date < DATE '2019-01-01'
  AND shipping_country = 'United States'
  AND shipping_mode IN (
      'First Class',
      'Same Day',
      'Second Class',
      'Standard Class');
/*
Ergebnis:
Der Business Slice enthält 5.013 Bestellungen.
Die Zeilenanzahl entspricht der ursprünglichen Tabelle orders.

Der definierte Zeitraum umfasst 2015–2018.
Berücksichtigt werden Bestellungen aus den United States
mit den vier festgelegten Versandarten.

Interpretation:
Die Abfrage liefert dieselbe Anzahl an Bestellungen
wie die ursprüngliche Tabelle orders.
Damit wurden durch die definierten Filter keine
Bestellungen ausgeschlossen.

Die 6 Bestellungen ohne shipping_postal_code bleiben
im Business Slice enthalten.

Einschränkung:
Die übereinstimmende Zeilenanzahl bestätigt nicht
die inhaltliche Richtigkeit aller Bestellangaben.

Die fehlenden Postleitzahlen werden nicht ergänzt,
da ihre tatsächlichen Werte nicht bekannt sind.
*/

-- ============================================================
-- QUELLE: 03_kpis/individual_kpis.sql
-- ============================================================
-- ============================================================
-- UNICORN – KPI-ANALYSE
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die Stakeholder-Frage „Wo sollten wir den Fokus für
weiteres Wachstum setzen?“ anhand von fünf KPIs
aus drei Perspektiven untersuchen.

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

-- ============================================================
-- QUELLE: 03_kpis/summary_query.sql
-- ============================================================
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

-- ============================================================
-- QUELLE: 03_kpis/segmented_kpis.sql
-- ============================================================
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

-- ============================================================
-- QUELLE: 04_joined_data/canonical_join.sql
-- ============================================================
-- ============================================================
-- UNICORN – CANONICAL JOIN
-- ============================================================
/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die vier Unicorn-Tabellen werden zu einer zentralen,
einheitlichen Datengrundlage für die weitere Analyse
und das Reporting verbunden.

Verwendete Tabellen:
- order_details
- orders
- customers
- product

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Grain:
Eine Zeile entspricht einer Bestellposition
(order_details).

Join-Logik:
- order_details → orders über order_id
- orders → customers über customer_id
- order_details → product über product_id

Alle vier Tabellen werden mit INNER JOIN verbunden.
Die Überprüfung der Zeilenanzahl und der Join-Qualität
erfolgt separat in join_validation.sql.
*/

SELECT
    -- order_details
    od.order_details_id,
    od.order_id,
    od.product_id,
    od.quantity,
    od.order_discount,
    od.order_sales,
    od.order_profits,
    od.order_profit_ratio,

    -- orders
    o.customer_id,
    o.order_date,
    o.shipping_city,
    o.shipping_state,
    o.shipping_region,
    o.shipping_country,
    o.shipping_postal_code,
    o.shipping_date,
    o.shipping_mode,

    -- customers
    c.customer_name,
    c.customer_segment,

    -- product
    p.product_name,
    p.product_category,
    p.product_subcategory,
    p.product_manufacturer

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
      'Standard Class');

/*
Ergebnis:
Der Canonical Join liefert 9.997 Zeilen und 23 Spalten.

Prüfung des CSV-Exports:
- 9.997 eindeutige Bestellpositions-IDs
- Keine fehlenden Bestellpositions-IDs
- Keine doppelten Bestellpositions-IDs
- Zeitraum: 2015–2018
- Land: United States
- Alle vier definierten Versandarten enthalten

Interpretation:
Im exportierten Ergebnis ist jede Bestellposition
eindeutig identifizierbar. Der vorgesehene Grain
(eine Zeile pro Bestellposition) wird eingehalten.

Einschränkung:
Ob durch die INNER JOINs Bestellpositionen aus
der gefilterten Ausgangsdatenbasis verloren gehen,
wird separat in join_validation.sql überprüft.
*/

-- ============================================================
-- QUELLE: 04_joined_data/join_validation.sql
-- ============================================================
-- ============================================================
-- UNICORN – JOIN VALIDATION
-- ============================================================
/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die Qualität des Canonical Join wird überprüft.
Dabei wird untersucht, ob durch die Verknüpfung
der vier Unicorn-Tabellen Bestellpositionen
verloren gehen oder vervielfacht werden.

Verwendete Tabellen:
- order_details
- orders
- customers
- product

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Grain:
Eine Zeile entspricht einer Bestellposition
(order_details).

Prüflogik:
Check 1: Vergleich der Zeilenanzahl vor und
         nach dem vollständigen Canonical Join.
Check 2: Prüfung auf doppelte JOIN-Schlüssel.
Check 3: Prüfung auf fehlende Referenzen
         mithilfe von LEFT JOIN und IS NULL.

Hinweis:
Check 1 verwendet den definierten Business Scope.
Checks 2 und 3 prüfen die Schlüsselbeziehungen
über den gesamten Datenbestand.
*/

-- ============================================================
-- CHECK 1 – ZEILENANZAHL
-- ============================================================

-- Check 1a: Anzahl der Bestellpositionen im Analyseumfang
SELECT
    COUNT(*) AS anzahl_bestellpositionen
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
      'Standard Class');

/* Ergebnis:
Die Abfrage liefert 9.997 Bestellpositionen.
Damit ist die erwartete Zeilenanzahl bestätigt. */

-- Check 1b: Anzahl der Zeilen nach dem vollständigen Canonical Join
SELECT
    COUNT(*) AS anzahl_canonical_join
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
      'Standard Class');

/* Ergebnis:
Der vollständige Canonical Join liefert 9.997 Zeilen.
Die Zeilenanzahl entspricht damit der Anzahl der Bestellpositionen aus Check 1a.
Der Vergleich zeigt keine Veränderung der Gesamtzeilenanzahl.
Ob einzelne Bestellpositionen verloren gehen oder vervielfacht
werden, wird ergänzend durch die Schlüssel- und Referenzprüfungen
in Check 2 und Check 3 beurteilt. */

-- ============================================================
-- CHECK 2 – DUPLICATE DETECTION
-- ============================================================

-- Check 2a: Doppelte order_id in orders prüfen
-- Erwartung: 0 Duplikate

SELECT
    order_id,
    COUNT(*) AS anzahl
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

/* Ergebnis:
Es wurden keine doppelten order_id-Werte gefunden.
Die Eindeutigkeit von orders.order_id ist bestätigt. */

-- Check 2b: Doppelte customer_id in customers prüfen
-- Erwartung: 0 Duplikate

SELECT
    customer_id,
    COUNT(*) AS anzahl
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

/* Ergebnis:
Es wurden keine doppelten customer_id-Werte gefunden.
Die Eindeutigkeit von customers.customer_id ist bestätigt. */

-- Check 2c: Doppelte product_id in product prüfen
-- Erwartung: 0 Duplikate

SELECT
    product_id,
    COUNT(*) AS anzahl
FROM product
GROUP BY product_id
HAVING COUNT(*) > 1;

/* Ergebnis:
Es wurden keine doppelten product_id-Werte gefunden.
Die Eindeutigkeit von product.product_id ist bestätigt.

Zusammenfassung Check 2:
Alle Join-Schlüssel auf der One-Seite sind eindeutig.
Es besteht kein Hinweis auf eine Zeilenvervielfachung
durch doppelte Join-Schlüssel. */

-- ============================================================
-- CHECK 3 – ORPHAN CHECKS
-- ============================================================

-- Check 3a: Bestellpositionen ohne passende Bestellung prüfen
-- Erwartung: 0 verwaiste Referenzen

SELECT
    COUNT(*) AS fehlende_orders
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

/* Ergebnis:
Es wurden keine Bestellpositionen ohne passende Bestellung gefunden.
Die Referenzen zwischen order_details und orders sind vollständig. */

-- Check 3b: Bestellpositionen ohne passenden Kunden prüfen
-- Erwartung: 0 verwaiste Referenzen

SELECT
    COUNT(*) AS fehlende_customers
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

/*
Ergebnis:
Es wurden keine Bestellpositionen ohne passenden Kunden gefunden.
Die Referenzen zwischen order_details, orders und customers sind vollständig.
*/

-- Check 3c: Bestellpositionen ohne passendes Produkt prüfen
-- Erwartung: 0 verwaiste Referenzen

SELECT
    COUNT(*) AS fehlende_products
FROM order_details AS od
LEFT JOIN product AS p
    ON od.product_id = p.product_id
WHERE p.product_id IS NULL;

/* Ergebnis:
Es wurden keine Bestellpositionen ohne passendes Produkt gefunden.
Die Referenzen zwischen order_details und product sind vollständig.

Zusammenfassung Check 3:
Es wurden keine verwaisten Referenzen gefunden.
Alle für den Canonical Join benötigten Beziehungen sind vollständig */

-- ============================================================
-- QUELLE: 04_joined_data/join_comparison.sql
-- ============================================================
-- ============================================================
-- UNICORN – JOIN COMPARISON
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
INNER JOIN und LEFT JOIN vergleichen, um zu prüfen,
ob beim Verknüpfen von Tabellen Bestellpositionen
verloren gehen oder zusätzliche Zeilen entstehen.

Verwendete Tabellen:
- order_details
- orders

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Prüfumfang:
Die JOIN-Varianten werden zunächst auf den
vollständigen Quelltabellen ohne zusätzliche
Business-Scope-Filter verglichen.

Vorgehensweise:
1. Anzahl der Zeilen beim INNER JOIN ermitteln.
2. Anzahl der Zeilen beim LEFT JOIN ermitteln.
3. Ergebnisse vergleichen.
4. Unterschiede untersuchen und dokumentieren.

Die Originaldaten bleiben unverändert.
*/

-- ============================================================
-- 1. INNER JOIN – ANZAHL DER BESTELLPOSITIONEN
-- ============================================================

SELECT
    COUNT(*) AS inner_join_rows
FROM order_details AS od
INNER JOIN orders AS o
    ON od.order_id = o.order_id;

-- Der INNER JOIN liefert ebenfalls 9.997 Zeilen.

-- ============================================================
-- 2. LEFT JOIN – ANZAHL DER BESTELLPOSITIONEN
-- ============================================================

SELECT
    COUNT(*) AS left_join_rows
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id;

/*
Ergebnis:
Der LEFT JOIN liefert 9.997 Bestellpositionen.
Der INNER JOIN liefert ebenfalls 9.997 Zeilen.

Die Differenz beträgt 0 Zeilen.

Interpretation:
Beide JOIN-Varianten liefern dieselbe Zeilenanzahl.
Es gibt somit keinen Hinweis auf verlorene
Bestellpositionen durch den INNER JOIN.

Die gleiche Zeilenanzahl allein beweist jedoch
noch nicht, dass alle JOIN-Schlüssel korrekt
zugeordnet sind.
*/

-- ============================================================
-- 3. BESTELLPOSITIONEN OHNE PASSENDE BESTELLUNG
-- ============================================================

-- Erwartung: 0

SELECT
    COUNT(*) AS unmatched_order_details
FROM order_details AS od
LEFT JOIN orders AS o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

/*
Ergebnis:
Die Abfrage liefert 0 Bestellpositionen ohne
passende Bestellung.

Interpretation:
Alle Bestellpositionen besitzen eine passende
Bestellung in der Tabelle orders.

Zusammen mit dem Vergleich der Zeilenanzahlen
zeigt dies, dass beim INNER JOIN keine
Bestellpositionen verloren gehen.

Die Prüfung bezieht sich auf die vollständigen
Quelltabellen ohne Business-Scope-Filter.
*/

-- ============================================================
-- QUELLE: 05_cleaned_dimensions/diagnostic_queries.sql
-- ============================================================
-- ============================================================
-- UNICORN – DIMENSION DIAGNOSTICS
-- ============================================================
/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19
Zeitraum: 2015–2018

Ziel:
Die relevanten Dimensionen werden auf mögliche
Datenqualitätsprobleme untersucht.

Eine Bereinigung erfolgt nur, wenn die Diagnosen
einen tatsächlichen Bedarf zeigen.

Verwendete Tabellen:
- customers
- orders
- product

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Prüfumfang:
Die Dimensionsprüfungen erfolgen auf den
jeweiligen Quelltabellen ohne zusätzliche
Business-Scope-Filter.

Geprüfte Merkmale:
- Führende und nachgestellte Leerzeichen
- Auffällige Groß- und Kleinschreibung
- NULL-Werte
- Fehlende oder unerwartete Kategorien
- Auffällige Herstellerangaben

Hinweis:
order_details wird nicht direkt benötigt, da
hier die Dimensionsattribute der Tabellen
customers, orders und product geprüft werden.

Ergebnisse und Bereinigungsentscheidungen werden
jeweils direkt unter den SQL-Abfragen dokumentiert.
*/

-- ============================================================
-- 1. customers.customer_name
-- ============================================================

-- Check 1.1: Führende oder nachgestellte Leerzeichen
-- Erwartung: 0 Zeilen

SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_name <> TRIM(customer_name);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine führenden oder nachgestellten Leerzeichen
in customer_name gefunden.

Decision:
Keine Bereinigung mit TRIM erforderlich.
*/

-- Check 1.2: Auffällige Groß- oder Kleinschreibung
-- Erwartung: 0 Zeilen

SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_name = UPPER(customer_name)
   OR customer_name = LOWER(customer_name);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine vollständig groß- oder kleingeschriebenen
Kundennamen gefunden.

Decision:
Keine Bereinigung aufgrund vollständig groß- oder
kleingeschriebener Kundennamen erforderlich.
Die vorhandene Schreibweise bleibt unverändert.
*/

-- Check 1.3: Fehlende oder leere Kundennamen prüfen
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_fehlende_namen
FROM customers
WHERE customer_name IS NULL
   OR TRIM(customer_name) = '';

/*
Ergebnis:
Die Abfrage liefert 0 fehlende oder leere Kundennamen.
Es wurden weder NULL-Werte noch leere Zeichenfolgen
in customer_name gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder leerer
Kundennamen erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 2. customers.customer_segment
-- ============================================================

-- Check 2.1: Vorhandene Kategorien prüfen
-- Erwartung: Consumer, Corporate, Home Office

SELECT
    customer_segment,
    COUNT(*) AS anzahl
FROM customers
GROUP BY customer_segment
ORDER BY customer_segment;

/*
Ergebnis:
Es wurden genau drei Kundensegmente gefunden:
Consumer, Corporate und Home Office.

Alle Werte entsprechen den erwarteten Kategorien.

Decision:
Keine Bereinigung von customer_segment erforderlich.
*/

-- Check 2.2: Fehlende oder unerwartete Kundensegmente
-- Erwartung: 0 Zeilen

SELECT
    customer_segment,
    COUNT(*) AS anzahl
FROM customers
WHERE customer_segment IS NULL
   OR customer_segment NOT IN (
       'Consumer', 'Corporate', 'Home Office'
   )
GROUP BY customer_segment
ORDER BY customer_segment;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
vorgegebenen Kundensegmente Consumer, Corporate und
Home Office gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Kundensegmente erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 2.3: Leere oder nur aus Leerzeichen bestehende Segmente
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_segmente
FROM customers
WHERE customer_segment IS NOT NULL
  AND TRIM(customer_segment) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Kundensegmente gefunden.

Decision:
Keine Bereinigung aufgrund leerer Kundensegmente
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 3. orders.shipping_city
-- ============================================================

-- Check 3.1: Führende oder nachgestellte Leerzeichen
-- Erwartung: 0 Zeilen

SELECT DISTINCT
    shipping_city
FROM orders
WHERE shipping_city <> TRIM(shipping_city);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine führenden oder nachgestellten Leerzeichen
in shipping_city gefunden.

Decision:
Keine Bereinigung mit TRIM erforderlich.
*/

-- Check 3.2: Auffällige Groß- oder Kleinschreibung
-- Erwartung: 0 Zeilen

SELECT DISTINCT
    shipping_city
FROM orders
WHERE shipping_city = UPPER(shipping_city)
   OR shipping_city = LOWER(shipping_city);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine vollständig groß- oder kleingeschriebenen
Städtenamen gefunden.

Decision:
Keine Bereinigung aufgrund vollständig groß- oder
kleingeschriebener Städtenamen erforderlich.
Die vorhandene Schreibweise bleibt unverändert.
*/

-- Check 3.3: Fehlende oder leere Städtenamen prüfen
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_fehlende_staedte
FROM orders
WHERE shipping_city IS NULL
   OR TRIM(shipping_city) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden weder NULL-Werte noch leere oder ausschließlich
aus Leerzeichen bestehende Städtenamen gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder leerer
Städtenamen erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 4. orders.shipping_state
-- ============================================================

-- Check 4.1: Führende oder nachgestellte Leerzeichen
-- Erwartung: 0 Zeilen

SELECT DISTINCT
    shipping_state
FROM orders
WHERE shipping_state <> TRIM(shipping_state);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine führenden oder nachgestellten Leerzeichen
in shipping_state gefunden.

Decision:
Keine Bereinigung mit TRIM erforderlich.
*/

-- Check 4.2: Auffällige Groß- oder Kleinschreibung
-- Erwartung: 0 Zeilen

SELECT DISTINCT
    shipping_state
FROM orders
WHERE shipping_state = UPPER(shipping_state)
   OR shipping_state = LOWER(shipping_state);

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine vollständig groß- oder kleingeschriebenen
Bundesstaatennamen gefunden.

Decision:
Keine Bereinigung aufgrund vollständig groß- oder
kleingeschriebener Bundesstaatennamen erforderlich.
Die vorhandene Schreibweise bleibt unverändert.
*/

-- Check 4.3: Fehlende oder leere Bundesstaatennamen prüfen
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_fehlende_bundesstaaten
FROM orders
WHERE shipping_state IS NULL
   OR TRIM(shipping_state) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden weder NULL-Werte noch leere oder ausschließlich
aus Leerzeichen bestehende Bundesstaatennamen gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder leerer
Bundesstaatennamen erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 5. orders.shipping_region
-- ============================================================

-- Check 5.1: Vorhandene Kategorien prüfen
-- Erwartung: Central, East, South, West

SELECT
    shipping_region,
    COUNT(*) AS anzahl
FROM orders
GROUP BY shipping_region
ORDER BY shipping_region;

/*
Ergebnis:
Es wurden genau vier Versandregionen gefunden:
Central, East, South und West.

Alle Werte entsprechen den erwarteten Kategorien.

Decision:
Keine Bereinigung von shipping_region erforderlich.
*/

-- Check 5.2: Fehlende oder unerwartete Versandregionen
-- Erwartung: 0 Zeilen

SELECT
    shipping_region,
    COUNT(*) AS anzahl
FROM orders
WHERE shipping_region IS NULL
   OR shipping_region NOT IN (
       'Central', 'East', 'South', 'West'
   )
GROUP BY shipping_region
ORDER BY shipping_region;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
vorgegebenen Versandregionen Central, East, South und
West gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Versandregionen erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 5.3: Leere oder nur aus Leerzeichen bestehende Regionen
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_regionen
FROM orders
WHERE shipping_region IS NOT NULL
  AND TRIM(shipping_region) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Versandregionen gefunden.

Decision:
Keine Bereinigung aufgrund leerer Versandregionen
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 6. orders.shipping_country
-- ============================================================

-- Check 6.1: Vorhandene Kategorien prüfen
-- Erwartung: United States

SELECT
    shipping_country,
    COUNT(*) AS anzahl
FROM orders
GROUP BY shipping_country
ORDER BY shipping_country;

/*
Ergebnis:
Es wurde nur ein Versandland gefunden:
United States.

Der Wert ist konsistent und entspricht der erwarteten Kategorie.

Decision:
Keine Bereinigung von shipping_country erforderlich.
*/

-- Check 6.2: Fehlende oder unerwartete Versandländer
-- Erwartung: 0 Zeilen

SELECT
    shipping_country,
    COUNT(*) AS anzahl
FROM orders
WHERE shipping_country IS NULL
   OR shipping_country <> 'United States'
GROUP BY shipping_country
ORDER BY shipping_country;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb des
vorgegebenen Versandlandes United States gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Versandländer erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 6.3: Leere oder nur aus Leerzeichen bestehende Versandländer
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_laender
FROM orders
WHERE shipping_country IS NOT NULL
  AND TRIM(shipping_country) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Versandländer gefunden.

Decision:
Keine Bereinigung aufgrund leerer Versandländer
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 7. orders.shipping_mode
-- ============================================================

-- Check 7.1: Vorhandene Kategorien prüfen
-- Erwartung: First Class, Same Day, Second Class, Standard Class

SELECT
    shipping_mode,
    COUNT(*) AS anzahl
FROM orders
GROUP BY shipping_mode
ORDER BY shipping_mode;
/*
Ergebnis:
Es wurden genau vier Versandarten gefunden:
First Class, Same Day, Second Class und Standard Class.

Alle Werte entsprechen den erwarteten Kategorien.

Decision:
Keine Bereinigung von shipping_mode erforderlich.
*/

-- Check 7.2: Fehlende oder unerwartete Versandarten
-- Erwartung: 0 Zeilen

SELECT
    shipping_mode,
    COUNT(*) AS anzahl
FROM orders
WHERE shipping_mode IS NULL
   OR shipping_mode NOT IN (
       'First Class', 'Same Day',
       'Second Class', 'Standard Class')
GROUP BY shipping_mode
ORDER BY shipping_mode;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
vorgegebenen Versandarten First Class, Same Day,
Second Class und Standard Class gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Versandarten erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 7.3: Leere oder nur aus Leerzeichen bestehende Versandarten
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_versandarten
FROM orders
WHERE shipping_mode IS NOT NULL
  AND TRIM(shipping_mode) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Versandarten gefunden.

Decision:
Keine Bereinigung aufgrund leerer Versandarten
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 8. orders.shipping_postal_code
-- ============================================================

-- Check 8.1: NULL-Werte prüfen
-- Erwartung: 6 NULL-Werte

SELECT
    COUNT(*) AS null_anzahl
FROM orders
WHERE shipping_postal_code IS NULL;
/*
Ergebnis:
Es wurden 6 NULL-Werte in shipping_postal_code gefunden.

Decision:
Die NULL-Werte werden zunächst genauer untersucht,
bevor eine Bereinigung oder Ersetzung vorgenommen wird.
*/

-- Check 8.2: Kontext der fehlenden Postleitzahlen prüfen
-- Erwartung: 6 Zeilen, entsprechend dem NULL-Count aus Check 8.1
-- Die Ausgabe zeigt die betroffenen Bestellungen und ihren Versandort.

SELECT
    order_id,
    shipping_city,
    shipping_state,
    shipping_postal_code
FROM orders
WHERE shipping_postal_code IS NULL
ORDER BY shipping_city, order_id;
/*
Ergebnis:
Alle 6 NULL-Werte in shipping_postal_code
gehören zu Bestellungen aus Burlington, Vermont.

Decision:
Vor einer Ersetzung wird geprüft, ob für Burlington, Vermont
auch gültige Postleitzahlen im Datensatz vorhanden sind.
*/

-- Check 8.3: Vorhandene Postleitzahlen für Burlington, Vermont prüfen
-- Erwartung gemäß bisherigem Befund: 1 Zeile mit NULL als Postleitzahl
-- DISTINCT fasst die identischen Kombinationen zu einer Zeile zusammen.

SELECT DISTINCT
    shipping_city,
    shipping_state,
    shipping_postal_code
FROM orders
WHERE shipping_city = 'Burlington'
  AND shipping_state = 'Vermont'
ORDER BY shipping_postal_code;
/*
Ergebnis:
Für Burlington, Vermont wurden ausschließlich NULL-Werte
in shipping_postal_code gefunden.

Für diese Stadt ist im Datensatz keine Postleitzahl vorhanden,
aus der die fehlenden Werte zuverlässig abgeleitet werden könnten.

Decision:
Die fehlenden Postleitzahlen werden nicht geschätzt.
Die Originalwerte bleiben NULL.
Für das Reporting werden sie als 'UNKNOWN' gekennzeichnet,
damit die betroffenen Bestellungen in der Auswertung erhalten bleiben.
*/

-- ============================================================
-- 9. product.product_category
-- ============================================================

-- Check 9.1: Vorhandene Kategorien prüfen
-- Erwartung: Furniture, Office Supplies, Technology

SELECT
    product_category,
    COUNT(*) AS anzahl
FROM product
GROUP BY product_category
ORDER BY product_category;

/*
Ergebnis:
Es wurden genau drei Produktkategorien gefunden:
Furniture, Office Supplies und Technology.

Alle Werte entsprechen den erwarteten Kategorien.

Decision:
Keine Bereinigung von product_category erforderlich.
*/

-- Check 9.2: Fehlende oder unerwartete Produktkategorien
-- Erwartung: 0 Zeilen

SELECT
    product_category,
    COUNT(*) AS anzahl
FROM product
WHERE product_category IS NULL
   OR product_category NOT IN (
       'Furniture', 'Office Supplies', 'Technology'
   )
GROUP BY product_category
ORDER BY product_category;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
vorgegebenen Produktkategorien Furniture, Office Supplies
und Technology gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Produktkategorien erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 9.3: Leere oder nur aus Leerzeichen bestehende Produktkategorien
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_kategorien
FROM product
WHERE product_category IS NOT NULL
  AND TRIM(product_category) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Produktkategorien gefunden.

Decision:
Keine Bereinigung aufgrund leerer Produktkategorien
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 10. product.product_subcategory
-- ============================================================

-- Check 10.1: Vorhandene Kategorien prüfen
-- Erwartung: 17 unterschiedliche Subkategorien

SELECT
    product_subcategory,
    COUNT(*) AS anzahl
FROM product
GROUP BY product_subcategory
ORDER BY product_subcategory;
/*
Ergebnis:
Es wurden genau 17 Produkt-Subkategorien gefunden.

Alle Werte entsprechen den erwarteten Kategorien.
Es wurden keine abweichenden Schreibweisen oder zusätzlichen
Subkategorien gefunden.

Decision:
Keine Bereinigung von product_subcategory erforderlich.
*/

-- Check 10.2: Fehlende oder unerwartete Subkategorien
-- Erwartung: 0 Zeilen

SELECT
    product_subcategory,
    COUNT(*) AS anzahl
FROM product
WHERE product_subcategory IS NULL
   OR product_subcategory NOT IN (
       'Paper', 'Binders', 'Phones', 'Furnishings',
       'Art', 'Accessories', 'Storage', 'Appliances',
       'Chairs', 'Labels', 'Machines', 'Tables',
       'Bookcases', 'Envelopes', 'Supplies',
       'Fasteners', 'Copiers')
GROUP BY product_subcategory
ORDER BY product_subcategory;
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
17 vorgegebenen Subkategorien gefunden.

Decision:
Keine Bereinigung aufgrund fehlender oder unerwarteter
Subkategorien erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 10.3: Leere oder nur aus Leerzeichen bestehende Subkategorien
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_subkategorien
FROM product
WHERE product_subcategory IS NOT NULL
  AND TRIM(product_subcategory) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Produkt-Subkategorien gefunden.

Decision:
Keine Bereinigung aufgrund leerer Produkt-Subkategorien
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- 11. product.product_manufacturer
-- ============================================================

-- Check 11.1: Auffällige Herstellerwerte mit "staple" prüfen
-- Unauffälliges Ergebnis für dieses Suchmuster: 0 Zeilen
-- Treffer sind Verdachtsfälle und müssen fachlich geprüft werden.
-- Keine Treffer schließen andere auffällige Herstellerwerte nicht aus.

SELECT DISTINCT
    product_manufacturer
FROM product
WHERE LOWER(product_manufacturer) LIKE '%staple%'
ORDER BY product_manufacturer;
/*
Ergebnis:
Es wurden 9 unterschiedliche Werte in product_manufacturer
gefunden, die eher wie Produktbezeichnungen als
wie Herstellernamen wirken.

Beispiele:
Staple magnet, Staple remover, Easy-staple paper.

Decision:
Die auffälligen Herstellerwerte werden zunächst genauer
untersucht. Eine Bereinigung wird erst nach Prüfung
der zugehörigen Produktdatensätze festgelegt.
*/

-- Check 11.2: Kontext der auffälligen Herstellerwerte prüfen
-- Erwartung gemäß bisherigem Befund: 9 Produktdatensätze
-- Die Ausgabe ermöglicht den Vergleich von Hersteller und Produktname.
-- Die Anzahl der Datensätze wird hier separat geprüft:
-- 9 unterschiedliche Herstellerwerte bedeuten nicht automatisch 9 Produkte.

SELECT
    product_id,
    product_name,
    product_subcategory,
    product_manufacturer
FROM product
WHERE LOWER(product_manufacturer) LIKE '%staple%'
ORDER BY product_manufacturer, product_name;
/*
Ergebnis:
Bei allen 9 auffälligen Datensätzen entspricht
product_manufacturer exakt dem product_name.

Dies deutet darauf hin, dass bei diesen Produkten
Produktnamen im Herstellerfeld gespeichert wurden.

Decision:
Vor einer Bereinigung wird geprüft, ob dieses Muster
auch bei weiteren Produkten vorkommt.
*/

-- Check 11.3: Produktname und Hersteller auf identische Werte prüfen
-- Unauffälliges Ergebnis für dieses Suchmuster: 0 Zeilen
-- Treffer sind Verdachtsfälle, kein Beweis für fehlerhafte Herstellerwerte.
-- Keine Treffer schließen andere auffällige Herstellerwerte nicht aus.

SELECT
    product_id,
    product_name,
    product_subcategory,
    product_manufacturer
FROM product
WHERE product_manufacturer = product_name
ORDER BY product_id;
/*
Ergebnis:
Es wurden 10 Produkte gefunden, bei denen
product_manufacturer exakt dem product_name entspricht.

Neben den 9 bereits auffälligen Staple-Werten
betrifft dies auch das Produkt "Xerox 1971".

Das Muster deutet auf mögliche fehlerhafte Herstellerangaben hin,
beweist jedoch nicht automatisch, dass jeder einzelne Wert falsch ist.

Decision:
Die auffälligen Werte werden nicht überschrieben.
Sie sollen später als potenziell problematische Herstellerangaben
gekennzeichnet werden, damit die Originaldaten erhalten bleiben.
*/

-- Check 11.4: NULL-Werte in product_manufacturer prüfen
-- Erwartung: 0 NULL-Werte

SELECT
    COUNT(*) AS null_anzahl
FROM product
WHERE product_manufacturer IS NULL;
/*
Ergebnis:
Es wurden 0 NULL-Werte in product_manufacturer gefunden.
Leere Zeichenfolgen wurden mit diesem Check nicht geprüft.

Decision:
Keine Bereinigung aufgrund von NULL-Werten erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- Check 11.5: Führende oder nachgestellte Leerzeichen prüfen
-- Erwartung: 0 Zeilen

SELECT DISTINCT
    product_manufacturer
FROM product
WHERE product_manufacturer <> TRIM(product_manufacturer);
/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine führenden oder nachgestellten Leerzeichen
in product_manufacturer gefunden.

Decision:
Keine Bereinigung mit TRIM erforderlich.
*/

-- Check 11.6: Leere oder nur aus Leerzeichen bestehende Herstellerwerte
-- Erwartung: 0

SELECT
    COUNT(*) AS anzahl_leere_hersteller
FROM product
WHERE product_manufacturer IS NOT NULL
  AND TRIM(product_manufacturer) = '';

/*
Ergebnis:
Die Abfrage liefert 0.
Es wurden keine leeren oder ausschließlich aus
Leerzeichen bestehenden Herstellerwerte gefunden.

Decision:
Keine Bereinigung aufgrund leerer Herstellerwerte
erforderlich.
Die vorhandenen Werte bleiben unverändert.
*/

-- ============================================================
-- QUELLE: 05_cleaned_dimensions/cleaning.sql
-- ============================================================
-- ============================================================
-- UNICORN – DIMENSION CLEANING
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die in diagnostic_queries.sql identifizierten
Datenqualitätsprobleme werden für das Reporting
transparent gekennzeichnet.

Bereinigungsregeln:
1. Fehlende Postleitzahlen als 'UNKNOWN' ausgeben.
2. Auffällige Herstellerangaben mit einem Flag markieren.

Die Originaldaten bleiben unverändert.

Hinweis:
Die Abfragen prüfen die jeweiligen Quelltabellen
ohne zusätzliche Business-Scope-Filter.
*/

-- 1. Fehlende Postleitzahlen für das Reporting kennzeichnen

/*
Finding:
6 Bestellungen aus Burlington, Vermont haben keine
shipping_postal_code. Für diese Stadt ist im Datensatz
keine Postleitzahl zur zuverlässigen Ergänzung vorhanden.

Decision:
Die fehlenden Postleitzahlen werden nicht geschätzt.
Für das Reporting wird 'UNKNOWN' ausgegeben und ein
Flag kennzeichnet die fehlenden Werte.
Die Originaldaten bleiben unverändert.
*/

SELECT
    order_id,
    shipping_postal_code,
    COALESCE(
        CAST(shipping_postal_code AS TEXT),
        'UNKNOWN'
    ) AS shipping_postal_code_clean,
    CASE
        WHEN shipping_postal_code IS NULL THEN 1
        ELSE 0
    END AS postal_code_missing_flag
FROM orders
ORDER BY postal_code_missing_flag DESC, order_id;

/*
Ergebnis:
Die Abfrage liefert 5.013 Zeilen.
Die 6 fehlenden Postleitzahlen werden als 'UNKNOWN'
mit postal_code_missing_flag = 1 ausgegeben.

Bei den übrigen 5.007 Zeilen bleibt die Postleitzahl
inhaltlich unverändert; postal_code_missing_flag = 0.
*/

-- 2. Auffällige Herstellerwerte kennzeichnen

/*
Finding:
Bei 10 Produkten entspricht product_manufacturer
dem product_name. Dieses Muster deutet auf mögliche
fehlerhafte Herstellerangaben hin, beweist sie aber nicht.

Decision:
Keine Überschreibung der Herstellerwerte.
Die betroffenen Produkte werden mit einem Quality-Flag
als prüfbedürftig gekennzeichnet.
Das Flag bewertet ausschließlich dieses Suchmuster.
*/

SELECT
    product_id,
    product_name,
    product_manufacturer,
    CASE
        WHEN product_manufacturer = product_name THEN 1
        ELSE 0
    END AS manufacturer_review_flag
FROM product
ORDER BY manufacturer_review_flag DESC, product_id;

/*
Ergebnis:
Die Abfrage liefert 1.850 Produkte.
Bei 10 Produkten entspricht product_manufacturer
dem product_name; manufacturer_review_flag = 1.

Bei den übrigen 1.840 Produkten trifft dieses Suchmuster
nicht zu; manufacturer_review_flag = 0.
Flag 0 bestätigt nicht die allgemeine Richtigkeit
der Herstellerangabe.

Die Herstellerwerte werden unverändert ausgegeben.
*/

-- ============================================================
-- QUELLE: 05_cleaned_dimensions/rules_and_qa.sql
-- ============================================================
-- ============================================================
-- UNICORN – STANDARDIZATION AND QUALITY ASSURANCE
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Produkt-Subkategorien werden nach ihrem
Verwendungszweck gruppiert und durch
zusätzliche Qualitätsprüfungen kontrolliert.

Verwendete Tabellen:
- product
- orders

Business Scope:
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day,
  Second Class und Standard Class

Prüfumfang:
Die Gruppierung und Qualitätsprüfungen erfolgen
auf den jeweiligen Quelltabellen ohne zusätzliche
Business-Scope-Filter.

Vorgehensweise:
1. Produkt-Subkategorien in vier Gruppen einteilen.
2. Anzahl der Produkte je Gruppe kontrollieren.
3. Nicht zugeordnete Produkte identifizieren.
4. Versandregionen auf gültige Werte prüfen.
5. Fehlende Postleitzahlen kontrollieren.

Die Originaldaten bleiben unverändert.
*/

-- ============================================================
-- 1. PRODUKT-SUBKATEGORIEN NACH VERWENDUNGSZWECK GRUPPIEREN
-- ============================================================

/*
Ziel:
Die Subkategorien werden in vier fachliche Gruppen eingeteilt.
Damit lassen sich Umsatz und Gewinn später nach dem
Verwendungszweck der Produkte vergleichen.

Regel:
Writing & Filing: Papier, Schreib- und Ablagematerial.
Furniture & Storage: Möbel, Einrichtung und Aufbewahrung.
Technology: technische Geräte und Zubehör.
Office Essentials: Geräte und allgemeiner Bürobedarf.

Die ursprüngliche Subkategorie bleibt erhalten.
Nicht zugeordnete oder fehlende Werte erhalten 'Other'
und müssen geprüft werden.
*/

-- 1.1: Verwendungsgruppe je Produkt zuordnen
-- Erwartung: 1.850 Produkte und keine Zuordnung zu 'Other'

SELECT
    product_id,
    product_subcategory,
    CASE
        WHEN product_subcategory IN (
            'Paper', 'Binders', 'Art',
            'Labels', 'Envelopes', 'Fasteners'
        ) THEN 'Writing & Filing'

        WHEN product_subcategory IN (
            'Furnishings', 'Storage', 'Chairs',
            'Tables', 'Bookcases'
        ) THEN 'Furniture & Storage'

        WHEN product_subcategory IN (
            'Phones', 'Accessories', 'Machines', 'Copiers'
        ) THEN 'Technology'

        WHEN product_subcategory IN (
            'Appliances', 'Supplies'
        ) THEN 'Office Essentials'

        ELSE 'Other'
    END AS product_usage_group
FROM product
ORDER BY product_usage_group, product_subcategory, product_id;

/*
Ergebnis:
Die Abfrage liefert 1.850 Produkte.
Jedem Produkt wird eine der vier Gruppen zugeordnet.
Kein Produkt erhält die Zuordnung 'Other'.
Die ursprünglichen Subkategorien bleiben unverändert.
*/

-- 1.2: Anzahl der Produkte je Verwendungsgruppe
-- Erwartung: 4 Gruppen mit insgesamt 1.850 Produkten

WITH grouped_products AS (
    SELECT
        product_id,
        CASE
            WHEN product_subcategory IN (
                'Paper', 'Binders', 'Art',
                'Labels', 'Envelopes', 'Fasteners'
            ) THEN 'Writing & Filing'

            WHEN product_subcategory IN (
                'Furnishings', 'Storage', 'Chairs',
                'Tables', 'Bookcases'
            ) THEN 'Furniture & Storage'

            WHEN product_subcategory IN (
                'Phones', 'Accessories', 'Machines', 'Copiers'
            ) THEN 'Technology'

            WHEN product_subcategory IN (
                'Appliances', 'Supplies'
            ) THEN 'Office Essentials'

            ELSE 'Other'
        END AS product_usage_group
    FROM product)
SELECT
    product_usage_group,
    COUNT(*) AS product_count
FROM grouped_products
GROUP BY product_usage_group
ORDER BY product_count DESC;

/*
Ergebnis:
Die Abfrage liefert 4 Gruppen:

Writing & Filing: 793 Produkte
Furniture & Storage: 512 Produkte
Technology: 412 Produkte
Office Essentials: 133 Produkte

Die Summe beträgt 1.850 Produkte.
Die Gruppe 'Other' kommt im aktuellen Ergebnis nicht vor.
*/

-- ============================================================
-- 2. QUALITÄTSSICHERUNG
-- ============================================================

-- 2.1: Produkte ohne bekannte Verwendungsgruppe
-- Erwartung: 0 Zeilen
-- Bei Treffern: Subkategorie prüfen und die Zuordnungsregel
-- bei Bedarf fachlich begründet ergänzen.

WITH grouped_products AS (
    SELECT
        product_id,
        product_subcategory,
        CASE
            WHEN product_subcategory IN (
                'Paper', 'Binders', 'Art',
                'Labels', 'Envelopes', 'Fasteners'
            ) THEN 'Writing & Filing'

            WHEN product_subcategory IN (
                'Furnishings', 'Storage', 'Chairs',
                'Tables', 'Bookcases'
            ) THEN 'Furniture & Storage'

            WHEN product_subcategory IN (
                'Phones', 'Accessories', 'Machines', 'Copiers'
            ) THEN 'Technology'

            WHEN product_subcategory IN (
                'Appliances', 'Supplies'
            ) THEN 'Office Essentials'

            ELSE 'Other'
        END AS product_usage_group
    FROM product)
SELECT
    product_id,
    product_subcategory,
    product_usage_group
FROM grouped_products
WHERE product_usage_group = 'Other'
ORDER BY product_id;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Kein Produkt erhält die Zuordnung 'Other'.

Alle Produkte werden von der aktuellen Zuordnungsregel
einer bekannten Verwendungsgruppe zugeordnet.
*/

-- 2.2: Versandregionen auf gültige Werte prüfen
-- Erwartung: 0 Zeilen
-- Bei Treffern: Fehlende oder neue Regionswerte untersuchen.
-- Die erlaubten Werte nur bei fachlicher Begründung erweitern.

SELECT
    shipping_region,
    COUNT(*) AS anzahl
FROM orders
WHERE shipping_region IS NULL
   OR shipping_region NOT IN (
       'Central', 'East', 'South', 'West'
   )
GROUP BY shipping_region
ORDER BY shipping_region;

/*
Ergebnis:
Die Abfrage liefert 0 Zeilen.
Es wurden keine NULL-Werte oder Werte außerhalb der
vorgegebenen Versandregionen Central, East, South und
West gefunden.

Die geprüfte Bedingung ist im aktuellen Datenbestand erfüllt.
*/

-- 2.3: NULL-Anzahl der Postleitzahlen prüfen
-- Erwartung: Eine Ergebniszeile mit null_anzahl = 6
-- Bei abweichendem Wert: Datenänderung untersuchen und prüfen,
-- ob die bisherige Reporting-Regel weiterhin angemessen ist.
-- Den Erwartungswert nicht ohne Prüfung anpassen.

SELECT
    COUNT(*) AS null_anzahl
FROM orders
WHERE shipping_postal_code IS NULL;

/*
Ergebnis:
Die Abfrage liefert eine Zeile mit null_anzahl = 6.
Die Anzahl fehlender Postleitzahlen entspricht
dem erwarteten Wert.

Die geprüfte Bedingung ist im aktuellen Datenbestand erfüllt.
*/

-- ============================================================
-- QUELLE: 06_reporting_stack/stack.sql
-- ============================================================
-- ============================================================
-- UNICORN – GEMEINSAMER REPORTING STACK
-- ============================================================

/*
Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19

Ziel:
Die bisherigen Projektschritte werden zu einem
gemeinsamen Reporting-Stack verbunden.
Die fünf definierten KPIs werden auf einer
einheitlichen Datenbasis berechnet.

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

Vorgehensweise:
1. base           – Canonical Join + Cleaning
2. Aggregationen  – Umsatz- und Gewinnsummen
3. Vorjahreswerte – Vergleich mit LAG()
4. reporting      – Gemeinsame Aggregatstruktur
5. Final SELECT   – KPI-Berechnung, Sortierung und Rundung

Ergebnisarten:
- region_year    – Umsatzwachstum nach Region und Jahr
- category_total – Umsatz und Gewinnmarge nach Kategorie
- segment_year   – Umsatzwachstum nach Segment und Jahr
- segment_total  – Gesamtumsatz nach Kundensegment

Wichtig:
Alle Ergebnisarten verwenden dieselbe Datenbasis.
Die Umsätze dürfen nicht über die verschiedenen
Ergebnisarten hinweg addiert werden.

NULL bedeutet:
Eine Kennzahl ist nicht vorgesehen oder ein
Vergleich ist nicht berechenbar.
Bei Gesamtzeilen ist order_year NULL,
da diese den gesamten Zeitraum 2015–2018 umfassen.

Die Originaldaten bleiben unverändert.
*/

-- ============================================================
-- LAYER 1 – BASE
-- Grain: Eine Zeile entspricht einer Bestellposition.
-- ============================================================

WITH base AS (

    SELECT
        od.order_details_id,
        od.order_id,
        od.product_id,
        od.quantity,
        od.order_discount,
        od.order_sales,
        od.order_profits,
        od.order_profit_ratio,

        o.customer_id,
        o.order_date,
        o.shipping_city,
        o.shipping_state,
        o.shipping_region,
        o.shipping_country,
        o.shipping_postal_code,

        -- BIGINT in Text umwandeln, damit UNKNOWN darstellbar ist.
        COALESCE(
            o.shipping_postal_code::text,
            'UNKNOWN'
        ) AS shipping_postal_code_clean,

        o.shipping_date,
        o.shipping_mode,

        c.customer_name,
        c.customer_segment,

        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.product_manufacturer,

        -- Prüft die exakte Übereinstimmung.
        -- Fehlende Herstellerwerte werden nicht gesondert geprüft.
        CASE
            WHEN p.product_manufacturer = p.product_name
                THEN 'CHECK'
            ELSE 'OK'
        END AS manufacturer_quality_flag

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
-- LAYER 2 – AGGREGATIONEN
-- ============================================================

-- Grain: Eine Region in einem Kalenderjahr.
-- ------------------------------------------------------------
-- region_yearly_sales: Summiert Umsatz und zählt Positionen je Region und Jahr.
-- ------------------------------------------------------------
region_yearly_sales AS (

    SELECT
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer
),

-- Grain: Eine Produktkategorie über 2015–2018.
-- ------------------------------------------------------------
-- category_totals: Summiert Umsatz und Gewinn je Kategorie über 2015–2018.
-- ------------------------------------------------------------
category_totals AS (

    SELECT
        product_category,
        SUM(order_sales)::numeric AS total_sales,
        SUM(order_profits)::numeric AS total_profits,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count,
        COUNT(*) FILTER (
            WHERE order_profits IS NULL
        ) AS missing_profit_count

    FROM base

    GROUP BY
        product_category
),

-- Grain: Ein Kundensegment in einem Kalenderjahr.
-- ------------------------------------------------------------
-- segment_yearly_sales: Summiert Umsatz und zählt Positionen je Segment und Jahr.
-- ------------------------------------------------------------
segment_yearly_sales AS (

    SELECT
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer
),

-- Grain: Ein Kundensegment über 2015–2018.
-- Additive Kennzahlen werden aus den Jahressummen übernommen.
-- ------------------------------------------------------------
-- segment_totals: Fasst die Jahresaggregate je Segment über 2015–2018 zusammen.
-- ------------------------------------------------------------
segment_totals AS (

    SELECT
        customer_segment,
        SUM(total_sales) AS total_sales,
        SUM(position_count)::bigint AS position_count,
        SUM(missing_sales_count)::bigint AS missing_sales_count

    FROM segment_yearly_sales

    GROUP BY
        customer_segment
),

-- ============================================================
-- LAYER 3 – VORJAHRESWERTE
-- ============================================================

-- ------------------------------------------------------------
-- region_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Region und Jahr.
-- ------------------------------------------------------------
region_previous_sales AS (

    SELECT
        shipping_region,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM region_yearly_sales
),

-- ------------------------------------------------------------
-- segment_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Segment und Jahr.
-- ------------------------------------------------------------
segment_previous_sales AS (

    SELECT
        customer_segment,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM segment_yearly_sales
),

-- ============================================================
-- LAYER 4 – GEMEINSAME ERGEBNISSTRUKTUR
-- UNION ALL erhält die getrennten Auswertungsperspektiven.
-- ============================================================

-- ------------------------------------------------------------
-- reporting: Vereinheitlicht Aggregate; Grain: Ergebnisart, Dimension und ggf. Jahr.
-- ------------------------------------------------------------
reporting AS (

    -- KPI 1: Umsatzwachstum nach Region
    SELECT
        'region_year'::text AS report_type,
        shipping_region AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,

        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM region_previous_sales

    UNION ALL

    -- KPI 2 und 3: Kategorieumsatz und Gewinnmarge
    SELECT
        'category_total'::text AS report_type,
        product_category AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        total_profits,

        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        missing_profit_count

    FROM category_totals

    UNION ALL

    -- KPI 4: Gesamtumsatz nach Kundensegment
    SELECT
        'segment_total'::text AS report_type,
        customer_segment AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        NULL::numeric AS total_profits,
        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_totals

    UNION ALL

    -- KPI 5: Umsatzwachstum nach Kundensegment
    SELECT
        'segment_year'::text AS report_type,
        customer_segment AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,

        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_previous_sales
)

-- ============================================================
-- FINAL SELECT
-- Berechnet abgeleitete KPIs ohne neue Aggregationen.
-- Rundung erst für die Ausgabe.
-- ============================================================

SELECT
    report_type,
    dimension_value,
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_profits, 2) AS total_profits,
    -- Marge aus Summen; fehlende Eingangswerte ergeben keine Marge.
    CASE
        WHEN report_type = 'category_total'
         AND missing_sales_count = 0
         AND missing_profit_count = 0
        THEN ROUND(total_profits / NULLIF(total_sales, 0) * 100, 2)
        ELSE NULL
    END AS profit_margin_percent,
    previous_year,
    ROUND(previous_year_sales, 2) AS previous_year_sales,
    -- Nur direkte Vorjahre vergleichen; NULLIF schützt vor Division durch 0.
    CASE
        WHEN report_type IN ('region_year', 'segment_year')
         AND previous_year = order_year - 1
         AND missing_sales_count = 0
         AND previous_missing_sales_count = 0
        THEN ROUND(
            (total_sales - previous_year_sales)
            / NULLIF(previous_year_sales, 0) * 100, 2
        )
        ELSE NULL
    END AS sales_growth_percent,
    position_count,
    missing_sales_count,
    missing_profit_count

FROM reporting

ORDER BY
    CASE report_type
        WHEN 'region_year' THEN 1
        WHEN 'category_total' THEN 2
        WHEN 'segment_total' THEN 3
        WHEN 'segment_year' THEN 4
    END,
    dimension_value,
    order_year NULLS LAST;
/*
Ergebnisprüfung:
Die Ausgabe enthält 34 Zeilen und 12 Spalten.
Der vollständige Vergleich mit der geprüften Referenzausgabe
ergibt keine Abweichungen bei Werten oder NULL-Feldern.

Jede Ergebnisart umfasst für sich 9.997 Positionen
und einen Gesamtumsatz von 2.307.249.
Alle 21 Wachstumsraten und drei Kategorie-Gewinnmargen
bleiben nach der Umstrukturierung unverändert.

Die Verlagerung der KPI-Berechnungen in den finalen SELECT
verändert die Ergebnisse nicht.
*/

-- ============================================================
-- QUELLE: 06_reporting_stack/parameterized_stack.sql
-- ============================================================
-- ============================================================
-- UNICORN – PARAMETRISIERTER REPORTING STACK
-- ============================================================

/*
Datenquellen: customers, orders, order_details, product
Verantwortlich: Suryandi
SQL-Dialekt: PostgreSQL

Stakeholder-Frage:
Wo sollten wir den Fokus für weiteres Wachstum setzen?

Business Scope:
Bestellungen von 2015 bis 2018
Versandland: United States
Region: über parameters.region_filter wählbar (Standard: all)
Versandarten: First Class, Same Day,
Second Class und Standard Class

Aufbau:
0. parameters     – Regionsauswahl
1. base           – Canonical Join + Cleaning
2. Aggregationen  – Umsatz- und Gewinnsummen
3. Vorjahreswerte – Vergleich mit LAG()
4. reporting      – Gemeinsame Aggregatstruktur
5. Final SELECT   – KPI-Berechnung, Sortierung und Rundung

Ergebnisarten:
region_year   – Region und Jahr: Umsatzwachstum
category_total – Kategorie: Umsatz und Gewinnmarge, 2015–2018
segment_year  – Kundensegment und Jahr: Umsatzwachstum
segment_total – Kundensegment: Gesamtumsatz, 2015–2018

Wichtig:
Die Ergebnisarten betrachten dieselbe Datenbasis aus
unterschiedlichen Perspektiven. Ihre Umsätze dürfen
nicht über alle Ergebnisarten hinweg addiert werden.

NULL bedeutet:
Kennzahl nicht vorgesehen oder Vergleich nicht berechenbar.
Bei Gesamtzeilen ist order_year NULL, da sie 2015–2018 umfassen.
*/

-- ============================================================
-- FILTERSTEUERUNG
-- Anschließend folgen Base, Aggregationen und KPI-Ausgabe.
-- ============================================================

-- ============================================================
-- PARAMETER – Eine Zeile mit dem gewünschten Regionsfilter.
-- Zulässig: all, Central, East, South, West (Schreibweise beachten).
-- all deaktiviert nur den Regionsfilter; der Business Scope bleibt gültig.
-- Beispiel: 'West' statt 'all' für die Auswertung der Region West.
-- ============================================================
WITH parameters AS (
    SELECT 'all'::text AS region_filter
),

-- ============================================================
-- BASE – Join und Cleaning; eine Zeile je Bestellposition.
-- ============================================================
base AS (

    SELECT
        od.order_details_id,
        od.order_id,
        od.product_id,
        od.quantity,
        od.order_discount,
        od.order_sales,
        od.order_profits,
        od.order_profit_ratio,

        o.customer_id,
        o.order_date,
        o.shipping_city,
        o.shipping_state,
        o.shipping_region,
        o.shipping_country,
        o.shipping_postal_code,

        -- BIGINT in Text umwandeln, damit UNKNOWN darstellbar ist.
        COALESCE(
            o.shipping_postal_code::text,
            'UNKNOWN'
        ) AS shipping_postal_code_clean,

        o.shipping_date,
        o.shipping_mode,

        c.customer_name,
        c.customer_segment,

        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.product_manufacturer,

        -- Prüft die exakte Übereinstimmung.
        -- Fehlende Herstellerwerte werden nicht gesondert geprüft.
        CASE
            WHEN p.product_manufacturer = p.product_name
                THEN 'CHECK'
            ELSE 'OK'
        END AS manufacturer_quality_flag

    FROM order_details AS od

    JOIN orders AS o
        ON od.order_id = o.order_id

    JOIN customers AS c
        ON o.customer_id = c.customer_id

    JOIN product AS p
        ON od.product_id = p.product_id

    -- Genau eine Parameterzeile: Der CROSS JOIN vervielfacht keine Positionen.
    CROSS JOIN parameters AS prm

    WHERE (prm.region_filter = 'all'
           OR o.shipping_region = prm.region_filter)
      AND o.order_date >= DATE '2015-01-01'
      AND o.order_date < DATE '2019-01-01'
      AND o.shipping_country = 'United States'
      AND o.shipping_mode IN (
          'First Class',
          'Same Day',
          'Second Class',
          'Standard Class')),

-- ============================================================
-- LAYER 2 – AGGREGATIONEN
-- ============================================================

-- Grain: Eine Region in einem Kalenderjahr.
-- ------------------------------------------------------------
-- region_yearly_sales: Summiert Umsatz und zählt Positionen je Region und Jahr.
-- ------------------------------------------------------------
region_yearly_sales AS (

    SELECT
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        shipping_region,
        EXTRACT(YEAR FROM order_date)::integer),

-- Grain: Eine Produktkategorie über 2015–2018.
-- ------------------------------------------------------------
-- category_totals: Summiert Umsatz und Gewinn je Kategorie über 2015–2018.
-- ------------------------------------------------------------
category_totals AS (

    SELECT
        product_category,
        SUM(order_sales)::numeric AS total_sales,
        SUM(order_profits)::numeric AS total_profits,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count,
        COUNT(*) FILTER (
            WHERE order_profits IS NULL
        ) AS missing_profit_count

    FROM base

    GROUP BY
        product_category),

-- Grain: Ein Kundensegment in einem Kalenderjahr.
-- ------------------------------------------------------------
-- segment_yearly_sales: Summiert Umsatz und zählt Positionen je Segment und Jahr.
-- ------------------------------------------------------------
segment_yearly_sales AS (

    SELECT
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer AS order_year,
        SUM(order_sales)::numeric AS total_sales,
        COUNT(*) AS position_count,
        COUNT(*) FILTER (
            WHERE order_sales IS NULL
        ) AS missing_sales_count

    FROM base

    GROUP BY
        customer_segment,
        EXTRACT(YEAR FROM order_date)::integer),

-- Grain: Ein Kundensegment über 2015–2018.
-- Additive Kennzahlen werden aus den Jahressummen übernommen.
-- ------------------------------------------------------------
-- segment_totals: Fasst die Jahresaggregate je Segment über 2015–2018 zusammen.
-- ------------------------------------------------------------
segment_totals AS (

    SELECT
        customer_segment,
        SUM(total_sales) AS total_sales,
        SUM(position_count)::bigint AS position_count,
        SUM(missing_sales_count)::bigint AS missing_sales_count

    FROM segment_yearly_sales

    GROUP BY
        customer_segment),

-- ============================================================
-- LAYER 3 – VORJAHRESWERTE
-- ============================================================

-- ------------------------------------------------------------
-- region_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Region und Jahr.
-- ------------------------------------------------------------
region_previous_sales AS (

    SELECT
        shipping_region,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY shipping_region
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM region_yearly_sales),

-- ------------------------------------------------------------
-- segment_previous_sales: Ergänzt vorherige Jahreswerte; Grain bleibt Segment und Jahr.
-- ------------------------------------------------------------
segment_previous_sales AS (

    SELECT
        customer_segment,
        order_year,
        total_sales,
        position_count,
        missing_sales_count,

        LAG(order_year) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_year_sales,

        LAG(missing_sales_count) OVER (
            PARTITION BY customer_segment
            ORDER BY order_year
        ) AS previous_missing_sales_count

    FROM segment_yearly_sales),

-- ============================================================
-- LAYER 4 – GEMEINSAME ERGEBNISSTRUKTUR
-- UNION ALL erhält die getrennten Auswertungsperspektiven.
-- ============================================================

-- ------------------------------------------------------------
-- reporting: Vereinheitlicht Aggregate; Grain: Ergebnisart, Dimension und ggf. Jahr.
-- ------------------------------------------------------------
reporting AS (

    -- KPI 1: Umsatzwachstum nach Region
    SELECT
        'region_year'::text AS report_type,
        shipping_region AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,

        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM region_previous_sales

    UNION ALL

    -- KPI 2 und 3: Kategorieumsatz und Gewinnmarge
    SELECT
        'category_total'::text AS report_type,
        product_category AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        total_profits,

        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        missing_profit_count

    FROM category_totals

    UNION ALL

    -- KPI 4: Gesamtumsatz nach Kundensegment
    SELECT
        'segment_total'::text AS report_type,
        customer_segment AS dimension_value,
        NULL::integer AS order_year,
        total_sales,
        NULL::numeric AS total_profits,
        NULL::integer AS previous_year,
        NULL::numeric AS previous_year_sales,
        NULL::bigint AS previous_missing_sales_count,
        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_totals

    UNION ALL

    -- KPI 5: Umsatzwachstum nach Kundensegment
    SELECT
        'segment_year'::text AS report_type,
        customer_segment AS dimension_value,
        order_year,
        total_sales,
        NULL::numeric AS total_profits,
        previous_year,
        previous_year_sales,
        previous_missing_sales_count,

        position_count,
        missing_sales_count,
        NULL::bigint AS missing_profit_count

    FROM segment_previous_sales)

-- ============================================================
-- FINAL SELECT
-- Berechnet abgeleitete KPIs ohne neue Aggregationen.
-- Rundung erst für die Ausgabe.
-- ============================================================

SELECT
    report_type,
    dimension_value,
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_profits, 2) AS total_profits,
    -- Marge aus Summen; fehlende Eingangswerte ergeben keine Marge.
    CASE
        WHEN report_type = 'category_total'
         AND missing_sales_count = 0
         AND missing_profit_count = 0
        THEN ROUND(total_profits / NULLIF(total_sales, 0) * 100, 2)
        ELSE NULL
    END AS profit_margin_percent,
    previous_year,
    ROUND(previous_year_sales, 2) AS previous_year_sales,
    -- Nur direkte Vorjahre vergleichen; NULLIF schützt vor Division durch 0.
    CASE
        WHEN report_type IN ('region_year', 'segment_year')
         AND previous_year = order_year - 1
         AND missing_sales_count = 0
         AND previous_missing_sales_count = 0
        THEN ROUND(
            (total_sales - previous_year_sales)
            / NULLIF(previous_year_sales, 0) * 100, 2
        )
        ELSE NULL
    END AS sales_growth_percent,
    position_count,
    missing_sales_count,
    missing_profit_count

FROM reporting

ORDER BY
    CASE report_type
        WHEN 'region_year' THEN 1
        WHEN 'category_total' THEN 2
        WHEN 'segment_total' THEN 3
        WHEN 'segment_year' THEN 4
    END,
    dimension_value,
    order_year NULLS LAST;

/*
Ergebnisprüfung – Regionsfilter all:

Die Ausgabe enthält 34 Zeilen und 12 Spalten.

Jede der vier Ergebnisarten umfasst für sich
9.997 Bestellpositionen und einen Gesamtumsatz
von 2.307.249.

Die Ausgabe enthält:
- 16 Region-Jahr-Ergebnisse
- 3 Kategorie-Gesamtergebnisse
- 3 Segment-Gesamtergebnisse
- 12 Segment-Jahr-Ergebnisse

Interpretation:
Der Parameterwert all deaktiviert den Regionsfilter.
Alle vier Regionen werden berücksichtigt.

Die Kontrollsummen stimmen zwischen den
vier Ergebnisarten überein.
Es fehlen keine Umsatzwerte.

Die verschiedenen Ergebnisarten dürfen nicht
miteinander addiert werden, da sie dieselbe
Datenbasis unterschiedlich darstellen.

Die Originaldaten bleiben unverändert.
*/

-- ============================================================
-- QUELLE: 07_analysis/trend_and_ranking.sql
-- ============================================================
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

Land und Versandarten entsprechen dem Reporting-Stack unter 06_reporting_stack/.
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

-- ============================================================
-- QUELLE: 07_analysis/stretch.sql
-- ============================================================
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

-- ============================================================
-- QUELLE: 07_analysis/explain_review.sql
-- ============================================================
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

-- ============================================================
-- QUELLE: 08_delivery/final_queries.sql
-- ============================================================
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
