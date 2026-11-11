# Unicorn – Trend- und Ranking-Ergebnisse

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi 

## Zweck

Diese Datei dokumentiert Ergebnisbeispiele der beiden Queries aus `trend_and_ranking.sql`. Die vollständigen Ausgaben liegen in den zugehörigen CSV-Dateien.

## Query 1 – Top-3-Kunden je Region nach Umsatz

**Zeitraum:** 2017–2018  
**Grain:** Eine Zeile je ausgewähltem Kunden und Versandregion.  
**Ergebnisdatei:** `trend_and_ranking_query1.csv`

### Erste fünf Ergebniszeilen

| shipping_region | customer_id | customer_revenue | rank_in_region |
|---|---:|---:|---:|
| Central | 731 | 18336.00 | 1 |
| Central | 7 | 10403.00 | 2 |
| Central | 328 | 6058.00 | 3 |
| East | 758 | 13724.00 | 1 |
| East | 335 | 10523.00 | 2 |

### Prüfung

Die vollständige Ausgabe enthält 12 Zeilen und vier Spalten. Jede der vier Regionen enthält drei unterschiedliche Kunden mit den Rangplätzen 1, 2 und 3. Die Kundenumsätze sind innerhalb jeder Region absteigend sortiert.

### Beobachtung

Kunde 731 in Central weist mit 18.336,00 den höchsten Kundenumsatz unter den zwölf ausgewiesenen Ergebnissen auf. Daraus lässt sich keine Aussage über den Gesamtumsatz oder das Wachstum einer Region ableiten.

## Query 2 – Umsatz und Vorjahreswachstum je Region

**Zeitraum:** 2015–2018  
**Grain:** Eine Zeile je Kalenderjahr und Versandregion.  
**Ergebnisdatei:** `trend_and_ranking_query2.csv`

### Erste fünf Ergebniszeilen

| year | shipping_region | revenue | prev_year_revenue | yoy_growth_pct |
|---|---|---:|---:|---:|
| 2015 | Central | 103850.00 | NULL | NULL |
| 2016 | Central | 102875.00 | 103850.00 | -0.94 |
| 2017 | Central | 147434.00 | 102875.00 | 43.31 |
| 2018 | Central | 147097.00 | 147434.00 | -0.23 |
| 2015 | East | 141800.00 | NULL | NULL |

Die leeren Felder des CSV-Exports werden hier als `NULL` dargestellt. Wachstumsraten sind Prozentwerte.

### Prüfung

Die vollständige Ausgabe enthält 16 Zeilen und fünf Spalten. Alle vier Regionen enthalten die Jahre 2015–2018. Die Vorjahresumsätze stimmen mit den entsprechenden Vorjahreszeilen überein. Alle zwölf Wachstumsraten wurden anhand der exportierten Umsätze nachgerechnet und stimmen auf zwei Nachkommastellen.

Für 2015 fehlen Vorjahresumsatz und Wachstum erwartungsgemäß, da 2014 außerhalb des Analysezeitraums liegt.

### Beobachtung

In der vollständigen Ausgabe verzeichnet West 2018 mit 33,37 % das höchste relative Umsatzwachstum, knapp vor South mit 33,16 %. Central zeigt nach 43,31 % Wachstum im Jahr 2017 einen leichten Rückgang von 0,23 % im Jahr 2018. Die Ursachen dieser unterschiedlichen Entwicklung lassen sich aus den Jahresaggregaten allein nicht bestimmen.

## Prüfgrenzen und Reproduzierbarkeit

Die Prüfung bestätigt die Ausgabestruktur, die Sortierung des Rankings und die rechnerische Konsistenz des Jahresvergleichs. Ein unabhängiger Abgleich der Umsatzsummen mit den Quelldaten wurde nicht durchgeführt.

Zur Reproduktion jede vollständige Query aus `trend_and_ranking.sql` einzeln gegen denselben Unicorn-Datenstand ausführen. Query 1 muss zwölf, Query 2 sechzehn Ergebniszeilen liefern. Die Ergebnisse mit den vollständigen CSV-Exporten vergleichen.

## Zwischenfazit

Die beiden Analysen ergänzen sich: Das Kundenranking zeigt umsatzstarke Kunden je Region, während die Trendanalyse die regionale Umsatzentwicklung beschreibt.

West und South weisen 2018 die höchsten relativen Wachstumsraten auf. Für eine Wachstumsempfehlung müssen jedoch auch Profitabilität und Risiken berücksichtigt werden.