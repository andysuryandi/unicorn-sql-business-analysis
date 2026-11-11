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