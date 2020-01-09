-- Run this on the server with your external table, NOT on
-- the remote server.
USE [PolyBaseRevealed]
GO
IF NOT EXISTS
(
	SELECT *
	FROM sys.stats s
	WHERE
		s.name = N'sParkingViolationsSQLControl_VehicleYear_RegistrationState'
)
BEGIN
	CREATE STATISTICS [sParkingViolationsSQLControl_VehicleYear_RegistrationState] ON dbo.ParkingViolationsSQLControl
	(
		VehicleYear,
		RegistrationState,
		VehicleBodyType,
		VehicleMake
	) WITH FULLSCAN;
END
GO