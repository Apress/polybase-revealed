USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

CREATE EXTERNAL TABLE ParkingViolationsSpark
(
    SummonsNumber NVARCHAR(255),
    PlateID NVARCHAR(255),
    RegistrationState NVARCHAR(255),
    PlateType NVARCHAR(255),
    IssueDate NVARCHAR(255),
    ViolationCode NVARCHAR(255),
    VehicleBodyType NVARCHAR(255),
    VehicleMake NVARCHAR(255),
    IssuingAgency NVARCHAR(255),
    StreetCode1 NVARCHAR(255),
    StreetCode2 NVARCHAR(255),
    StreetCode3 NVARCHAR(255),
    VehicleExpirationDate NVARCHAR(255),
    ViolationLocation NVARCHAR(255),
    ViolationPrecinct NVARCHAR(255),
    IssuerPrecinct NVARCHAR(255),
    IssuerCode NVARCHAR(255),
    IssuerCommand NVARCHAR(255),
    IssuerSquad NVARCHAR(255),
    ViolationTime NVARCHAR(255),
    TimeFirstObserved NVARCHAR(255),
    ViolationCounty NVARCHAR(255),
    ViolationInFrontOfOrOpposite NVARCHAR(255),
    HouseNumber NVARCHAR(255),
    StreetName NVARCHAR(255),
    IntersectingStreet NVARCHAR(255),
    DateFirstObserved NVARCHAR(255),
    LawSection NVARCHAR(255),
    SubDivision NVARCHAR(255),
    ViolationLegalCode NVARCHAR(255),
    DaysParkingInEffect NVARCHAR(255),
    FromHoursInEffect NVARCHAR(255),
    ToHoursInEffect NVARCHAR(255),
    VehicleColor NVARCHAR(255),
    UnregisteredVehicle NVARCHAR(255),
    VehicleYear NVARCHAR(255),
    MeterNumber NVARCHAR(255),
    FeetFromCurb NVARCHAR(255),
    ViolationPostCode NVARCHAR(255),
    ViolationDescription NVARCHAR(255),
    NoStandingorStoppingViolation NVARCHAR(255),
    HydrantViolation NVARCHAR(255),
    DoubleParkingViolation NVARCHAR(255)
)
WITH
(
    LOCATION = 'NYCParkingTickets',
    DATA_SOURCE = ClusterinoSpark,
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 5000
);
GO

-- 26 seconds against Hadoop + ORC.
-- 13 seconds in Hive directly.
-- 23 seconds against single-node Spark.
SELECT
	RegistrationState,
	COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolationsORC
GROUP BY
	RegistrationState
ORDER BY
	RegistrationState;