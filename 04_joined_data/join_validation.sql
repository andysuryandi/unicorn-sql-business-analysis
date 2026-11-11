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