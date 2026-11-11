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