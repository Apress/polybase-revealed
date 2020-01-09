USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'NorthCarolinaPopulationExcelTyped'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE NorthCarolinaPopulationExcelTyped WITH
    (
        LOCATION = 'odbc://clusterino',
        CONNECTION_OPTIONS = 'Driver={CData Excel Source}; DSN=NCPopTyped'
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationExcelTyped'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelTyped
    (
        RowID INT,
        SummaryLevel FLOAT(53),
        CountyID FLOAT(53),
        PlaceID FLOAT(53),
        IsPrimaryGeography FLOAT(53),
        Name NVARCHAR(4000),
        PopulationType NVARCHAR(4000),
        Year FLOAT(53),
        Population FLOAT(53)
    )
    WITH
    (
        LOCATION = 'NorthCarolinaPopulation',
        DATA_SOURCE = NorthCarolinaPopulationExcelTyped
    );
END

-- Succeeds.
SELECT * FROM dbo.NorthCarolinaPopulationExcelTyped;