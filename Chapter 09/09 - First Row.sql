-- We can ignore the first 1-15 rows.  This will let us ignore headers without rows showing up as rejected.
-- This behavior is only available for Azure SQL Data Warehouse.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_file_formats eff
	WHERE
		name = N'CSVRow2'
)
BEGIN
	CREATE EXTERNAL FILE FORMAT CSVRow2 WITH
	(
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS
		(
			FIELD_TERMINATOR = ',',
			STRING_DELIMITER = '',
			DATE_FORMAT = '',
			USE_TYPE_DEFAULT = FALSE,
			FIRST_ROW = 2
		)
	);
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'NorthCarolinaPopulation'
)
BEGIN
	DROP EXTERNAL TABLE dbo.NorthCarolinaPopulation;
END
GO
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
		FILE_FORMAT = CSVRow2,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 5,
		REJECTED_ROW_LOCATION = 'Reject/NorthCarolinaPopulation'
	);
END
GO

SELECT *
FROM dbo.NorthCarolinaPopulation;
-- We can now review the rejected rows in Azure Blob Storage.
-- The set of rejected rows no longer includes our header.