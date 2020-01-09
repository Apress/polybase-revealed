USE [PolyBaseRevealed]
GO
DROP TABLE IF EXISTS #RegistrationStates;

CREATE TABLE #RegistrationStates
(
    RegistrationState VARCHAR(30)
);
INSERT INTO #RegistrationStates(RegistrationState)
VALUES('NY'),('CT'),('NJ'),('PA');

SELECT
    p.VehicleBodyType,
    p.VehicleMake,
    p.VehicleYear,
    p.RegistrationState,
    COUNT(*)
FROM PolyBaseRevealed.dbo.ParkingViolationsSQLControl p
    INNER JOIN #RegistrationStates r
        ON p.RegistrationState = r.RegistrationState
WHERE
    p.VehicleYear IN ('2013', '2014', '2015', '2016', '2017')
GROUP BY
    p.VehicleBodyType,
    p.VehicleMake,
    p.VehicleYear,
    p.RegistrationState;

SELECT
    p.VehicleBodyType,
    p.VehicleMake,
    p.VehicleYear,
    p.RegistrationState,
    COUNT(*)
FROM SQLCONTROL.PolyBaseRevealed.dbo.ParkingViolationsLocal p
    INNER JOIN #RegistrationStates r
        ON p.RegistrationState = r.RegistrationState
WHERE
    p.VehicleYear IN ('2013', '2014', '2015', '2016', '2017')
GROUP BY
    p.VehicleBodyType,
    p.VehicleMake,
    p.VehicleYear,
    p.RegistrationState;
