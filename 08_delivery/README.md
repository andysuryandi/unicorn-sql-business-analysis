# Unicorn Sales Analysis – Final Delivery

**Autor:** Suryandi  
**Analysezeitraum:** 2015–2018

Dieses Paket untersucht Umsatzentwicklung, regionale Wachstumstreiber, wichtige Kunden sowie Rabatte und Verlustbeiträge im Unicorn-Datensatz.


## Inhalt

| Datei oder Ordner | Zweck |
|---|---|
| [final_analysis.md](final_analysis.md) | Abschlussbericht und Business-Empfehlung |
| [final_queries.sql](final_queries.sql) | Sechs finale SQL-Abfragen |
| [outputs/](outputs/) | CSV-Ergebnisse |
| [self_assessment.md](self_assessment.md) | Selbsteinschätzung |
| [presentation.pptx](presentation.pptx) | Abschlusspräsentation |
| [stretch/follow_up_memo.md](stretch/follow_up_memo.md) | Vorschlag für eine Folgeuntersuchung |

## Ergebnisdateien

- [Q1 – Revenue by Year](outputs/q1_revenue_by_year.csv)
- [Q2 – Region Growth](outputs/q2_region_growth.csv)
- [Q3 – Top Customers](outputs/q3_top_customers.csv)
- [Q4 – Discount Impact](outputs/q4_discount_impact.csv)
- [Q5 – Negative Margin Categories](outputs/q5_negative_margin_categories.csv)
- [Q6 – Recommendation Evidence](outputs/q6_recommendation_evidence.csv)


## So liest du das Paket

**Fünf Minuten:** Executive Summary und zentrale Empfehlung am Anfang von `final_analysis.md` lesen.

**Zwanzig Minuten:** Den vollständigen Bericht mit den sechs Fragen lesen.

**Eine Zahl überprüfen:** Den zugehörigen CSV-Export öffnen oder die entsprechende Query aus `final_queries.sql` erneut ausführen.

## Reproduzierbarkeit

Die SQL-Abfragen wurden mit Beekeeper Studio gegen PostgreSQL 15.19 ausgeführt. Die projektweite Sammeldatei `09_queries.sql` im Hauptordner wurde vollständig und ohne SQL-Fehlermeldungen ausgeführt. Voraussetzung sind die Tabellen `customers`, `orders`, `order_details` und `product`, die über den aktuellen Suchpfad erreichbar sein müssen.

Der gemeinsame Business Scope umfasst Bestellungen von 2015 bis einschließlich 2018, Versandland United States und die Versandarten First Class, Same Day, Second Class und Standard Class. Q2 und Q3 betrachten 2017–2018; Q3 beschränkt sich entsprechend dem Ergebnis von Q2 auf West.

Jede Query enthält ihre eigenen CTEs und kann vollständig einzeln ausgeführt werden. Es werden keine zuvor angelegten temporären Tabellen oder Views benötigt. Für übereinstimmende Ergebnisse ist derselbe Datenstand erforderlich.

Die CSV-Ausgaben wurden rechnerisch geprüft und zwischen den Queries abgeglichen. Diese Kontrollen ersetzen keinen unabhängigen Abgleich mit den Quelldaten. Annahmen und fachliche Grenzen sind im Bericht und in den SQL-Kommentaren dokumentiert.

## Hinweis zum Projekt

Dieses Projekt wurde zu Lern- und Portfoliozwecken anhand eines fiktiven Handelsunternehmens erstellt.
Die Analyse demonstriert SQL-Kenntnisse, Datenqualitätsprüfungen, betriebswirtschaftliche Auswertungen und datenbasierte Handlungsempfehlungen.
Die Veröffentlichung der Daten und Ergebnisse erfolgt im Rahmen der dafür geltenden Nutzungs- und Weitergaberechte.
