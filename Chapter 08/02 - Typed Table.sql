USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationTypedSpark'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationTypedSpark
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
        LOCATION = 'NorthCarolinaPopulationTyped',
        DATA_SOURCE = ClusterinoSpark
    );
END
GO

SELECT
    ncp.Name,
    ncp.PopulationType,
    ncp.Population
FROM dbo.NorthCarolinaPopulationTypedSpark ncp
    INNER JOIN dbo.CityPopulationCenter cpc 
        ON ncp.Name = cpc.CityName
WHERE
    ncp.PopulationType = 'CENSUSPOP'
    AND ncp.Year = 2010
    AND ncp.IsPrimaryGeography = 0;
