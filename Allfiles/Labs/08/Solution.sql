-- Items sold by Fiscal Year and Quarter
SELECT  d.FiscalYear AS FY,
        d.FiscalQuarter AS FQ,
        SUM(r.OrderQuantity) AS ItemsSold
FROM FactResellerSales AS r
JOIN DimDate AS d ON r.OrderDateKey = d.DateKey
GROUP BY d.FiscalYear, d.FiscalQuarter
ORDER BY FY, FQ;


-- Items sold by Fiscal Year, Quarter, and sales territory region
SELECT  d.FiscalYear AS FY,
        d.FiscalQuarter AS FQ,
        t. SalesTerritoryRegion AS SalesTerritory,
        SUM(r.OrderQuantity) AS ItemsSold
FROM FactResellerSales AS r
JOIN DimDate AS d ON r.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON r.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.FiscalYear, d.FiscalQuarter, t. SalesTerritoryRegion
ORDER BY FY, FQ, SalesTerritory


-- Items sold by Fiscal Year, Quarter, sales territory region, and product category
SELECT  d.FiscalYear AS FY,
        d.FiscalQuarter AS FQ,
        t. SalesTerritoryRegion AS SalesTerritory,
        pc.EnglishProductCategoryName AS ProductCategory,
        SUM(r.OrderQuantity) AS ItemsSold
FROM FactResellerSales AS r
JOIN DimDate AS d ON r.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON r.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
JOIN DimProduct AS p ON r.ProductKey = p.ProductKey
JOIN DimProductSubcategory AS ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY d.FiscalYear, d.FiscalQuarter, t. SalesTerritoryRegion, pc.EnglishProductCategoryName
ORDER BY FY, FQ, SalesTerritory, ProductCategory


-- Ranked sales territories by year based on total sales amount
SELECT  d.FiscalYear,
        t. SalesTerritoryRegion AS SalesTerritory,
        SUM(s.SalesAmount) AS TerritoryTotal,
        SUM(SUM(s.SalesAmount)) OVER(PARTITION BY d.FiscalYear) AS YearTotal,
        RANK() OVER(PARTITION BY d.FiscalYear
                    ORDER BY SUM(s.SalesAmount) DESC) AS RankForYear
FROM FactResellerSales AS s
JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON s.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.FiscalYear, t.SalesTerritoryRegion
ORDER BY d.FiscalYear;


-- Approximate number of sales orders per fiscal year by territory
SELECT  d.FiscalYear,
        t. SalesTerritoryRegion AS SalesTerritory,
        APPROX_COUNT_DISTINCT(s.SalesOrderNumber) AS ApproxOrders
FROM FactResellerSales AS s
JOIN DimDate AS d ON s.OrderDateKey = d.DateKey
JOIN DimEmployee AS e ON s.EmployeeKey = e.EmployeeKey
JOIN DimSalesTerritory AS t ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY d.FiscalYear, t.SalesTerritoryRegion
ORDER BY d.FiscalYear, ApproxOrders;
