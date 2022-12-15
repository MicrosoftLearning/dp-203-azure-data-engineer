---
lab:
    title: 'Load Data into a Relational Data Warehouse'
---

# Load Data into a Relational Data Warehouse

In this exercise, you're going to load data into a dedicated SQL Pool.

This exercise should take approximately **30** minutes to complete.

## Before you start

You'll need an [Azure subscription](https://azure.microsoft.com/free) in which you have administrative-level access.

## Provision an Azure Synapse Analytics workspace

You'll need an Azure Synapse Analytics workspace with access to data lake storage. You can use the built-in serverless SQL pool to query files in the data lake.

In this exercise, you'll use a combination of a PowerShell script and an ARM template to provision an Azure Synapse Analytics workspace.

1. Sign into the [Azure portal](https://portal.azure.com) at `https://portal.azure.com`.
2. Use the **[\>_]** button to the right of the search bar at the top of the page to create a new Cloud Shell in the Azure portal, selecting a ***PowerShell*** environment and creating storage if prompted. The Cloud Shell provides a command line interface in a pane at the bottom of the Azure portal, as shown here:

    ![Azure portal with a cloud shell pane](./images/cloud-shell.png)

    > **Note**: If you have previously created a cloud shell that uses a *Bash* environment, use the the drop-down menu at the top left of the cloud shell pane to change it to ***PowerShell***.

3. Cloud Shell can be resized by dragging the separator bar at the top of the pane, or by using the —, **&#9723;**, and **X** icons at the top right of the pane to minimize, maximize, and close the pane. For more information about using the Azure Cloud Shell, see the [Azure Cloud Shell documentation](https://docs.microsoft.com/azure/cloud-shell/overview).

4. In the PowerShell pane, enter the following commands to clone this repository:

    ```powershell
    rm -r dp-203 -f
    git clone https://github.com/MicrosoftLearning/dp-203-azure-data-engineer dp-203
    ```

5. After the repository has been cloned, enter the following commands to change to the folder for this exercise, and run the **setup.ps1** script it contains:

    ```powershell
    cd dp-203/Allfiles/Labs/09
    ./setup.ps1
    ```

6. If prompted, choose which subscription you want to use (this option will only happen if you have access to multiple Azure subscriptions).
7. When prompted, enter a suitable password to be set for your Azure Synapse SQL pool.

    > **Note**: Be sure to remember this password!

8. Wait for the script to complete - typically this takes around 10 minutes, but in some cases may take longer. While you're waiting, review the [dedicated SQL pool (formerly SQL DW) in Azure Synapse Analytics](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-overview-what-is) article in the Azure Synapse Analytics documentation.

## View and Navigate Synapse Workspace

1. After the script has completed, in the Azure portal, go to the dp203-xxxxxxx resource group that it created, and select your Synapse workspace.
2. In the **Overview page** for your Synapse Workspace, in the **Open Synapse Studio** card, select **Open** to open Synapse Studio in a new browser tab; signing in if prompted.
3. On the left side of Synapse Studio, use the ›› icon to expand the menu - revealing the different pages within Synapse Studio that you’ll use to manage resources and perform data analytics tasks.
4. On the **Data** page, view the **Linked** tab and verify that your workspace includes a link to your Azure Data Lake Storage Gen2 storage account, which should have a name similar to **synapsexxxxxxx (Primary - datalakexxxxxxx)**.
5. Expand your storage account and verify that it contains a file system container named **files (primary)**.
6. Select the files container, and note that it contains folders named data and synapse. The synapse folder is used by Azure Synapse, and the data folder contains the data files you're going to query.
Open the sales folder and the orders folder it contains, and observe that the orders folder contains .csv files for dimCustomer, dimDate, dimProduct, and FactInternetSales data.
***Right-click*** any of the files and select Preview to see the data it contains. Note the files contain a header row, so you can select the option to display column headers.

### Start the dedicated SQL pool

1. Open the **synapse*xxxxxxx*** Synapse workspace, and on its **Overview** page, in the **Open Synapse Studio** card, select **Open** to open Synapse Studio in a new browser tab; signing in if prompted.
2. On the left side of Synapse Studio, use the **&rsaquo;&rsaquo;** icon to expand the menu - revealing the different pages within Synapse Studio.
3. On the **Manage** page, on the **SQL pools** tab, select the row for the **sql*xxxxxxx*** dedicated SQL pool and use it's **&#9655;** icon to start it; confirming that you want to resume it when prompted.
4. Wait for the SQL pool to resume. This can take a few minutes. You can use the **&#8635; Refresh** button to check its status periodically. The status will show as **Online** when it's ready.

## Load data warehouse tables

Let's look at some SQL Based approaches to loading data into the Data Warehouse.

1. Select the  **Data** panel.
2. Within this panel, select the **workspace** tab.
3. Expand the ***SQL Database***
4. On the database created with your **sqlxxxxxxx** suffix mouse-over the right-hand side of the panel until the ellipses appears, then left-click.
5. Select ***New SQL Script***.
6. Select ***Empty Script***.

    ![Select empty sql script](./images/select-empty-sql-script.png)

You now have a blank SQL page, which is connected to the instance for the following exercises.
## Loading data into staging tables

If you use external tables for staging, there's no need to load the data into them because they already reference the data files in the data lake. However, if you use "regular" relational tables, you can use the COPY statement to load data from the data lake, as shown in the following example:

>**NOTE**: Change the ***datalakexxxxxx*** with the name of your datalake name created during the beginning of the exercise

1. In the previously opened ***SQL Script*** type or, copy the following code into the window.
2. Press the **Run** button at the top of the ***SQL Script*** pane.

```sql
SELECT COUNT(1) 
FROM dbo.StageProduct

```

3. Be sure to replace the name, "datalakexxxxxxx." with the name of your datalake and prefix created during the beginning of the lab.
4. Copy/paste or type the following code into ***SQL Script*** window.

```sql
COPY INTO dbo.StageProduct
    (ProductID, ProductAlternateKey, ProductName, ProductCategory, Color, Size, ListPrice, Discontinued)
FROM 'https://datalakexxxxxx.blob.core.windows.net/files/data/StageProduct.csv'
WITH
(
    FILE_TYPE = 'CSV',
    MAXERRORS = 0,
    IDENTITY_INSERT = 'OFF',
    FIRSTROW = 2 --Defines where the first data row starts
);


SELECT COUNT(1) 
FROM dbo.StageProduct

```

5. Run the script by pressing the ctrl + e key combination or pressing the **Run** button at the top of the panel.
6. The use of "staging" tables allows us to review and change anything before moving or using it to append to or upsert into any existing dimension tables. The structure of this table will vary slightly as your read during the module depending upon the type of slowly changing dimensions (SCD) used.

Let's also bring in another table, which will be used for later using the same method.

1. In the previously opened ***SQL Script*** type or, copy the following code into the window.

>**NOTE**: Don't forget to change the ***datalakexxxxxx*** with the name of your datalake name in both the ```FROM``` and the ```ERRORFILE``` elements below.

1. Run the script by pressing the ctrl + e key combination or pressing the **Run** button at the top of the panel.

```sql
COPY INTO dbo.StageCustomer
(CustomerKey, GeographyKey, CustomerAlternateKey, Title, FirstName, MiddleName, LastName, NameStyle, BirthDate, 
MaritalStatus, Suffix, Gender, EmailAddress, YearlyIncome, TotalChildren, NumberChildrenAtHome, EnglishEducation, 
SpanishEducation, FrenchEducation, EnglishOccupation, SpanishOccupation, FrenchOccupation, HouseOwnerFlag, 
NumberCarsOwned, AddressLine1, AddressLine2, Phone, DateFirstPurchase, CommuteDistance)
FROM 'https://datalakexxxxxx.dfs.core.windows.net/files/data/StageCustomer.csv'
WITH
(
 FILE_TYPE = 'CSV'
 ,MAXERRORS = 0
 ,FIRSTROW = 2 --Defines where the first data row starts
 ,ERRORFILE = 'https://datalakexxxxxx.dfs.core.windows.net/files/'
)
--END
GO
```
4. Check your results by typing the following query to verify the data was loaded properly.

```sql
SELECT Top 100 *
FROM StageCustomer
```

## Loading staged data into dimension tables

Once you've staged and verified the data you can use it to look for changes between the existing and new data (Deltas), perform lookups to detect changes in dimensions, or load it into the dimension tables using SQL.

## Using a CREATE TABLE AS (CTAS) statement

> ***NOTE*** For more Information, see [CREATE TABLE AS SELECT (CTAS)](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-develop-ctas) in the Azure Synapse Analytics documentation.

The CREATE TABLE AS SELECT (CTAS) expression has various uses, which include:

1. redistributing the hash key of a table to align with other tables for better query performance.
2. assigning a surrogate key to a staging table based upon existing values after performing a delta analysis.
3. creating aggregate tables quickly for report purposes.

The statement allows for creating a new table with the results of a SELECT statement.

1. Create a new Query window or use the existing one making sure to highlight all existing content and delete it first. 
2. Type or paste the following code into the Query window

```sql
CREATE TABLE dbo.DimProduct
WITH
(
    DISTRIBUTION = HASH(ProductAltKey),
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT ROW_NUMBER() OVER(ORDER BY ProductID) AS ProductKey,
       ProductID AS ProductAltKey,
       ProductName,
       ProductCategory,
       Color,
       Size,
       ListPrice,
       Discontinued
FROM dbo.StageProduct
WHERE Color != 'NA' -- Pull Everything except undefined colors
```

3. As you can read from the query, we're using the StageProduct table with a filter on the color column and creating a new table named DimProduct. This table DimProduct is a distributed table using ProductAltKey as its hash distribution key and also has a Clustered Columnstore Index (CCI). 
4. You can view the results of this table by typing or copying/pasting the following code into the window below the CTAS.

```sql
SELECT ProductKey,
    ProductAltKey,
    ProductName,
    ProductCategory,
    Color,
    Size,
    ListPrice,
    Discontinued
FROM dbo.DimProduct
```

## Updating Dimension tables

As discussed in the module, there are several types of slowly changing dimensions (SCDs) and techniques to update them. let's look at a few.

1. type or copy/paste the following query into a new query window.
2. It's best to run each of the SCDs individually and then run a query before and after to see the actual impact on the table/row but in this run, we're going to perform several different types of SCDs.

```sql
-- Insert new customers noting the schemas of the tables are identical
SET IDENTITY_INSERT dbo.DimCustomer ON

INSERT INTO dbo.DimCustomer ([CustomerKey],[GeographyKey],[CustomerAlternateKey],[Title],[FirstName],[MiddleName],[LastName],[NameStyle],[BirthDate],[MaritalStatus],
[Suffix],[Gender],[EmailAddress],[YearlyIncome],[TotalChildren],[NumberChildrenAtHome],[EnglishEducation],[SpanishEducation],[FrenchEducation],
[EnglishOccupation],[SpanishOccupation],[FrenchOccupation],[HouseOwnerFlag],[NumberCarsOwned],[AddressLine1],[AddressLine2],[Phone],
[DateFirstPurchase],[CommuteDistance])
SELECT *
FROM dbo.StageCustomer AS stg
WHERE NOT EXISTS
    (SELECT * FROM dbo.DimCustomer AS dim
     WHERE dim.CustomerKey = stg.CustomerKey);

SET IDENTITY_INSERT dbo.DimCustomer OFF

--Look for type 1 updates in our staging file
SELECT dim.LastName, stg.LastName, dim.EmailAddress, stg.EmailAddress, dim.Phone, stg.Phone
FROM DimCustomer dim inner join StageCustomer stg
ON dim.CustomerKey = stg.CustomerKey
WHERE dim.LastName <> stg.LastName OR dim.EmailAddress <> stg.EmailAddress OR dim.Phone <> stg.Phone

-- Type 1 updates (name, email, phone)
UPDATE dbo.DimCustomer
SET LastName = stg.LastName,
    EmailAddress = stg.EmailAddress,
    Phone = stg.Phone
FROM DimCustomer dim inner join StageCustomer stg
ON dim.CustomerKey = stg.CustomerKey
WHERE dim.LastName <> stg.LastName OR dim.EmailAddress <> stg.EmailAddress OR dim.Phone <> stg.Phone

-- Type 2 updates (geographic address changes triggers new entry)
INSERT INTO dbo.DimCustomer
SELECT stg.GeographyKey,stg.CustomerAlternateKey,stg.Title,stg.FirstName,stg.MiddleName,stg.LastName,stg.NameStyle,stg.BirthDate,stg.MaritalStatus,
stg.Suffix,stg.Gender,stg.EmailAddress,stg.YearlyIncome,stg.TotalChildren,stg.NumberChildrenAtHome,stg.EnglishEducation,stg.SpanishEducation,stg.FrenchEducation,
stg.EnglishOccupation,stg.SpanishOccupation,stg.FrenchOccupation,stg.HouseOwnerFlag,stg.NumberCarsOwned,stg.AddressLine1,stg.AddressLine2,stg.Phone,
stg.DateFirstPurchase,stg.CommuteDistance
FROM dbo.StageCustomer AS stg
JOIN dbo.DimCustomer AS dim
ON stg.CustomerKey = dim.CustomerKey
WHERE stg.AddressLine1 <> dim.AddressLine1 OR stg.AddressLine2 <> dim.AddressLine2;
```

3. Press the **Run** button or ctrl + e to execute the code.

As an alternative to using multiple ```INSERT``` and ```UPDATE``` statement, you can use a single ```MERGE``` statement to perform an ```UPSERT``` operation to insert new records and update existing ones, as shown in the following example, which loads new product records and applies type 1 updates to existing products:

1. type or copy/paste the following query into a ***new query window***.
2. Press the **Run** button to execute the code.

```sql
MERGE dbo.DimProduct AS tgt
    USING (SELECT ProductID, ProductAlternateKey, ProductName, ProductCategory, Color, Size,
    ListPrice, Discontinued FROM dbo.StageProduct) AS src
    ON src.ProductID = tgt.ProductAltKey
WHEN MATCHED THEN
    UPDATE SET
        tgt.ProductKey = src.ProductID,
        tgt.ProductAltKey = src.ProductID,
        tgt.ProductName = src.ProductName,
        tgt.ProductCategory = src.ProductCategory,
        tgt.Color = src.Color,
        tgt.Size = src.Size,
        tgt.ListPrice = src.ListPrice,
        tgt.Discontinued = src.Discontinued
WHEN NOT MATCHED THEN
    INSERT VALUES
        (src.ProductID,
         src.ProductID,
         src.ProductName,
         src.ProductCategory,
         src.Color,
         src.Size,
         src.ListPrice,
         src.Discontinued);
```

## Optimize Load Performance

After loading new data into the data warehouse, it's a recommended [best practice](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-statistics) to rebuild the table columnstore indexes and update statistics on commonly queried columns.

The following example rebuilds all indexes on the DimProduct table.

1. type or copy/paste the following query into a ***new or existing query window***.
2. Press the **Run** button to execute the code.

```sql
ALTER INDEX ALL ON dbo.DimProduct REBUILD
```

The following example creates statistics on the ProductCategory column of the DimProduct table:

1. type or copy/paste the following query into a ***new or existing query window***.
2. Press the **Run** button to execute the code.

```sql
CREATE STATISTICS productcategory_stats
ON dbo.DimProduct (ProductCategory);
```

>**NOTE** For more information, see the [Indexes on dedicated SQL pool tables in Azure Synapse Analytics](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-index) and [Table statistics for dedicated SQL pool in Azure Synapse Analytics articles](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-statistics) in the Azure Synapse Analytics documentation.

## Delete Azure resources

If you've finished exploring Azure Synapse Analytics, you should delete the resources you've created to avoid unnecessary Azure costs.

1. Close the Synapse Studio browser tab and return to the Azure portal.
2. On the Azure portal, on the **Home** page, select **Resource groups**.
3. Select the **dp203-*xxxxxxx*** resource group for your Synapse Analytics workspace (not the managed resource group), and verify that it contains the Synapse workspace, storage account, and Spark pool for your workspace.
4. At the top of the **Overview** page for your resource group, select **Delete resource group**.
5. Enter the **dp203-*xxxxxxx*** resource group name to confirm you want to delete it, and select **Delete**.

    After a few minutes, your Azure Synapse workspace resource group and the managed workspace resource group associated with it will be deleted.
