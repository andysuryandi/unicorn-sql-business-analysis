# Unicorn – Join Validation Notes

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi 

## Check 1 – Row Count

**Ergebnis:**  
Vor dem vollständigen Canonical Join: 9.997 Bestellpositionen.  
Nach dem vollständigen Canonical Join: 9.997 Zeilen.

**Interpretation:**  
Die Zeilenanzahl bleibt unverändert. Der Vergleich allein schließt nicht aus, dass einzelne Bestellpositionen verloren gehen und andere vervielfacht werden. Die ergänzenden Schlüssel- und Referenzprüfungen in Check 2 und Check 3 bestätigen jedoch, dass die erforderlichen JOIN-Beziehungen eindeutig und vollständig sind.


## Check 2 – Duplicate Detection

**Ergebnis:**  
- `orders.order_id`: 0 Duplikate  
- `customers.customer_id`: 0 Duplikate  
- `product.product_id`: 0 Duplikate  

**Interpretation:**  
Alle Join-Schlüssel auf der One-Seite sind eindeutig. Es gibt keinen Hinweis auf eine Zeilenvervielfachung durch doppelte Schlüssel.


## Check 3 – Anti-Join / Orphan References

**Ergebnis:**  
- Bestellpositionen ohne passende Bestellung: 0  
- Bestellpositionen ohne passenden Kunden: 0  
- Bestellpositionen ohne passendes Produkt: 0  

**Interpretation:**  
Es wurden keine verwaisten Referenzen gefunden. Alle für den Canonical Join benötigten Beziehungen sind vollständig.


## Fazit

Der Canonical Join liefert 9.997 Bestellpositionen innerhalb des definierten Business Scope (2015–2018, United States und vier Versandarten).

Die Prüfungen zeigen keine doppelten JOIN-Schlüssel auf der One-Seite und keine verwaisten Referenzen. Damit ist bestätigt, dass die Bestellpositionen durch die Tabellenverbindungen weder verloren gehen noch vervielfacht werden.

Der Canonical Join ist somit eine geeignete und validierte Grundlage für die weitere Analyse und das Reporting.