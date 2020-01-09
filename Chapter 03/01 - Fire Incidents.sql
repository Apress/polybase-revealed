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
        e.name = N'TsvFileFormat'
)
BEGIN
	CREATE EXTERNAL FILE FORMAT TsvFileFormat WITH
	(
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS
		(
			FIELD_TERMINATOR = N'\t',
			USE_TYPE_DEFAULT = True,
			STRING_DELIMITER = '"',
			ENCODING = 'UTF8'
		)
	);
END
GO
IF (OBJECT_ID('dbo.FireIncidents') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.FireIncidents
    (
        X FLOAT NULL,
        Y FLOAT NULL,
        OBJECTID INT NULL,
        IncidentNumber VARCHAR(10) NULL,
        IncidentType INT NULL,
        IncidentTypeDescription VARCHAR(500) NULL,
        ArrivalDateTime DATETIME2(3) NULL,
        ClearedDateTime DATETIME2(3) NULL,
        DispatchDateTime DATETIME2(3) NULL,
        Exposure TINYINT NULL,
        Platoon CHAR(1) NULL,
        Station TINYINT NULL,
        Address VARCHAR(500) NULL,
        Address2 VARCHAR(500) NULL,
        AptOrRoom VARCHAR(50) NULL,
        --NOTE:  uniqueidentifier is not supported for external tables.
        GlobalID VARCHAR(36) NULL,
        CreationDate DATETIME2(3) NULL,
        Creator VARCHAR(120) NULL,
        EditDate DATETIME2(3) NULL,
        Editor VARCHAR(120) NULL
    )
    WITH
    (
        LOCATION = N'/PolyBaseData/Fire_Incidents.tsv',
        DATA_SOURCE = Clusterino,
        FILE_FORMAT = TsvFileFormat,
        REJECT_TYPE = VALUE,
        REJECT_VALUE = 5000
    );
END
GO
--177,733 out of 177,739.  5 rows plus the header are rejected.
SELECT COUNT(1)
FROM dbo.FireIncidents;

--Quick check to ensure results come back.
SELECT TOP(100)
	fi.X,
	fi.Y,
	fi.OBJECTID,
	fi.IncidentNumber,
	fi.IncidentType,
	fi.IncidentTypeDescription,
	fi.ArrivalDateTime,
	fi.ClearedDateTime,
	fi.DispatchDateTime,
	fi.Exposure,
	fi.Platoon,
	fi.Station,
	fi.Address,
	fi.Address2,
	fi.AptOrRoom,
	fi.GlobalID,
	fi.CreationDate,
	fi.Creator,
	fi.EditDate,
	fi.Editor
FROM dbo.FireIncidents fi;

--Find the most active fire stations and platoons for a given year.
SELECT
	fi.Station,
	fi.Platoon,
	YEAR(fi.DispatchDateTime) AS [Year],
	COUNT(1) AS NumberOfIncidents
FROM dbo.FireIncidents fi
GROUP BY
	fi.Station,
	fi.Platoon,
	YEAR(fi.DispatchDateTime)
ORDER BY
	NumberOfIncidents DESC;