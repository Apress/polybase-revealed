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

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationExcelUntyped'
)
BEGIN
    drop  EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelUntyped
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelUntyped
    (
        RowID INT,
        SUMLEV NVARCHAR(4000),
        COUNTY NVARCHAR(4000),
        PLACE NVARCHAR(4000),
        PRIMGEO_FLAG NVARCHAR(4000),
        NAME NVARCHAR(4000),
        POPTYPE NVARCHAR(4000),
        YEAR NVARCHAR(4000),
        POPULATION NVARCHAR(4000)
    )
    WITH
    (
        LOCATION = 'NorthCarolinaPopulation',
        DATA_SOURCE = NorthCarolinaPopulationExcelUntyped
    );
END
GO

-- Succeeds.
SELECT
    COUNTY, PLACE, primgeo_flag, name
FROM dbo.NorthCarolinaPopulationExcelUntyped;

-- Throws a buffer error.
SELECT
    SUMLEV, COUNTY, PLACE, primgeo_flag, name
FROM dbo.NorthCarolinaPopulationExcelUntyped;

/*
Msg 7320, Level 16, State 110, Line 1
Cannot execute the query "Remote Query" against OLE DB provider "SQLNCLI11" for linked server "(null)". 105082;
    Generic ODBC error: COdbcReadConnection::ReadBuffer: not enough buffer space for one row |
    Error calling: pReadConn->ReadBuffer(pBuffer, bufferOffset, bufferLength, pBytesRead, pRowsRead) |
    state: FFFF, number: 58, active connections: 9.
Total execution time: 00:00:03.882
*/