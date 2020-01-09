USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials dsc
    WHERE
        dsc.name = N'HiveCredential'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL HiveCredential
    WITH IDENTITY = '<Your Username>', Secret = '<Your Password>';
END
GO

CREATE EXTERNAL DATA SOURCE ClusterinoHive WITH
(
    LOCATION = 'odbc://clusterino:10000',
    CONNECTION_OPTIONS = 'Driver={Cloudera ODBC Driver for Apache Hive}; Host = clusterino; Port = 10000; Database = default; ServerNode = clusterino:10000; ssl=false',
    --CONNECTION_OPTIONS = 'Driver={Cloudera ODBC Driver for Apache Hive}; Host = clusterino; Port = 10000; Database = default; ServerNode = clusterino:10000',
    CREDENTIAL = HiveCredential,
    PUSHDOWN = ON
);
GO

CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationHive
(
    SummaryLevel INT,
    CountyID INT,
    PlaceID INT,
    IsPrimaryGeography BIT,
    Name NVARCHAR(255),
    PopulationType NVARCHAR(255),
    Year INT,
    Population INT
)
WITH
(
    LOCATION = 'northcarolinapopulation',
    DATA_SOURCE = ClusterinoHive
);
GO

SELECT * FROM dbo.NorthCarolinaPopulationHive;