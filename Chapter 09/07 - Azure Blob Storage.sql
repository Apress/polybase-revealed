-- Test connecting to Azure Blob Storage
IF NOT EXISTS
(
	SELECT 1
	FROM sys.database_scoped_credentials c
	WHERE
		c.name = N'AzureStorageCredential'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
	WITH IDENTITY = '<Your blob account>',
	SECRET = '<Your secret>';
END
GO

IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources eds
	WHERE
		eds.name = N'AzureNCPopBlob'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE AzureNCPopBlob WITH
	(
		TYPE = HADOOP,
		LOCATION = 'wasbs://ncpop@<Your blob account>.blob.core.windows.net',
		CREDENTIAL = AzureStorageCredential
	);
END
GO

-- This is a data virtualization scenario, so instead of using the ext schema,
-- we will create the table in dbo.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'NorthCarolinaPopulation'
)
BEGIN
	CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulation
	(
		SumLev INT NOT NULL,
		County INT NOT NULL,
		Place INT NOT NULL,
		IsPrimaryGeography BIT NOT NULL,
		[Name] VARCHAR(120) NOT NULL,
		PopulationType VARCHAR(20) NOT NULL,
		Year INT NOT NULL,
		Population INT NOT NULL
	)
	WITH
	(
		LOCATION = N'Census/NorthCarolinaPopulation.csv',
		DATA_SOURCE = AzureNCPopBlob,
		FILE_FORMAT = CSV,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 5
	);
END
GO

-- Ensure that the table loaded correctly.
SELECT *
FROM dbo.NorthCarolinaPopulation;
