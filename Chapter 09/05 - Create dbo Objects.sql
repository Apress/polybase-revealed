-- Load each of the tables into the dbo schema.
-- The scripts are slightly modified from https://docs.microsoft.com/en-us/azure/sql-data-warehouse/load-data-from-azure-blob-storage-using-polybase.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Date'
)
BEGIN
	CREATE TABLE [dbo].[Date]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[Date]
	OPTION (LABEL = 'CTAS : Load [dbo].[Date]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Geography'
)
BEGIN
	CREATE TABLE [dbo].[Geography]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS
	SELECT * FROM [ext].[Geography]
	OPTION (LABEL = 'CTAS : Load [dbo].[Geography]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'HackneyLicense'
)
BEGIN
	CREATE TABLE [dbo].[HackneyLicense]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[HackneyLicense]
	OPTION (LABEL = 'CTAS : Load [dbo].[HackneyLicense]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Medallion'
)
BEGIN
	CREATE TABLE [dbo].[Medallion]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[Medallion]
	OPTION (LABEL = 'CTAS : Load [dbo].[Medallion]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Time'
)
BEGIN
	CREATE TABLE [dbo].[Time]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[Time]
	OPTION (LABEL = 'CTAS : Load [dbo].[Time]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Weather'
)
BEGIN
	CREATE TABLE [dbo].[Weather]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[Weather]
	OPTION (LABEL = 'CTAS : Load [dbo].[Weather]');
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		schema_id = SCHEMA_ID('dbo')
		AND name = N'Trip'
)
BEGIN
	CREATE TABLE [dbo].[Trip]
	WITH
	(
		DISTRIBUTION = ROUND_ROBIN,
		CLUSTERED COLUMNSTORE INDEX
	)
	AS SELECT * FROM [ext].[Trip]
	OPTION (LABEL = 'CTAS : Load [dbo].[Trip]');
END
GO
