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