# Unicorn – QA Findings

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi  
**Stand:** 22. Oktober 2026

Diese Datei dokumentiert die wichtigsten Auffälligkeiten,
die während der QA-Prüfung der Unicorn-Daten gefunden wurden.

Die Findings beschreiben, was in den Daten festgestellt wurde.
Mögliche Ursachen werden an dieser Stelle nicht angenommen.


## Finding 1 – Auffällige Postleitzahlen

In der Tabelle `orders` wurden insgesamt 219 auffällige
Postleitzahlen gefunden.

Davon haben 213 Bestellungen eine `shipping_postal_code`
mit nur 4 Stellen.

Bei weiteren 6 Bestellungen fehlt die Postleitzahl vollständig.

Dadurch können Analysen auf Postleitzahl-Ebene
unvollständig oder ungenau sein.


## Finding 2 – Negative Gewinne

In der Tabelle `order_details` wurden 1.864 Bestellpositionen
mit negativem Gewinn (`order_profits < 0`) gefunden.

Das entspricht rund 18,65 % aller 9.997 Bestellpositionen.

Negative Gewinne sind nicht automatisch ein Datenfehler,
sie sind jedoch für die spätere Profitabilitätsanalyse
besonders relevant.


## Finding 3 – Herstellerwert "Other"

In der Tabelle `product` wurden 356 Produkte
mit dem Herstellerwert `Other` gefunden.

`Other` ist kein fehlender Wert,
nennt jedoch keinen konkreten Hersteller.

Dadurch können spätere Analysen nach Hersteller
weniger genau sein.


## Finding 4 – Kunden ohne Bestellung

In der Tabelle `customers` gibt es 2 Kunden,
für die keine zugehörige Bestellung in `orders` vorhanden ist.

Das ist nicht automatisch ein Datenfehler.

Bei späteren Kundenanalysen sollte jedoch berücksichtigt werden,
ob Kunden ohne Bestellungen einbezogen oder ausgeschlossen werden.


## Finding 5 – Nur ein Versandland

In der Tabelle `orders` stammen alle Bestellungen
aus den United States.

Es wurden keine Bestellungen aus anderen Ländern gefunden.

Dadurch beziehen sich geografische Analysen in diesem Projekt
ausschließlich auf den US-Markt.