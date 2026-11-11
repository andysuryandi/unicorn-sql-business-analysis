# Unicorn – Business Slice Notes
 
**Erstellt von:** Suryandi  
**Stand:** 22. Oktober 2026

## 1\. Zeitraum

**Included:**  
Bestellungen aus dem Zeitraum 2015 bis 2018.

**Excluded:**  
Bestellungen außerhalb dieses Zeitraums.  
Im vorhandenen Datensatz gibt es jedoch keine Bestellungen außerhalb von 2015–2018.

**Reason:**  
Die Prüfung der Tabelle `orders` zeigte, dass die Bestellungen
vom 03.01.2015 bis zum 30.12.2018 reichen.
Damit entspricht der gewählte Zeitraum dem vollständigen
vorhandenen Bestelldatensatz.



## 2\. Geografie

**Included:**  
Bestellungen aus den United States.

**Excluded:**  
Bestellungen aus anderen Ländern.  
Im vorhandenen Datensatz gibt es jedoch keine Bestellungen außerhalb der United States.

**Reason:**  
Die Prüfung von `shipping_country` zeigte,
dass alle Bestellungen aus den United States stammen.
Daher werden keine vorhandenen Bestellungen
durch diesen Filter ausgeschlossen.



## 3\. Versandarten

**Included:**  
First Class, Same Day, Second Class und Standard Class.

**Excluded:**  
Andere oder ungültige Versandarten.  
Im vorhandenen Datensatz wurden jedoch keine weiteren Versandarten gefunden.

**Reason:**  
Die Prüfung von `shipping_mode` zeigte genau vier verschiedene Versandarten: 
First Class, Same Day, Second Class und Standard Class. 
Weitere Versandarten wurden im vorhandenen Datensatz nicht festgestellt.



## 4\. Fehlende Postleitzahlen

**Included:**  
Auch die 6 Bestellungen ohne `shipping_postal_code`
bleiben im Business Slice enthalten.

**Excluded:**  
Keine Bestellungen werden allein wegen einer
fehlenden Postleitzahl ausgeschlossen.

**Reason:**  
Die betroffenen Bestellungen können weiterhin über
Stadt, Bundesstaat und Region analysiert werden.
Die fehlende Postleitzahl verhindert daher die
allgemeine Verkaufsanalyse nicht.



## Zusammenfassung

Der Business Slice enthält 5.013 Bestellungen aus den Jahren
2015–2018 aus den United States. Alle vier vorhandenen
Versandarten sind enthalten.

Es wurden keine Bestellungen aus dem Analyseumfang ausgeschlossen.
Die 6 Bestellungen ohne `shipping_postal_code` bleiben enthalten,
da sie für die allgemeine Analyse weiterhin verwendet werden können.

