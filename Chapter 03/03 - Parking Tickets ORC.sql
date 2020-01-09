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
/* Using ORC instead of CSV */
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_file_formats e
	WHERE  
		e.name = N'OrcFileFormat'
)
BEGIN
	CREATE EXTERNAL FILE FORMAT OrcFileFormat WITH
	(
		FORMAT_TYPE = ORC,
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.DefaultCodec'
	);
END
GO

CREATE EXTERNAL TABLE ParkingViolationsORC
(
    SummonsNumber VARCHAR(50),
    PlateID VARCHAR(120),
    RegistrationState VARCHAR(30),
    PlateType VARCHAR(50),
    IssueDate VARCHAR(50),
    ViolationCode VARCHAR(50),
    VehicleBodyType VARCHAR(50),
    VehicleMake VARCHAR(50),
    IssuingAgency VARCHAR(50),
    StreetCode1 VARCHAR(50),
    StreetCode2 VARCHAR(50),
    StreetCode3 VARCHAR(50),
    VehicleExpirationDate VARCHAR(50),
    ViolationLocation VARCHAR(50),
    ViolationPrecinct VARCHAR(50),
    IssuerPrecinct VARCHAR(50),
    IssuerCode VARCHAR(50),
    IssuerCommand VARCHAR(100),
    IssuerSquad VARCHAR(100),
    ViolationTime VARCHAR(100),
    TimeFirstObserved VARCHAR(100),
    ViolationCounty VARCHAR(100),
    ViolationInFrontOfOrOpposite VARCHAR(100),
    HouseNumber VARCHAR(50),
    StreetName VARCHAR(100),
    IntersectingStreet VARCHAR(100),
    DateFirstObserved VARCHAR(50),
    LawSection VARCHAR(30),
    SubDivision VARCHAR(50),
    ViolationLegalCode VARCHAR(100),
    DaysParkingInEffect VARCHAR(50),
    FromHoursInEffect VARCHAR(50),
    ToHoursInEffect VARCHAR(50),
    VehicleColor VARCHAR(50),
    UnregisteredVehicle VARCHAR(50),
    VehicleYear VARCHAR(50),
    MeterNumber VARCHAR(50),
    FeetFromCurb VARCHAR(50),
    ViolationPostCode VARCHAR(30),
    ViolationDescription VARCHAR(150),
    NoStandingorStoppingViolation VARCHAR(50),
    HydrantViolation VARCHAR(50),
    DoubleParkingViolation VARCHAR(50)
)
WITH
(
    LOCATION = N'/PolyBaseData/NYCParkingTicketsORC/',
    DATA_SOURCE = Clusterino,
    FILE_FORMAT = OrcFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 5000
);
GO

--12 seconds
SELECT COUNT(1) FROM dbo.ParkingViolationsORC;

--26 seconds
SELECT
	RegistrationState,
	COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolationsORC
GROUP BY
	RegistrationState
ORDER BY
	RegistrationState;
--13 seconds when running in Hive