USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'NorthCarolinaPopulationExcelUntyped'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE NorthCarolinaPopulationExcelUntyped WITH
    (
        LOCATION = 'odbc://noplace',
        CONNECTION_OPTIONS = 'Driver={CData Excel Source}; DSN=NCPopUntyped'
    );
END
GO

IF EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationExcelUntyped'
)
BEGIN
    DROP EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelUntyped;
END
GO
CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelUntyped
(
    RowID INT,
    SUMLEV NVARCHAR(150),
    COUNTY NVARCHAR(150),
    PLACE NVARCHAR(150),
    PRIMGEO_FLAG NVARCHAR(150),
    NAME NVARCHAR(150),
    POPTYPE NVARCHAR(150),
    YEAR NVARCHAR(150),
    POPULATION NVARCHAR(150)
)
WITH
(
    LOCATION = 'NorthCarolinaPopulation',
    DATA_SOURCE = NorthCarolinaPopulationExcelUntyped
);

-- Succeeds.
SELECT
    COUNTY, PLACE, primgeo_flag, name
FROM dbo.NorthCarolinaPopulationExcelUntyped;

-- Succeeds.
SELECT
    SUMLEV, COUNTY, PLACE, primgeo_flag, name
FROM dbo.NorthCarolinaPopulationExcelUntyped;

-- Succeeds.
SELECT * FROM dbo.NorthCarolinaPopulationExcelUntyped;
