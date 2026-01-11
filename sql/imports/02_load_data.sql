--Import the CSV
COPY orders
FROM '/Users/mohibabbas/Data Analyst Projects/supply-chain-analytics-sql-excel/data/raw/global_superstore.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');

