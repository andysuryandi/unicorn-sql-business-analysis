# Unicorn – Before/After Cleaning

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi 

## 1\. Fehlende Postleitzahlen

### Befund und Regel

In der Tabelle `orders` fehlen bei 6 von insgesamt 5.013 Bestellungen die Postleitzahlen. Alle betroffenen Bestellungen stammen aus Burlington, Vermont.

Für diesen Versandort sind im Datensatz keine vorhandenen Postleitzahlen verfügbar, aus denen sich die fehlenden Werte zuverlässig ergänzen lassen.

### Vorher-Nachher-Beispiele

|Merkmal|Vorher|Nachher (Reporting)|
|-|-|-|
|`shipping_postal_code`|`NULL` bei 6 Bestellungen|`UNKNOWN` bei 6 Bestellungen|
|`postal_code_missing_flag`|Nicht vorhanden|`1` bei fehlender Postleitzahl, sonst `0`|
|Originaldaten|6 fehlende Werte|Unverändert|

### Entscheidung

Die fehlenden Postleitzahlen werden nicht geschätzt. Stattdessen werden sie im Reporting mit `UNKNOWN` gekennzeichnet.

Ein zusätzliches Flag ermöglicht es, die betroffenen Bestellungen gezielt zu identifizieren. Die Originaldaten bleiben unverändert.

### Konkrete Beispiele

|order_id|Originalwert|Reportingwert|postal_code_missing_flag|
|-|-|-|-|
|CA-2016-117086|NULL|UNKNOWN|1|
|CA-2016-162887|NULL|UNKNOWN|1|
|CA-2018-104066|NULL|UNKNOWN|1|
|CA-2015-100004|10011|10011|0|
|CA-2015-100006|10024|10024|0|

### Interpretation

Die drei betroffenen Beispielzeilen erhalten UNKNOWN und Flag 1.
Die beiden Beispiele mit vorhandener Postleitzahl bleiben
inhaltlich unverändert und erhalten Flag 0. UNKNOWN macht die
fehlende Angabe sichtbar, ohne eine Postleitzahl zu erfinden.
Im vollständigen Ergebnis betrifft die Kennzeichnung 6 von
5.013 Bestellungen.



## 2\. Auffällige Herstellerwerte

### Befund und Regel

Bei 10 Produkten entspricht product_manufacturer dem product_name.
Dieses Muster deutet auf mögliche fehlerhafte Herstellerangaben hin,
beweist sie aber nicht.

Die Herstellerwerte bleiben unverändert. Zusätzlich wird
manufacturer_review_flag ausgegeben: 1 bei identischem Hersteller-
und Produktnamen, andernfalls 0.

### Vorher-Nachher-Beispiele

|product_id|product_name|Hersteller vorher|Hersteller nachher|manufacturer_review_flag|
|-|-|-|-|-|
|17|3-ring staple pack|3-ring staple pack|3-ring staple pack|1|
|538|Easy-staple paper|Easy-staple paper|Easy-staple paper|1|
|1769|Xerox 1971|Xerox 1971|Xerox 1971|1|
|1|"While you Were Out" Message Book, One Form per Page|Other|Other|0|
|2|#10 Gummed Flap White Envelopes, 100/Box|Other|Other|0|

### Interpretation

Bei den drei markierten Beispielprodukten stimmen Hersteller-
und Produktname überein. Die Herstellerwerte werden nicht ersetzt;
die Veränderung besteht ausschließlich im zusätzlichen Prüfkennzeichen.

Bei den Produkten 1 und 2 unterscheidet sich der Produktname vom
Herstellerwert Other. Sie erhalten deshalb Flag 0. Das bestätigt
nicht, dass Other eine vollständige oder korrekte Herstellerangabe
ist, sondern nur, dass das geprüfte Suchmuster nicht zutrifft.

Im vollständigen Ergebnis werden 10 von 1.850 Produkten markiert.
Die übrigen 1.840 Produkte erhalten Flag 0.


## Bewusst unveränderte kurze Postleitzahlen
213 Bestellungen haben vierstellige Postleitzahlen. Sie bleiben unverändert: Die numerische Speicherung kann führende Nullen verlieren, bestätigt aber nicht die richtige Adresse. Eine Ergänzung erfordert eine verlässliche Referenz. Postleitzahlen künftig als Text importieren; die ursprüngliche numerische Quellspalte wird hier nicht umgeschrieben.
