SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE TABLE [dbo].[DimProduct](
    [ProductKey] [int] IDENTITY NOT NULL,
    [ProductAltKey] [nvarchar](30) NULL,
    [ProductName] [nvarchar](50) NULL,
    [Color] [nvarchar](30) NULL,
    [Size] [nvarchar](50) NULL,
    [ListPrice] [money] NULL,
    [Discontinued] [bit] NULL)
WITH
(
	DISTRIBUTION = HASH(ProductAltKey),
	CLUSTERED COLUMNSTORE INDEX
);
GO

INSERT DimProduct
VALUES('AR-5381','Adjustable Race','Red',NULL,1.99,0);
GO
