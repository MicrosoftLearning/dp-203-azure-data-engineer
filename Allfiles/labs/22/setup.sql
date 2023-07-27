SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE TABLE [dbo].[Product](
    [ProductKey] [int] NOT NULL,
    [ProductName] [nvarchar](50) NULL,
    [Category][nvarchar](50) NULL,
    [ListPrice] [money] NULL)
WITH
(
	DISTRIBUTION = HASH(ProductKey),
	CLUSTERED COLUMNSTORE INDEX
);
GO

INSERT DimProduct
VALUES('786','Mountain-300 Black','Mountain Bikes',2294.9900);
GO
