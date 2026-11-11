# Unicorn Sales Analysis – Final Delivery

**Autor:** Suryandi  
**Analysezeitraum:** 2015–2018

Dieses Paket untersucht Umsatzentwicklung, regionale Wachstumstreiber, wichtige Kunden sowie Rabatte und Verlustbeiträge im Unicorn-Datensatz.

## Inhalt

| Datei oder Ordner | Zweck |
| :---- | :---- |
| [final\_analysis.md](http://final_analysis.md) | Executive Summary, sechs Business-Fragen, Ergebnisse, Einschränkungen und Managementempfehlung. |
| [final\_queries.sql](http://final_queries.sql) | Sechs einzeln ausführbare, kommentierte SQL-Abfragen. |
| [outputs/](http://outputs/) | Sechs CSV-Exporte als Nachweise für die berichteten Zahlen. |
| [self\_assessment.md](http://self_assessment.md) | Selbsteinschätzung mit Begründungen und Verbesserungsmöglichkeiten. |
| [presentation.pptx](http://presentation.pptx) | Präsentation, 9 Folie. |
| [stretch/follow\_up\_memo.md](http://stretch/follow_up_memo.md) | Vorschlag für eine gezielte Folgeuntersuchung zur Rabatt- und Preisgestaltung bei Furniture. |

Ergebnisdateien

* Q1: [outputs/q1\_revenue\_by\_year.csv](http://outputs/q1_revenue_by_year.csv)  
* Q2: [outputs/q2\_region\_growth.csv](http://outputs/q2_region_growth.csv)  
* Q3: [outputs/q3\_top\_customers.csv](http://outputs/q3_top_customers.csv)  
* Q4: [outputs/q4\_discount\_impact.csv](http://outputs/q4_discount_impact.csv)  
* Q5: [outputs/q5\_negative\_margin\_categories.csv](http://outputs/q5_negative_margin_categories.csv)  
* Q6: [outputs/q6\_recommendation\_evidence.csv](http://outputs/q6_recommendation_evidence.csv)

## So liest du das Paket

**Fünf Minuten:** Executive Summary und zentrale Empfehlung am Anfang von `final_analysis.md` lesen.

**Zwanzig Minuten:** Den vollständigen Bericht mit den sechs Fragen lesen.

**Eine Zahl überprüfen:** Den zugehörigen CSV-Export öffnen oder die entsprechende Query aus `final_queries.sql` erneut ausführen.

## Reproduzierbarkeit

Die SQL-Abfragen wurden mit Beekeeper Studio gegen PostgreSQL 15.19 ausgeführt. Die projektweite Sammeldatei `09_queries.sql` im Hauptordner wurde vollständig und ohne SQL-Fehlermeldungen ausgeführt. Voraussetzung sind die Tabellen `customers`, `orders`, `order_details` und `product`, die über den aktuellen Suchpfad erreichbar sein müssen.

Der gemeinsame Business Scope umfasst Bestellungen von 2015 bis einschließlich 2018, Versandland United States und die Versandarten First Class, Same Day, Second Class und Standard Class. Q2 und Q3 betrachten 2017–2018; Q3 beschränkt sich entsprechend dem Ergebnis von Q2 auf West.

Jede Query enthält ihre eigenen CTEs und kann vollständig einzeln ausgeführt werden. Es werden keine zuvor angelegten temporären Tabellen oder Views benötigt. Für übereinstimmende Ergebnisse ist derselbe Datenstand erforderlich.

Die CSV-Ausgaben wurden rechnerisch geprüft und zwischen den Queries abgeglichen. Diese Kontrollen ersetzen keinen unabhängigen Abgleich mit den Quelldaten. Annahmen und fachliche Grenzen sind im Bericht und in den SQL-Kommentaren dokumentiert.