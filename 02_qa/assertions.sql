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