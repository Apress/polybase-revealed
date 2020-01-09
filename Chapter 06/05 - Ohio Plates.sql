USE [PolyBaseRevealed]
GO
SELECT COUNT(*)
FROM dbo.ParkingViolationsSQLControl
WHERE
	RegistrationState = 'OH';

SELECT COUNT(*)
FROM SQLCONTROL.PolyBaseRevealed.dbo.ParkingViolationsLocal
WHERE
	RegistrationState = 'OH';