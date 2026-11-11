# Unicorn – JOIN Comparison

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi 

## 1. Ziel

Ziel ist es, `INNER JOIN` und `LEFT JOIN` zwischen den Tabellen `order_details` und `orders` zu vergleichen.

Dabei wird geprüft, ob beim `INNER JOIN` Bestellpositionen verloren gehen.

## 2. Datengrundlage

**Verwendete Tabellen:**
- `order_details`
- `orders`

**Business Scope des Projekts:**
- Zeitraum: 2015–2018
- Land: United States
- Versandarten: First Class, Same Day, Second Class und Standard Class

**Prüfumfang:**

Die JOIN-Prüfungen wurden auf den vollständigen Quelltabellen ohne zusätzliche Business-Scope-Filter durchgeführt.

## 3. Ergebnisse

| Prüfung | Ergebnis |
|---|---:|
| INNER JOIN | 9.997 Zeilen |
| LEFT JOIN | 9.997 Zeilen |
| Differenz | 0 Zeilen |
| Bestellpositionen ohne passende Bestellung | 0 |

## 4. Interpretation

Der `INNER JOIN` und der `LEFT JOIN` liefern jeweils 9.997 Bestellpositionen. Die Differenz beträgt 0 Zeilen.

Die zusätzliche Prüfung zeigt, dass keine Bestellposition ohne passende Bestellung existiert.

Damit gibt es in den geprüften Daten keinen Hinweis darauf, dass durch den `INNER JOIN` Bestellpositionen verloren gehen.

Der Vergleich allein prüft jedoch nicht die vollständige Qualität aller JOIN-Beziehungen im Datenmodell.

## 5. Entscheidung

Für die Verbindung zwischen `order_details` und `orders` wird weiterhin ein `INNER JOIN` verwendet.

**Begründung:**

Alle geprüften Bestellpositionen besitzen eine passende Bestellung. Der `INNER JOIN` bildet diese Beziehung ab, ohne Bestellpositionen auszuschließen.

Die Entscheidung ist mit den Ergebnissen aus `join_comparison.sql` nachvollziehbar dokumentiert.

## 6. Grenzen

Die Prüfung bezieht sich ausschließlich auf die Beziehung zwischen `order_details` und `orders`.

Die Beziehungen zu `customers` und `product` sind nicht Bestandteil dieses Vergleichs. Sie werden separat in `join_validation.sql` geprüft.

Die Ergebnisse gelten für den untersuchten Datenbestand und müssen bei Datenänderungen erneut kontrolliert werden.