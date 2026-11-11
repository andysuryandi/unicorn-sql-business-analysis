# Reporting Stack – Unicorn

**Zeitraum:** 2015–2018  
**Erstellt von:** Suryandi 

## Zweck und Zielgruppe

Der Stack unterstützt Stakeholder und Analysten bei der Frage, wo Unicorn weiteres Wachstum untersuchen sollte.

Er liefert fünf KPIs: Umsatzwachstum nach Region, Umsatz und Gewinnmarge nach Produktkategorie sowie Umsatz und Umsatzwachstum nach Kundensegment.

Der Business Scope umfasst Bestellungen von 2015–2018 in den United States mit First Class, Same Day, Second Class oder Standard Class.

## Aufbau und Designentscheidungen

`stack.sql` ist eine PostgreSQL-Anweisung. CTEs trennen die Verarbeitungsschritte nachvollziehbar, ohne persistente Zwischentabellen oder Views anzulegen.

| Schicht / CTE | Aufgabe und Grain |
|---|---|
| `base` | Verbindet `order_details`, `orders`, `customers` und `product`, filtert und bereinigt; eine Bestellposition je Zeile. |
| `region_yearly_sales`, `segment_yearly_sales` | Umsatz und Prüfkennzahlen je Region bzw. Segment und Jahr. |
| `category_totals`, `segment_totals` | Summen je Kategorie bzw. Segment über 2015–2018. |
| `region_previous_sales`, `segment_previous_sales` | Ergänzen Vorjahreswerte mit `LAG()`; Jahres-Grain bleibt erhalten. |
| `reporting` und finaler SELECT | Vereinheitlichen die Aggregate und berechnen die KPIs; Schlüssel: Ergebnisart, Dimension und gegebenenfalls Jahr. |

Die Gewinnmarge ist Gesamtgewinn / Gesamtumsatz × 100, kein Durchschnitt der Positionsmargen. Wachstum ist (Umsatz − Vorjahresumsatz) / Vorjahresumsatz × 100. Formeln und Rundung stehen im finalen SELECT. Jahreslücken, fehlende Eingangswerte und Nenner null ergeben keine Rate.

`parameterized_stack.sql` ergänzt einen einzeiligen Parameter-CTE und genau einen `CROSS JOIN` im Base-CTE. `region_filter` erlaubt `all`, `Central`, `East`, `South` oder `West`. Standard ist `all`; der übrige Business Scope bleibt unverändert.

## Bekannte Einschränkungen und Kontrollen

- Jede Ergebnisart beschreibt dieselbe Datenbasis. Umsätze und Positionen dürfen nicht über Ergebnisarten hinweg addiert werden. Gesamtzeilen haben kein Einzeljahr; `NULL` kennzeichnet nicht vorgesehene oder nicht berechenbare Werte.
- Elf Positionen aus sechs Bestellungen erhalten für fehlende Postleitzahlen `UNKNOWN`. Originalwerte bleiben erhalten; verlorene führende Nullen werden nicht rekonstruiert.
- 187 Positionen erhalten das Herstellerflag `CHECK` bei exakter Gleichheit von Hersteller und Produktname. `OK` ist kein umfassender Qualitätsnachweis; fehlende Hersteller werden nicht gesondert markiert.
- Der Reporting-Stack verwendet `INNER JOIN`. Die Join-Prüfung unter `04_joined_data/` ergab keine Bestellpositionen ohne passende Bestellung. Der vollständige Join über alle vier Tabellen wurde zusätzlich in den Join-Validierungen untersucht.
- Die dokumentierten Kontrollsummen gelten für den untersuchten Datenstand. Andere Datenstände können abweichende Ergebnisse liefern.

## Ergebnisprüfung der Regionsparameter

Der parametrisierte Reporting-Stack wurde mit den fünf Einstellungen `all`, `Central`, `East`, `South` und `West` getestet.

| Regionsfilter | Ergebniszeilen | Bestellpositionen | Gesamtumsatz |
|---|---:|---:|---:|
| all | 34 | 9.997 | 2.307.249 |
| Central | 22 | 2.323 | 501.256 |
| East | 22 | 2.856 | 690.268 |
| South | 22 | 1.616 | 390.313 |
| West | 22 | 3.202 | 725.412 |

### Ergebnis

Die vier Regionen ergeben zusammen 9.997 Bestellpositionen und einen Gesamtumsatz von 2.307.249. Damit stimmen ihre Kontrollsummen mit der Gesamtauswertung (`all`) überein.

Die Ausgabe für `all` umfasst 34 Zeilen und 12 Spalten. Jede einzelne Region liefert 22 Zeilen und 12 Spalten.

### Interpretation

Die Parametrisierung ermöglicht regionale Vergleiche, ohne die KPI-Definitionen oder den übrigen Business Scope zu verändern.

Die Kontrollsummen sind konsistent. Die unterschiedlichen Ergebnisarten verwenden jeweils dieselbe gefilterte Datenbasis und dürfen daher nicht miteinander addiert werden.

Die regionalen Umsatzentwicklungen unterscheiden sich. Für eine fundierte Wachstumsempfehlung müssen neben dem Umsatz auch Profitabilität und weitere Einflussfaktoren berücksichtigt werden.

### Reproduzierbarkeit

Die Regionsauswahl erfolgt über `parameters.region_filter`. Für einen neuen Test wird ausschließlich der Parameterwert geändert und die gesamte SQL-Abfrage erneut ausgeführt.

Die Testausgaben sind als `parameterized_stack_all.csv`, `parameterized_stack_central.csv`, `parameterized_stack_east.csv`, `parameterized_stack_south.csv` und `parameterized_stack_west.csv` dokumentiert.

Die Originaldaten bleiben unverändert.

## Mögliche Weiterentwicklungen

Datums- und Segmentfilter ergänzen; dabei unvollständige Jahre nicht als vollständige Jahresvergleiche ausweisen.

Die niedrige Furniture-Marge sowie die Profitabilität wachsender Regionen und Segmente untersuchen. Umsatzwachstum allein begründet keine Investitionsempfehlung.
## Zuordnung der KPI-Definitionen nach Paketbereinigung
Die fünf Haupt-KPIs mit JOIN-Auswertungen sind unter `03_kpis/kpi_definitions.md` definiert. Die zugehörigen SQL-Dateien sind gemeinsam unter `03_kpis/` abgelegt.
