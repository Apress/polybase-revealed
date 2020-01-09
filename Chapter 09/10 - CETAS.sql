-- This shows the CREATE EXTERNAL TABLE AS SELECT (CETAS) syntax to move data to Azure Blob Storage from Azure SQL Data Warehouse.
-- This behavior is only available for Azure SQL Data Warehouse.

CREATE EXTERNAL TABLE ext.PolyBaseTime
WITH
(
	LOCATION = '/Taxi/Time',
	DATA_SOURCE = AzureNCPopBlob,
	FILE_FORMAT = CSV
)
AS
SELECT *
FROM dbo.Time;

-- Query the table to ensure that we have the data.
SELECT *
FROM ext.PolyBaseTime;

-- Check Storage Explorer to ensure that we have the data.