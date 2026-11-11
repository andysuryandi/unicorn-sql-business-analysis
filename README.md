# Unicorn Analysis – Suryandi

**SQL Business Analysis | PostgreSQL | Data Quality | Business Intelligence**

## Projektüberblick

Dieses SQL-Abschlussprojekt wurde zu Ausbildungs- und Portfoliozwecken anhand des fiktiven Einzelhandelsunternehmens Unicorn erstellt.

**Geschäftliche Leitfrage:** Wo sollte das Unternehmen ansetzen, um profitables Wachstum zu fördern?

Die Analyse basiert auf einem bereitgestellten Datensatz für die Jahre 2015–2018 und untersucht Umsatzentwicklung, regionale Wachstumstreiber, wichtige Kunden, Rabattwirkungen und Verlustbeiträge.

**Werkzeuge:** PostgreSQL, SQL und Beekeeper Studio.

**Methoden:** Daten-Audit, Qualitätssicherung, JOIN-Validierung, KPI-Berechnungen, CTEs, Aggregationen, Window Functions und Business Analysis.

## Zentrale Ergebnisse

- **Umsatzentwicklung:** Der Umsatz stieg 2018 gegenüber 2017 um 20,34 %.
- **Regionales Wachstum:** Die Region West erzielte von 2017 bis 2018 mit 62.560 den höchsten absoluten Umsatzzuwachs.
- **Rabattanalyse:** Die hypothetische Umsatzdifferenz gegenüber einem Szenario ohne Rabatte beträgt 569.573,69. Dies ist kein nachgewiesener Umsatzverlust.
- **Verlustbeiträge:** Furniture verursachte 39,27 % der negativen Gewinnbeiträge innerhalb verlustbringender Bestellungen.

## Geschäftliche Empfehlung

Die Rabatt- und Preisgestaltung der Produktkategorie Furniture sollte gezielt untersucht werden.

Dafür sollten Rabattstufen, Unterkategorien sowie profitable und verlustbringende Bestellungen miteinander verglichen werden.

Die Ergebnisse zeigen Zusammenhänge innerhalb des untersuchten Datensatzes, belegen jedoch keine Ursache-Wirkungs-Beziehung.

## Einstieg

1. [Abschlussbericht](08_delivery/final_analysis.md) – Executive Summary, sechs Business-Fragen, Grenzen und Empfehlung.
2. [Abschlusspräsentation](08_delivery/presentation.pptx) – Präsentation der wichtigsten Ergebnisse.
3. [Finale SQL-Abfragen](08_delivery/final_queries.sql) – Sechs dokumentierte Analyseabfragen.
4. [Ergebnisexporte](08_delivery/outputs/) – Sechs zugehörige CSV-Dateien.

## Projektstruktur

| Ordner / Datei | Inhalt |
|---|---|
| `00_database/` | Dokumentation der Datenquelle und Tabellenstruktur |
| `01_audit/` | Datenwörterbuch, Grain, Schlüssel, Risiken und Exploration |
| `02_qa/` | Datenprüfungen, Assertions und Business Slice |
| `03_kpis/` | Fünf KPIs, Rabattsegmentierung und Ergebnisexporte |
| `04_joined_data/` | Kanonischer Vier-Tabellen-Join und Validierungsprüfungen |
| `05_cleaned_dimensions/` | Diagnostik und transparente Bereinigungsregeln |
| `06_reporting_stack/` | Reporting-Stack, Parameter und Ergebnisnachweise |
| `07_analysis/` | Rankings, Jahresvergleiche, gleitende Durchschnitte und EXPLAIN-Review |
| `08_delivery/` | Abschlussbericht, SQL-Abfragen, CSV-Ergebnisse, Präsentation und Selbsteinschätzung |
| `09_queries.sql` | Zusammengeführte Hauptskripte in Modulreihenfolge |

## Datenquelle

Die Daten stammen aus einer für das Ausbildungsprojekt bereitgestellten PostgreSQL-Datenbank.

Die Analyse verwendet vier Tabellen:

- `customers`
- `orders`
- `order_details`
- `product`

Die Rohdaten werden nicht öffentlich in diesem Portfolio-Repository bereitgestellt. Eine Weitergabe auf Anfrage kann nur unter Berücksichtigung der ursprünglichen Nutzungs- und Weitergaberechte geprüft werden.

## Dokumentation der Abfrageergebnisse

Nicht jede Abfrage wird zusätzlich als CSV-Datei exportiert.

Bei Prüfungen in den Bereichen Audit, Qualitätssicherung und JOIN-Validierung werden kurze Ergebnisse – beispielsweise eine einzelne Zeile, keine Treffer oder ein Prüfwert von 0 – in den SQL-Kommentaren oder den zugehörigen Markdown-Notizen dokumentiert.

Dabei wird erläutert, welche Bedeutung das jeweilige Ergebnis für die Datenqualität oder Analyse hat.

Analyseergebnisse und ausdrücklich in den Projektanleitungen geforderte CSV-Exporte werden in den jeweiligen Ergebnisordnern gespeichert.

## Reproduzierbarkeit und Validierung

Die SQL-Abfragen wurden mit Beekeeper Studio gegen PostgreSQL 15.19 ausgeführt.

Voraussetzung sind die vier Tabellen `customers`, `orders`, `order_details` und `product` mit der dokumentierten Datenstruktur und demselben Datenstand.

Die Sammeldatei `09_queries.sql` wurde nach der dokumentierten Projektdurchführung vollständig ohne SQL-Fehlermeldungen ausgeführt.

Der gemeinsame Business Scope umfasst:

- **Zeitraum:** 2015–2018
- **Versandland:** United States
- **Versandarten:** First Class, Same Day, Second Class und Standard Class

Abweichende Analysezeiträume sind in den jeweiligen Abfragen dokumentiert.

### Ergebnisvalidierung

Die sechs zentralen Analyseergebnisse wurden anhand zusätzlicher SQL-Kontrollabfragen überprüft und mit den Angaben im Abschlussbericht abgeglichen.

| Analyse | Validierung |
|---|---|
| Q1 – Jahresumsatz und Wachstum | Ergebnisabgleich bestanden |
| Q2 – Regionales Umsatzwachstum | Ergebnisabgleich bestanden |
| Q3 – Umsatzstärkste Kunden | Ergebnisabgleich bestanden |
| Q4 – Hypothetische Rabattwirkung | Ergebnisabgleich bestanden |
| Q5 – Verlustbeiträge nach Kategorie | Ergebnisabgleich bestanden |
| Q6 – Furniture-Rabattanalyse | Ergebnisabgleich bestanden |

Diese Ergebnisprüfungen bestätigen die kontrollierten Kennzahlen. Sie ersetzen keine vollständige unabhängige Prüfung sämtlicher SQL-Abfragen, JOIN-Kardinalitäten und Quelldaten.

Bei Änderungen an SQL oder Datenbestand müssen die betroffenen Prüfungen erneut durchgeführt werden.

Die gespeicherten EXPLAIN-Pläne dokumentieren den jeweiligen damaligen Planungsstand. Geschätzte Kosten sind keine gemessenen Ausführungszeiten.

## Grenzen der Analyse

Die Ergebnisse beziehen sich auf den bereitgestellten Datensatz und den dokumentierten Analysezeitraum.

Die hypothetische Rabattberechnung berücksichtigt keine möglichen Veränderungen des Kaufverhaltens.

Die Analyse der Verlustbeiträge betrachtet gezielt verlustbringende Bestellungen und erlaubt keine unmittelbaren Schlussfolgerungen über die Gesamtprofitabilität einzelner Produktkategorien.

Die Handlungsempfehlungen dienen daher als Grundlage für weiterführende Untersuchungen.

## Hinweis zum Ausbildungsprojekt

Unicorn ist ein fiktives Unternehmen. Dieses Projekt dient ausschließlich Ausbildungs- und Portfoliozwecken.

Die dargestellten Geschäftsszenarien, Kundennamen und Analyseergebnisse werden im Kontext dieses Übungsprojekts verwendet. Es handelt sich nicht um eine Analyse eines realen Unternehmens.
