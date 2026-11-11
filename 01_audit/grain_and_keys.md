# Unicorn – Grain and Keys

Verantwortlich: Suryandi
Datenbank: Unicorn
SQL-Dialekt: PostgreSQL 15.19
Zeitraum: 2015–2018


## customers

Grain: Eine Zeile entspricht einem Kunden.  
Primary Key: customer_id – jeder Wert ist eindeutig.  
Beobachtung: 795 Zeilen und 795 eindeutige customer_id-Werte.

SQL zur Prüfung des Primary Keys:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_keys
FROM customers;
```

Ergebnis: 795 Zeilen und 795 eindeutige customer_id-Werte.


## orders

Grain: Eine Zeile entspricht einer Bestellung.  
Primary Key: order_id.  
Beobachtung: 5013 Zeilen und 5013 eindeutige order_id-Werte.

SQL zur Prüfung des Primary Keys:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_keys
FROM orders;
```

Ergebnis: 5013 Zeilen und 5013 eindeutige order_id-Werte.


## order_details

Grain: Eine Zeile entspricht einem Produkt innerhalb einer Bestellung.  
Primary Key: order_details_id.  
Beobachtung: 9997 Zeilen und 9997 eindeutige order_details_id-Werte.

SQL zur Prüfung des Primary Keys:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_details_id) AS unique_keys
FROM order_details;
```

Ergebnis: 9997 Zeilen und 9997 eindeutige order_details_id-Werte.


## product

Grain: Eine Zeile entspricht einem Produkt.  
Primary Key: product_id.  
Beobachtung: 1850 Zeilen und 1850 eindeutige product_id-Werte.

SQL zur Prüfung des Primary Keys:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_keys
FROM product;
```

Ergebnis: 1850 Zeilen und 1850 eindeutige product_id-Werte.