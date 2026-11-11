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
