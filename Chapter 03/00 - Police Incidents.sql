IF (DB_ID('PolyBaseRevealed') IS NULL)
BEGIN
	CREATE DATABASE PolyBaseRevealed;
END
GO
USE PolyBaseRevealed
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources s
	WHERE
		s.name = N'Clusterino'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE Clusterino WITH
	(
		TYPE = HADOOP,
		LOCATION = 'hdfs://clusterino:8020',
		RESOURCE_MANAGER_LOCATION = N'clusterino:8050'
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
IF (OBJECT_ID('dbo.RaleighPoliceIncidents') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE dbo.RaleighPoliceIncidents
	(
		ObjectID INT NOT NULL,
		--NOTE:  uniqueidentifier is not supported for external tables.
		GlobalID VARCHAR(36) NULL,
		CaseNumber VARCHAR(100) NULL,
		CrimeCategory VARCHAR(130) NULL,
		CrimeCode VARCHAR(10) NULL,
		CrimeDescription VARCHAR(250) NULL,
		CrimeType VARCHAR(100) NULL,
		ReportedBlockAddress VARCHAR(150) NULL,
		CityOfIncident VARCHAR(100) NULL,
		City VARCHAR(100) NULL,
		District VARCHAR(50) NULL,
		ReportedDate DATETIME2(3) NULL,
		ReportedYear INT NULL,
		ReportedMonth TINYINT NULL,
		ReportedDay TINYINT NULL,
		ReportedHour TINYINT NULL,
		ReportedDayOfWeek VARCHAR(15) NULL,
		Latitude VARCHAR(30) NULL,
		Longitude VARCHAR(30) NULL,
		Agency VARCHAR(50) NULL,
		UpdatedDate DATETIME2(3) NULL
	)
	WITH
	(
		LOCATION = N'/PolyBaseData/Raleigh_Police_Incidents_NIBRS.csv',
		DATA_SOURCE = Clusterino,
		FILE_FORMAT = CsvFileFormat,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 5000
	);
END
GO

--Ensure that we get data back without error.
--If you do not fix the datetimes to remove T and Z, this will return an error.
SELECT TOP(10) * FROM dbo.RaleighPoliceIncidents;
GO

--232,128 out of 232,128
SELECT COUNT(1) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;
--232,128
SELECT COUNT(*) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;
--232,128
SELECT COUNT(District) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;
--232,127 -- the header row fails conversion and gets rejected.
SELECT COUNT(UpdatedDate) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;

--232,128 rows returned.
SELECT COUNT(District) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;
--232,127 rows returned.
SELECT COUNT(UpdatedDate) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents;

--Calculate incidents by year
SELECT
	rpi.ReportedYear,
	COUNT(1) AS NumberOfIncidents
FROM dbo.RaleighPoliceIncidents rpi
GROUP BY
	rpi.ReportedYear
ORDER BY
	rpi.ReportedYear;