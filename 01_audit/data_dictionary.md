# Unicorn – Data Dictionary



Verantwortlich: Suryandi

Datenbank: Unicorn

SQL-Dialekt: PostgreSQL 15.19

Zeitraum: 2015–2018



Dieses Datenwörterbuch beschreibt die vier Tabellen customers, orders, order\_details und product.



## 1\. customers

**Grain:** Eine Zeile entspricht einem Kunden.

|Column|Type|Key|Description|Notes|
|-|-|-|-|-|
|customer\_id|bigint|PK|Eindeutige ID des Kunden|795 eindeutige Werte|
|customer\_name|text|-|Name des Kunden|Keine fehlenden oder leeren Werte gefunden|
|customer\_segment|text|-|Kundensegment|Consumer, Corporate, Home Office|


## 2\. orders

**Grain:** Eine Zeile entspricht einer Bestellung.

|Column|Type|Key|Description|Notes|
|-|-|-|-|-|
|order\_id|text|PK|Eindeutige ID der Bestellung|5013 eindeutige Werte|
|customer\_id|bigint|FK|ID des Kunden, der die Bestellung aufgegeben hat|Verweist auf customers.customer\_id|
|order\_date|timestamp without time zone|-|Datum der Bestellung|Bestelldatum|
|shipping\_city|text|-|Stadt der Lieferadresse|-|
|shipping\_state|text|-|Bundesstaat der Lieferadresse|-|
|shipping\_region|text|-|Versandregion|West, East, Central, South|
|shipping\_country|text|-|Land der Lieferadresse|-|
|shipping\_postal\_code|bigint|-|Postleitzahl der Lieferadresse|6 fehlende Werte; alle betreffen Burlington, Vermont|
|shipping\_date|timestamp without time zone|-|Versanddatum der Bestellung|Kein Versanddatum liegt vor dem Bestelldatum|
|shipping\_mode|text|-|Versandart|Versandmethode der Bestellung|


## 3\. order\_details

**Grain:** Eine Zeile entspricht einem Produkt innerhalb einer Bestellung.

|Column|Type|Key|Description|Notes|
|-|-|-|-|-|
|order\_details\_id|bigint|PK|Eindeutige ID der Bestellposition|9997 eindeutige Werte|
|order\_id|text|FK|ID der zugehörigen Bestellung|Verweist auf orders.order\_id|
|product\_id|bigint|FK|ID des bestellten Produkts|Verweist auf product.product\_id|
|quantity|bigint|-|Bestellte Menge|Keine ungültigen Mengen gefunden|
|order\_discount|double precision|-|Rabatt der Bestellposition|Werte zwischen 0 und 1|
|order\_sales|double precision|-|Umsatz der Bestellposition|Numerischer Verkaufswert|
|order\_profits|double precision|-|Gewinn der Bestellposition|Negative Werte kommen vor|
|order\_profit\_ratio|double precision|-|Verhältnis von Gewinn zu Umsatz|Negative Werte können bei Verlusten vorkommen|


## 4\. product

**Grain:** Eine Zeile entspricht einem Produkt.

|Column|Type|Key|Description|Notes|
|-|-|-|-|-|
|product\_id|bigint|PK|Eindeutige ID des Produkts|1850 eindeutige Werte|
|product\_name|text|-|Name des Produkts|Freitext|
|product\_category|text|-|Produktkategorie|Furniture, Office Supplies, Technology|
|product\_subcategory|text|-|Unterkategorie des Produkts|17 unterschiedliche Unterkategorien|
|product\_manufacturer|text|-|Hersteller des Produkts|356 Produkte haben den Wert "Other"|


## Hinweis zur Währung

Die Währung der Umsatz- und Gewinnwerte ist in der verfügbaren
Projektdokumentation nicht angegeben. Geldbeträge werden daher
in den Einheiten des Datensatzes ausgewiesen und nicht als EUR
oder USD bezeichnet. Prozentuale Kennzahlen bleiben davon unberührt.


## Beobachtete Wertebereiche im gelieferten Snapshot

Land: United States. Versandarten: First Class, Same Day, Second Class, Standard Class.

Produkt-Unterkategorien: Accessories, Appliances, Art, Binders, Bookcases, Chairs, Copiers, Envelopes, Fasteners, Furnishings, Labels, Machines, Paper, Phones, Storage, Supplies, Tables.

Die dokumentierten SQL-Typen beschreiben die ursprüngliche Datenbank; CSV-Dateien speichern keine SQL-Typinformationen. Vor erneutem Serverlauf die Typen gegen information\_schema.columns prüfen.

