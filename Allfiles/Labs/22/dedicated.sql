-- Create a table
CREATE TABLE dbo.products(
	ProductID INT NOT NULL,
	ProductName NVARCHAR (100) NOT NULL,
	Category NVARCHAR (100) NOT NULL,
	ListPrice DECIMAL NULL
);
GO

PRINT 'products table created.';
GO

