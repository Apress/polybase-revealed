USE [PolyBaseRevealed]
GO
DROP TABLE IF EXISTS #RegistrationStates;

CREATE TABLE #RegistrationStates
(
    RegistrationState VARCHAR(30)
);
INSERT INTO #RegistrationStates(RegistrationState)
VALUES('OH'),('KY');

SELECT
    p.VehicleBodyType,
    p.VehicleMake,
    COUNT(*)
FROM PolyBaseRevealed.dbo.ParkingViolationsSQLControl p
    INNER JOIN #RegistrationStates r
        ON p.RegistrationState = r.RegistrationState
WHERE
    p.VehicleYear IN ('2005', '2006', '2007', '2008')
GROUP BY
    p.VehicleBodyType,
    p.VehicleMake;

SELECT
    p.VehicleBodyType,
    p.VehicleMake,
    COUNT(*)
FROM SQLCONTROL.PolyBaseRevealed.dbo.ParkingViolationsLocal p
    INNER JOIN #RegistrationStates r
        ON p.RegistrationState = r.RegistrationState
WHERE
    p.VehicleYear IN ('2005', '2006', '2007', '2008')
GROUP BY
    p.VehicleBodyType,
    p.VehicleMake;