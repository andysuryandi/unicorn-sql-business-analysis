# Unicorn – Stretch Notes

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi

## Gewählter Weg und Ziel

Gewählt wurde **Path A: gleitender 3-Monats-Umsatzdurchschnitt je Region**. Die Analyse ergänzt den Jahresvergleich um eine monatliche Perspektive. Sie hilft, einzelne Umsatzspitzen von einer über mehrere Monate erhöhten Umsatzentwicklung zu unterscheiden.

SQL: `stretch.sql`  
Ergebnisse: `outputs/stretch_results.csv`

## Berechnung und Prüfung

Der Durchschnitt umfasst den aktuellen und die beiden vorherigen Kalendermonate, getrennt nach Versandregion. Ein vollständiger Monatskalender verhindert, dass fehlende Monate das Zeitfenster verschieben.

Die Ausgabe enthält 192 Zeilen: vier Regionen mit jeweils 48 Monaten von Januar 2015 bis Dezember 2018. Alle 192 Durchschnittswerte wurden anhand der exportierten Monatsumsätze nachgerechnet und stimmen auf zwei Nachkommastellen. Die Jahressummen je Region stimmen außerdem mit Query 2 aus `trend_and_ranking.sql` überein.

Die ersten beiden Monate bleiben erhalten: Januar 2015 verwendet einen Monat, Februar zwei Monate. Ab März umfasst jedes Fenster drei Monate.

## Was die geglättete Reihe zeigt

**West:** Von September bis Dezember 2018 steigt der gleitende Durchschnitt von 24.808,33 auf 26.571,00. Obwohl der Monatsumsatz im Oktober auf 21.216,00 zurückgeht, bleibt die geglättete Reihe vergleichsweise stabil und steigt weiter. Die Entwicklung zum Jahresende beruht damit nicht ausschließlich auf einem einzelnen Spitzenmonat.

**East:** Der Monatsumsatz fällt von 44.000,00 im November 2018 auf 20.083,00 im Dezember. Der gleitende Durchschnitt sinkt wesentlich moderater von 36.244,33 auf 32.130,67. Die Glättung macht sichtbar, dass das jüngste Drei-Monats-Niveau trotz des starken Monatsrückgangs weiterhin hoch liegt; zugleich reagiert sie verzögert auf Veränderungen.

## Grenzen

Ein gleitender Durchschnitt glättet Schwankungen, erklärt aber deren Ursachen nicht und ist keine Saisonbereinigung. Er kann Wendepunkte verzögert zeigen. Die ersten beiden Werte je Region sind wegen der kürzeren Fenster nur eingeschränkt mit späteren Werten vergleichbar.

Monate ohne Bestellpositionen im definierten Scope werden als Nullumsatz behandelt. Das setzt eine vollständige Datenbasis voraus; fehlende Datenlieferungen lassen sich dadurch nicht erkennen. Enthält ein vorhandener Monat fehlende Umsatzwerte, bleiben sein Monatsumsatz und die betroffenen gleitenden Durchschnittswerte dagegen NULL.

Die Prüfung bestätigt die rechnerische Konsistenz der Exporte und ihre Übereinstimmung mit dem Jahresvergleich. Ein unabhängiger Abgleich mit den Quelldaten wurde nicht durchgeführt.

## Was ich mit einem weiteren Sprint ändern würde

Ich würde die Monatsumsätze mit den jeweiligen Vorjahresmonaten vergleichen und auffällige Entwicklungen nach Kundensegment und Produktkategorie aufschlüsseln. So ließe sich untersuchen, ob die hohen Jahresendwerte wiederkehrende saisonale Muster zeigen und welche Gruppen dazu beitragen.