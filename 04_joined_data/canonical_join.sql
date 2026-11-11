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
