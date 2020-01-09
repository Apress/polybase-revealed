-- This is an example of creating an external data source which connects
-- to a SQL Server instance.  Change the name SQLCONTROL to your instance
-- name.  You will also need to change (or create) the PolyBaseUser login
-- and fill in a password.

USE [PolyBaseRevealed]
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.database_scoped_credentials dsc
	WHERE
		dsc.name = N'SqlControlCredentials'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL SqlControlCredentials
	WITH IDENTITY = 'PolyBaseUser', Secret = '<<Some Password>>';
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources e
	WHERE
		e.name = N'SQLCONTROL'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE SQLCONTROL WITH
	(
		LOCATION = 'sqlserver://SQLCONTROL',
		PUSHDOWN = ON,
		CREDENTIAL = SqlControlCredentials
	);
END
GO
CREATE TABLE [dbo].[ParkingViolationsSQLControl]
(
	[SummonsNumber] [varchar](50) NULL,
	[PlateID] [varchar](120) NULL,
	[RegistrationState] [varchar](30) NULL,
	[PlateType] [varchar](50) NULL,
	[IssueDate] [varchar](50) NULL,
	[ViolationCode] [varchar](50) NULL,
	[VehicleBodyType] [varchar](50) NULL,
	[VehicleMake] [varchar](50) NULL,
	[IssuingAgency] [varchar](50) NULL,
	[StreetCode1] [varchar](50) NULL,
	[StreetCode2] [varchar](50) NULL,
	[StreetCode3] [varchar](50) NULL,
	[VehicleExpirationDate] [varchar](50) NULL,
	[ViolationLocation] [varchar](50) NULL,
	[ViolationPrecinct] [varchar](50) NULL,
	[IssuerPrecinct] [varchar](50) NULL,
	[IssuerCode] [varchar](50) NULL,
	[IssuerCommand] [varchar](100) NULL,
	[IssuerSquad] [varchar](100) NULL,
	[ViolationTime] [varchar](100) NULL,
	[TimeFirstObserved] [varchar](100) NULL,
	[ViolationCounty] [varchar](100) NULL,
	[ViolationInFrontOfOrOpposite] [varchar](100) NULL,
	[HouseNumber] [varchar](50) NULL,
	[StreetName] [varchar](100) NULL,
	[IntersectingStreet] [varchar](100) NULL,
	[DateFirstObserved] [varchar](50) NULL,
	[LawSection] [varchar](30) NULL,
	[SubDivision] [varchar](50) NULL,
	[ViolationLegalCode] [varchar](100) NULL,
	[DaysParkingInEffect] [varchar](50) NULL,
	[FromHoursInEffect] [varchar](50) NULL,
	[ToHoursInEffect] [varchar](50) NULL,
	[VehicleColor] [varchar](50) NULL,
	[UnregisteredVehicle] [varchar](50) NULL,
	[VehicleYear] [varchar](50) NULL,
	[MeterNumber] [varchar](50) NULL,
	[FeetFromCurb] [varchar](50) NULL,
	[ViolationPostCode] [varchar](30) NULL,
	[ViolationDescription] [varchar](150) NULL,
	[NoStandingorStoppingViolation] [varchar](50) NULL,
	[HydrantViolation] [varchar](50) NULL,
	[DoubleParkingViolation] [varchar](50) NULL
)
WITH
(
	LOCATION = 'PolyBaseRevealed.dbo.ParkingViolationsLocal',
	DATA_SOURCE = SQLCONTROL
);
GO
