CREATE DATABASE lakedb;
GO

USE lakedb;
GO

CREATE CREDENTIAL [https://datalakexxxxxxx.dfs.core.windows.net/files/products/products.csv]
WITH IDENTITY='Managed Identity';
GO

CREATE VIEW products_csv
AS
SELECT *
FROM
    OPENROWSET(
        BULK 'https://datalakexxxxxxx.dfs.core.windows.net/files/products/products.csv',
        FORMAT = 'CSV',
        HEADER_ROW = TRUE,
        PARSER_VERSION = '2.0'
    ) AS [result];
GO
