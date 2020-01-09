USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials dsc
    WHERE
        dsc.name = N'SparkCredential'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL SparkCredential
    WITH IDENTITY = '<Your Username>', Secret = '<Your Password>';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'ClusterinoSpark'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE ClusterinoSpark WITH
    (
        LOCATION = 'odbc://clusterino:10016',
        CONNECTION_OPTIONS = 'Driver={Hortonworks Spark ODBC Driver}; Host = clusterino; Port = 10016; Database = default; ServerNode = clusterino:10016',
        CREDENTIAL = SparkCredential,
        PUSHDOWN = ON
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationSpark'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationSpark
    (
        SUMLEV NVARCHAR(255),
        COUNTY NVARCHAR(255),
        PLACE NVARCHAR(255),
        PRIMGEO_FLAG NVARCHAR(255),
        NAME NVARCHAR(255),
        POPTYPE NVARCHAR(255),
        YEAR NVARCHAR(255),
        POPULATION NVARCHAR(255)
    )
    WITH
    (
        LOCATION = 'NorthCarolinaPopulation',
        DATA_SOURCE = ClusterinoSpark
    );
END
GO

SELECT * FROM dbo.NorthCarolinaPopulationSpark;