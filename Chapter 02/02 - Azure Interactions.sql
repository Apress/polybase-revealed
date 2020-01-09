USE PolyBaseRevealed
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<<SomeSecureKey>>';
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

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

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'CsvFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT CsvFileFormat WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N',',
            USE_TYPE_DEFAULT = True,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO

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
    FILE_FORMAT = CsvFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 5
);
GO

--Quick SELECT * to ensure that data loads as expected.
--Note 13607 rows returned but CSV has 13611
SELECT
    ncp.SumLev AS SummaryLevel,
    ncp.County,
    ncp.Place,
    ncp.IsPrimaryGeography,
    ncp.Name,
    ncp.PopulationType,
    ncp.Year,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp;
GO
--Filters work as you'd expect:  full town population estimates for 2017.
SELECT
    ncp.Name,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
ORDER BY
    Population DESC,
    Name ASC;
GO

--Join to a SQL table
IF (OBJECT_ID('dbo.PopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.PopulationCenter
    (
        PopulationCenterName VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED
    );

    INSERT INTO dbo.PopulationCenter
    (
        PopulationCenterName
    )
    VALUES
        ('Triangle'),
        ('Triad');
END
GO
IF (OBJECT_ID('dbo.CityPopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.CityPopulationCenter
    (
        CityName VARCHAR(120) NOT NULL,
        PopulationCenterName VARCHAR(30) NOT NULL,
        CONSTRAINT [PK_CityPopulationCenter]
            PRIMARY KEY CLUSTERED(CityName, PopulationCenterName),
        CONSTRAINT [FK_CityPopulationCenter_PopulationCenter]
            FOREIGN KEY(PopulationCenterName)
            REFERENCES dbo.PopulationCenter(PopulationCenterName)
    );
    INSERT INTO dbo.CityPopulationCenter
    (
        CityName,
        PopulationCenterName
    )
    VALUES
        ('Burlington city', 'Triad'),
        ('Greensboro city', 'Triad'),
        ('High Point city', 'Triad'),
        ('Winston-Salem city', 'Triad'),
        ('Apex town', 'Triangle'),
        ('Cary town', 'Triangle'),
        ('Chapel Hill town', 'Triangle'),
        ('Durham city', 'Triangle'),
        ('Raleigh city', 'Triangle');
END
GO
SELECT
    ncp.Name,
    cpc.PopulationCenterName,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp
    LEFT OUTER JOIN dbo.CityPopulationCenter cpc
        ON ncp.Name = cpc.CityName
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
ORDER BY
    Population DESC,
    Name ASC;
GO

--Aggregations and other operations work too.
SELECT
    cpc.PopulationCenterName,
    SUM(ncp.Population) AS TotalPopulation
FROM dbo.NorthCarolinaPopulation ncp
    INNER JOIN dbo.CityPopulationCenter cpc
        ON ncp.Name = cpc.CityName
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
GROUP BY
    cpc.PopulationCenterName;
GO

/*** Phase 2:  inserting into Azure with PolyBase ***/
EXEC sp_configure
    @configname = 'allow polybase export',
    @configvalue = 1;
GO
RECONFIGURE
GO
CREATE EXTERNAL DATA SOURCE AzureVisitsBlob WITH
(
    TYPE = HADOOP,
    LOCATION = 'wasbs://visits@cspolybaseblob.blob.core.windows.net',
    CREDENTIAL = AzureStorageCredential
);
GO
/* Only works with Azure SQL DW!
CREATE EXTERNAL FILE FORMAT CsvFileFormatSkipHeaders WITH
(
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS
    (
        FIELD_TERMINATOR = N',',
        USE_TYPE_DEFAULT = True,
        FIRST_ROW = 2
    )
);
GO */
CREATE EXTERNAL TABLE dbo.Visits
(
    PersonID INT NOT NULL,
    LocationID INT NOT NULL,
    VisitDate DATE NOT NULL
)
WITH
(
    LOCATION = N'Visits/',
    DATA_SOURCE = AzureVisitsBlob,
    FILE_FORMAT = CsvFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 1
);

--Query original file data
SELECT
    v.PersonID,
    p.FirstName,
    p.LastName,
    v.LocationID,
    l.LocationName,
    v.VisitDate
FROM dbo.Visits v
    INNER JOIN dbo.Person p
        ON v.PersonID = p.PersonID
    CROSS APPLY
    (
        SELECT TOP(1)
            l.LocationName
        FROM dbo.Location l
        WHERE
            l.LocationID = v.LocationID
    ) l;
GO

--Insert a new visitation
INSERT INTO dbo.Visits
(
        PersonID,
        LocationID,
        VisitDate
 )
VALUES
    (1,1,'1900-01-01');
GO

--Observe the new record
SELECT
    v.PersonID,
    p.FirstName,
    p.LastName,
    v.LocationID,
    l.LocationName,
    v.VisitDate
FROM dbo.Visits v
    INNER JOIN dbo.Person p
        ON v.PersonID = p.PersonID
    CROSS APPLY
    (
        SELECT TOP(1)
            l.LocationName
        FROM dbo.Location l
        WHERE
            l.LocationID = v.LocationID
    ) l
ORDER BY
    v.VisitDate ASC,
    v.PersonID ASC;
GO

SELECT
    r.sql_handle,
    t.text,
    r.execution_id,
    r.status,
    r.error_id,
    r.start_time,
    r.end_time,
    r.total_elapsed_time
FROM sys.dm_exec_distributed_requests r
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t;
SELECT
    r.*
FROM sys.dm_exec_distributed_request_steps r
WHERE
    r.execution_id = 'QID59'
ORDER BY
    start_time ASC;