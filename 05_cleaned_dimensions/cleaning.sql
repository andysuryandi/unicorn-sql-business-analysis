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