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






