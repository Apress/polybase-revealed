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

--You can query off of a single file if you want.
CREATE EXTERNAL TABLE ParkingViolations2016
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
    LOCATION = N'/  PolyBaseData/NYCParkingTickets/Parking_Violations_Issued_-_Fiscal_Year_2016.csv',
    DATA_SOURCE = Clusterino,
    FILE_FORMAT = CsvFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 5000
);

--10,626,900, including the header row.
--150 seconds on a test setup with standalone PolyBase and a single Hadoop data node.
SELECT COUNT(1) FROM dbo.ParkingViolations2016;

--156 seconds on the standalone test setup, and mostly sane data.
SELECT
	RegistrationState,
	COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolations2016
GROUP BY
	RegistrationState
ORDER BY
	RegistrationState;

--Or you can query off of an entire folder.
CREATE EXTERNAL TABLE ParkingViolations
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
    LOCATION = N'/PolyBaseData/NYCParkingTickets/',
    DATA_SOURCE = Clusterino,
    FILE_FORMAT = CsvFileFormat,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 5000
);

--33,239,160 rows.
--8 minutes, 18 seconds on a test setup with standalone PolyBase and a single Hadoop data node.
SELECT COUNT(1) FROM dbo.ParkingViolations;

--8 minutes, 32 seconds on a test setup with standalone PolyBase and a single Hadoop data node.
SELECT
	RegistrationState,
	COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolations
GROUP BY
	RegistrationState
ORDER BY
	RegistrationState;