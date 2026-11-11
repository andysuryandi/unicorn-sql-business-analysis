# Unicorn – Data Risks



Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19
Zeitraum: 2015–2018



## 1\. Missing Shipping Postal Codes

**Risk:** In der Tabelle `orders` fehlen bei 6 Bestellungen die Werte für `shipping\\\_postal\\\_code`.

**Implication:** Analysen auf Postleitzahl-Ebene könnten dadurch unvollständig sein.

**Confirmed by:** Eine Prüfung der fehlenden Werte in `shipping\\\_postal\\\_code` zeigte 6 fehlende Werte; alle betreffen Burlington, Vermont.



## 2\. Manufacturer "Other"

**Risk:** In der Tabelle `product` haben 356 Produkte in der Spalte `product\\\_manufacturer` den Wert "Other".

**Implication:** Analysen nach Hersteller könnten weniger genau sein, da "Other" keinen konkreten Hersteller bezeichnet.

**Confirmed by:** Eine Prüfung von `product\\\_manufacturer` zeigte 356 Produkte mit dem Wert "Other".



## 3\. Negative Profits

**Risk:** In der Tabelle `order\\\_details` enthält die Spalte `order\\\_profits` negative Werte.

**Implication:** Negative Gewinne können die Gesamtprofitabilität beeinflussen und sollten bei späteren Analysen genauer untersucht werden.

**Confirmed by:** Eine Prüfung der niedrigsten Werte in `order\\\_profits` zeigte negative Gewinnwerte.



## 4\. Customers Without Orders

**Risk:** In der Tabelle `customers` gibt es 2 Kunden, für die keine Bestellung in `orders` vorhanden ist.

**Implication:** Kundenanalysen können unterschiedliche Ergebnisse liefern, je nachdem, ob Kunden ohne Bestellungen berücksichtigt werden.

**Confirmed by:** Eine Prüfung der `customer\\\_id` zwischen `customers` und `orders` zeigte 2 Kunden ohne zugehörige Bestellung.



## Konkrete Auswirkungen auf die finale Analyse

Fehlende und kurze Postleitzahlen schränken feinräumige Analysen ein, nicht die Gruppierung nach vorhandener Region in Q2/Q3. Q4 rekonstruiert einen hypothetischen Umsatz ohne Rabatt und beweist keinen entgangenen Umsatz. Q5/Q6 untersuchen negative Bestellmargen; Produktmix und Rabattselektion verhindern einen kausalen Schluss. Herstellerauffälligkeiten betreffen spätere Herstelleranalysen; die finale Kategorieanalyse verwendet product\_category.

