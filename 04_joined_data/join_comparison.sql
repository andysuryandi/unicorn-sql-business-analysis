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





