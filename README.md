# Unicorn Analysis – Suryandi

**Paketstand: 23.10.2026.** Analyse des gelieferten Unicorn-Snapshots 2015–2018. Geschäftliche Leitfrage: Wo sollte der Fokus für profitables Wachstum liegen?

## Einstieg

1. `08_delivery/final_analysis.md`: Executive Summary, sechs Antworten, Grenzen und Empfehlung.  
2. `08_delivery/presentation.pptx`: sieben Folien mit Sprechernotizen.  
3. `08_delivery/final_queries.sql` und `08_delivery/outputs/`: SQL und sechs zugehörige Ergebnisexporte.

## Projektstruktur

| Ordner / Datei | Inhalt |
| :---- | :---- |
| 00\_database | Vier CSV-Exporte aus der bereitgestellten PostgreSQL-Datenbank |
| 01\_audit | Datenwörterbuch, Grain, Schlüssel, Risiken, Exploration |
| 02\_qa | Datenprüfungen, Assertions, Business Slice |
| 03\_kpis | Fünf KPIs zu Regionen, Produktkategorien und Kundensegmenten, Summary, Rabattsegmentierung und Ergebnisexporte |
| 04\_joined\_data | Kanonischer Vier-Tabellen-Join, Validierungsprüfungen, INNER-/LEFT-JOIN-Vergleich und Ergebnisnotizen |
| 05\_cleaned\_dimensions | Diagnostik, transparente Cleaning-Regeln und Ergebnisse |
| 06\_reporting\_stack | Reporting-Stack, Parameter und Ergebnisnachweise |
| 07\_analysis | Ranking, Jahresvergleich, gleitende Durchschnitte und EXPLAIN-Review |
| 08\_delivery | Abschlussbericht, finale Queries, Ergebnisse, Präsentation, Selbsteinschätzung |
| 09\_queries.sql | Zusammengeführte Hauptskripte in Modulreihenfolge |

&nbsp;

Datenquelle

Die Rohdaten wurden mit Beekeeper Studio aus der für das Projekt bereitgestellten PostgreSQL-Datenbank als CSV-Dateien exportiert und unter `00_database/` abgelegt. Die exportierten Dateien wurden anschließend nicht verändert.

## Dokumentation der Abfrageergebnisse

Nicht jede Abfrage wird zusätzlich als CSV-Datei exportiert. Zum Beispiel bei Prüfungen in den Bereichen Audit, QA und Join-Validierung werden kurze Ergebnisse – beispielsweise eine einzelne Zeile, keine Treffer oder ein Prüfwert von 0 – direkt in den SQL-Kommentaren oder den zugehörigen Markdown-Notizen dokumentiert. Dabei wird erläutert, was das Ergebnis für die jeweilige Prüfung bedeutet.

Analyseergebnisse und ausdrücklich in den Projektanleitungen geforderte CSV-Exporte werden in den jeweiligen Ergebnisordnern gespeichert.

## Reproduzieren und prüfen

Die SQL-Abfragen wurden mit Beekeeper Studio gegen PostgreSQL 15.19 ausgeführt. Voraussetzung sind die vier Tabellen `customers`, `orders`, `order_details` und `product`. Hinweise zu den Rohdateien stehen in `00_database/README.md`.

Die Sammeldatei `09_queries.sql` wurde vollständig ausgeführt. Dabei wurden keine SQL-Fehlermeldungen angezeigt. Die Herkunft jeder Sektion ist im Skript angegeben. Regionale Varianten und Entwicklungstests sind nicht zusätzlich in der Sammeldatei enthalten.

Der Business Scope umfasst die Jahre 2015–2018, das Versandland United States und die Versandarten First Class, Same Day, Second Class und Standard Class. Abweichende Analysezeiträume sind in den jeweiligen Abfragen dokumentiert.

Die erfolgreiche Ausführung bestätigt die technische Ausführbarkeit des geprüften Skriptstands. Der Abgleich der Abfrageergebnisse mit den gespeicherten CSV-Exporten erfolgt separat. Bei Änderungen an SQL oder Datenbestand sind die betroffenen Prüfungen zu wiederholen.

Die gespeicherten EXPLAIN-Pläne dokumentieren den jeweiligen damaligen Planungsstand. Geschätzte Kosten sind keine gemessenen Ausführungszeiten.

### Data Availability

The dataset was provided as part of an educational SQL data analytics project involving a fictional company.

The raw data is not included in this public repository. Data access may be considered upon request, subject to the original dataset's usage and sharing permissions.

The repository includes SQL queries, documentation, and selected aggregated analysis results to demonstrate the analytical methodology.
