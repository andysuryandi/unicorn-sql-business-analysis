# Unicorn Sales Analysis – Final Report

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi  
**Stand:** 22\. Oktober 2026

## Executive Summary

Unicorn erreicht 2018 mit **731.549,00** den höchsten Jahresumsatz des betrachteten Zeitraums. Nach einem Rückgang von 5,42 % im Jahr 2016 wächst der Umsatz 2017 um 29,22 % und 2018 um weitere 20,34 %. **West ist 2018 der stärkste regionale Wachstumstreiber:** Die Region erzielt mit 62.560,00 den größten absoluten Umsatzanstieg und mit 33,37 % zugleich die höchste Wachstumsrate. Die hypothetische Gegenrechnung ohne Rabatte ergibt einen Rabattbetrag von **569.573,69 beziehungsweise 19,80 % der No-Discount-Baseline**; dieser Betrag ist kein nachgewiesener vermeidbarer Umsatzverlust. Innerhalb insgesamt verlustbringender Bestellungen trägt **Furniture mit 54.975,00 beziehungsweise 39,27 %** den größten Anteil am Nettoverlust. Die rabattierten Furniture-Positionen dieser Bestellungen weisen zusammen eine Marge von −24,50 % auf.

### Zentrale Empfehlung

**Sales und Controlling sollten gemeinsam die Rabatt- und Preisgestaltung bei Furniture überprüfen.** Ausgangspunkt sind die rabattierten Furniture-Positionen in Verlustbestellungen. Diese sollten zunächst nach Produktunterkategorie und Rabatthöhe aufgeschlüsselt werden. Vor Preis- oder Rabattänderungen ist der Vergleich auf profitable Bestellungen auszuweiten und um Informationen zu Kosten und Aktionen zu ergänzen. Ziel ist eine begründete Auswahl konkreter Produkte und Rabattstufen für einen begrenzten Test, dessen Erfolg anhand von Gewinn, Marge und Absatz beurteilt wird.

### Geltungsbereich und Grenzen

Die Analyse umfasst Bestellungen von 2015 bis 2018 mit Versandland United States und den Versandarten First Class, Same Day, Second Class und Standard Class. Umsatz- und Gewinnbeträge werden in den Einheiten der Quelldaten dargestellt. Die Währung ist in den vorliegenden Ergebnisexporten nicht ausgewiesen.

Die Befunde beschreiben Entwicklungen und Zusammenhänge. Sie erklären keine Ursachen und belegen insbesondere nicht, dass Rabatte die beobachteten Verluste verursacht haben. Die Ergebnisse wurden anhand der Exporte rechnerisch geprüft und zwischen den Analysen abgeglichen; ein unabhängiger Abgleich mit den Quelldaten erfolgte im Rahmen dieser Ergebnisprüfung nicht.

---

## Q1. What is total revenue by year, and what's the year-over-year growth rate?

**Kontext:** Die jährliche Umsatzentwicklung zeigt, ob das Geschäft wächst und wie sich das Wachstum verändert.

**Query:** `final_queries.sql`, Q1  
**Ergebnis:** `outputs/q1_revenue_by_year.csv`

**Finding:** Nach einem Umsatzrückgang 2016 wächst Unicorn in den beiden Folgejahren deutlich und erreicht 2018 den höchsten Jahresumsatz; das prozentuale Wachstum fällt 2018 jedoch geringer aus als 2017\.

| Jahr | Umsatz | Wachstum gegenüber dem Vorjahr |
| :---- | ----: | ----: |
| 2015 | 497.371,00 | Nicht berechenbar |
| 2016 | 470.425,00 | −5,42 % |
| 2017 | 607.904,00 | \+29,22 % |
| 2018 | 731.549,00 | \+20,34 % |

**Caveat:** Für 2015 ist innerhalb des Analysezeitraums kein Vorjahresvergleich möglich. Die Umsatzentwicklung allein zeigt außerdem nicht, ob das Wachstum profitabel ist.

**Nächster Schritt:** Das Wachstum zunächst regional aufschlüsseln und bei Entscheidungen zur Wachstumsförderung zusätzlich die Profitabilität berücksichtigen.

## Q2. Which region is driving the most growth in 2017–2018, and by how much?

**Kontext:** Die regionale Aufteilung zeigt, woher der Gesamtumsatzanstieg von 2017 auf 2018 stammt.

**Query:** `final_queries.sql`, Q2  
**Ergebnis:** `outputs/q2_region_growth.csv`

**Finding:** West führt sowohl beim absoluten Umsatzanstieg als auch beim prozentualen Wachstum und ist damit nach beiden Maßstäben der stärkste regionale Wachstumstreiber.

| Region | Umsatz 2017 | Umsatz 2018 | Veränderung | Wachstum |
| :---- | ----: | ----: | ----: | ----: |
| West | 187.498,00 | 250.058,00 | \+62.560,00 | \+33,37 % |
| South | 92.315,00 | 122.925,00 | \+30.610,00 | \+33,16 % |
| East | 180.657,00 | 211.469,00 | \+30.812,00 | \+17,06 % |
| Central | 147.434,00 | 147.097,00 | −337,00 | −0,23 % |

Die regionalen Veränderungen ergeben zusammen den Gesamtanstieg von **123.645,00**. South wächst prozentual schneller als East, trägt absolut aber etwas weniger zum Anstieg bei.

**Caveat:** Der Vergleich umfasst einen einzigen Jahresübergang. Er zeigt nicht, ob das Wachstum dauerhaft ist oder auf einzelne Kunden, Produkte oder Aktionen zurückgeht.

**Nächster Schritt:** West anhand seiner Kundenstruktur näher betrachten. Für Q3 wird die Region anhand der höchsten prozentualen Wachstumsrate ausgewählt.

## Q3. Within that fastest-growing region, who are the top 3 customers in 2017–2018 by revenue?

**Kontext:** Die umsatzstärksten Kunden konkretisieren, welche Kundenbeziehungen innerhalb der ausgewählten Region besonders relevant sind.

**Query:** `final_queries.sql`, Q3  
**Ergebnis:** `outputs/q3_top_customers.csv`

**Finding:** Raymond Buch ist mit 14.345,00 der umsatzstärkste Kunde in West im gemeinsamen Zeitraum 2017–2018, gefolgt von Edward Hooks und Jane Waco.

| Rang | Kunden-ID | Kunde | Umsatz 2017–2018 |
| :---- | ----: | :---- | ----: |
| 1 | 623 | Raymond Buch | 14.345,00 |
| 2 | 250 | Edward Hooks | 7.408,00 |
| 3 | 347 | Jane Waco | 7.393,00 |

**Caveat:** Das Ranking basiert auf dem Gesamtumsatz beider Jahre innerhalb von West. Es zeigt weder die Kundenprofitabilität noch den jeweiligen Beitrag zum Wachstum von 2017 auf 2018\.

**Nächster Schritt:** Für die wichtigsten Kunden Umsatz und Gewinn getrennt nach Jahr vergleichen, bevor daraus Maßnahmen zur Kundenbindung oder Wachstumsförderung abgeleitet werden.

## Q4. Looking across all years and regions, what share of total revenue is being lost to the discount program (compared to a hypothetical no-discount baseline)?

**Kontext:** Eine rechnerische Gegenüberstellung macht die Größenordnung der gewährten Rabatte sichtbar.

**Query:** `final_queries.sql`, Q4  
**Ergebnis:** `outputs/q4_discount_impact.csv`

**Finding:** Unter der Annahme unveränderter Absatzmengen beträgt der rechnerische Rabattbetrag 569.573,69 beziehungsweise 19,80 % des hypothetischen Umsatzes ohne Rabatte.

| Kennzahl | Wert |
| :---- | ----: |
| Tatsächlicher Umsatz | 2.307.249,00 |
| Hypothetischer Umsatz ohne Rabatt | 2.876.822,69 |
| Rechnerischer Rabattbetrag | 569.573,69 |
| Rabattbetrag als Anteil der No-Discount-Baseline | 19,80 % |

Die Berechnung umfasst **9.997 Bestellpositionen**. Keine Position wurde durch die definierten Eingangsprüfungen als ungültig markiert.

Die Baseline wird je Position als Umsatz nach Rabatt geteilt durch eins minus Rabattanteil berechnet. Der Prozentwert verwendet die **No-Discount-Baseline als Nenner**, nicht den tatsächlichen Umsatz.

**Caveat:** Die Berechnung setzt voraus, dass `order_sales` den Umsatz nach Rabatt und `order_discount` den Rabattanteil enthält. Ohne Rabatte könnten sich Absatzmengen verändern; die Differenz ist daher kein nachgewiesener realisierbarer Mehrumsatz und keine Schätzung zusätzlichen Gewinns.

**Nächster Schritt:** Die Größenordnung gemeinsam mit den Gewinnbefunden untersuchen, statt daraus eine pauschale Abschaffung der Rabatte abzuleiten.

## Q5. Which product categories carry the negative-margin orders most heavily?

**Kontext:** Die Zuordnung der Verluste zu Kategorien hilft, eine gezielte Profitabilitätsprüfung zu priorisieren.

**Query:** `final_queries.sql`, Q5  
**Ergebnis:** `outputs/q5_negative_margin_categories.csv`

**Finding:** Furniture trägt mit 54.975,00 beziehungsweise 39,27 % den größten Nettoverlustbeitrag innerhalb insgesamt verlustbringender Bestellungen.

Als Verlustbestellung gilt eine Bestellung mit positivem Gesamtumsatz und negativem Gesamtgewinn. Erst nach dieser Prüfung werden ihre Positionen auf Produktkategorien verteilt.

| Kategorie | Anzahl beteiligter Verlustbestellungen | Nettoverlustbeitrag | Anteil am Nettoverlust |
| :---- | ----: | ----: | ----: |
| Furniture | 535 | 54.975,00 | 39,27 % |
| Office Supplies | 713 | 50.575,00 | 36,13 % |
| Technology | 281 | 34.442,00 | 24,60 % |

Der gesamte Nettoverlust der ausgewählten Bestellungen beträgt **139.992,00**. Office Supplies ist an den meisten Verlustbestellungen beteiligt; Furniture weist dagegen den höchsten Verlustbetrag auf.

**Caveat:** Diese Auswahl beschreibt nicht die Gesamtprofitabilität der Kategorien. Eine Bestellung kann mehrere Kategorien enthalten, weshalb die Bestellanzahlen nicht addiert werden dürfen. Bestellungen mit fehlenden Umsatz- oder Gewinnwerten sind von der Klassifikation ausgeschlossen.

**Nächster Schritt:** Furniture als ersten Untersuchungsschwerpunkt wählen und den Verlustbeitrag nach Rabattstatus aufschlüsseln.

## Q6. Based on the analysis above, what one recommendation would you make to the executive team?

**Kontext:** Die Ergebnisse sollen zu einer konkreten, überprüfbaren Managemententscheidung führen.

**Query:** `final_queries.sql`, Q6  
**Ergebnis:** `outputs/q6_recommendation_evidence.csv`

**Finding:** Innerhalb der ausgewählten Verlustbestellungen erzielen die rabattierten Furniture-Positionen einen Gewinn von −55.128,00; die wenigen nicht rabattierten Positionen gleichen davon lediglich 153,00 aus.

| Rabattstatus | Positionen | Umsatz | Gewinn | Gewinnmarge |
| :---- | ----: | ----: | ----: | ----: |
| Rabattiert | 657 | 224.995,00 | −55.128,00 | −24,50 % |
| Ohne Rabatt | 10 | 531,00 | \+153,00 | \+28,81 % |

Zusammen ergeben die Gruppen **225.526,00 Umsatz und −54.975,00 Gewinn**. Damit stimmen sie exakt mit den Furniture-Werten aus Q5 überein.

**Caveat:** Die Auswertung ist bereits auf Verlustbestellungen eingeschränkt. Die zehn nicht rabattierten Positionen bilden keine belastbare Kontrollgruppe. Unterschiede können beispielsweise mit Produktmix oder Kosten zusammenhängen; eine kausale Rabattwirkung ist nicht nachgewiesen.

**Empfehlung:** Das Management sollte Sales und Controlling mit einer gezielten Prüfung der Rabatt- und Preisgestaltung bei Furniture beauftragen. Ausgangspunkt sind die rabattierten Positionen in Verlustbestellungen. Die Prüfung sollte nach Unterkategorie und Rabatthöhe unterscheiden, profitable Bestellungen zum Vergleich einbeziehen und verfügbare Kosten- und Aktionsdaten berücksichtigen. Als Ergebnis sollen konkrete Produkte und Rabattstufen für einen begrenzten Test vorgeschlagen werden. Dessen Erfolg ist anhand von Gewinn, Marge und Absatz zu bewerten – nicht allein anhand des Umsatzes.

## Nachprüfung des Paketstands am 23.10.2026

Die sechs bestehenden Ergebnisdateien wurden unabhängig aus den vier mitgelieferten Rohdateien nachgerechnet und stimmen überein. Diese spätere lokale Prüfung ergänzt die ursprünglichen Exportprüfungen. Sie bestätigt weder einen aktuellen Serverdatenstand noch die Ausführung der überarbeiteten SQL auf PostgreSQL. Die fachlichen Grenzen und Kausalitätsvorbehalte bleiben bestehen.