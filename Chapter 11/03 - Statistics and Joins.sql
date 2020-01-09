USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF (OBJECT_ID('dbo.RegistrationRegion') IS NULL)
BEGIN
	CREATE TABLE dbo.RegistrationRegion
	(
		RegistrationRegion VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED
	);

	INSERT INTO dbo.RegistrationRegion
	(
		RegistrationRegion
	)
	VALUES
		('Northeast'),
		('Mid-Atlantic'),
		('Midwest'),
		('Southwest');

	CREATE TABLE dbo.RegistrationState
	(
		RegistrationState VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED,
		RegistrationRegion VARCHAR(30) NOT NULL
	);

	ALTER TABLE dbo.RegistrationState ADD CONSTRAINT [FK_RegistrationStates_RegistrationRegions]
	FOREIGN KEY(RegistrationRegion)
	REFERENCES dbo.RegistrationRegion(RegistrationRegion);

	INSERT INTO dbo.RegistrationState
	(
		RegistrationState,
		RegistrationRegion
	)
	VALUES
		('OH', 'Midwest'),
		('IN', 'Midwest'),
		('WI', 'Midwest'),
		('PA', 'Mid-Atlantic'),
		('NJ', 'Mid-Atlantic'),
		('DE', 'Mid-Atlantic'),
		('CT', 'Northeast'),
		('MA', 'Northeast'),
		('RI', 'Northeast'),
		('NM', 'Southwest'),
		('AZ', 'Southwest'),
		('CO', 'Southwest'),
		('UT', 'Southwest');

	CREATE TABLE dbo.VehicleYear
	(
		VehicleYear VARCHAR(50) NOT NULL PRIMARY KEY CLUSTERED,
		VehicleYearDescription VARCHAR(30) NOT NULL
	);

	INSERT INTO dbo.VehicleYear
	(
		VehicleYear,
		VehicleYearDescription
	)
	VALUES
		('2004', 'Old'),
		('2005', 'Old'),
		('2006', 'Old'),
		('2007', 'Old'),
		('2008', 'Old'),
		('2015', 'New'),
		('2016', 'New'),
		('2017', 'New'),
		('2018', 'New'),
		('2019', 'New');
END
GO

-- Try a "complicated" query.
SELECT
	pv.RegistrationState,
	pv.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSQLControl pv
	INNER JOIN dbo.RegistrationState rs
		ON pv.RegistrationState = rs.RegistrationState
	INNER JOIN dbo.RegistrationRegion rr
		ON rs.RegistrationRegion = rr.RegistrationRegion
	INNER JOIN dbo.VehicleYear vy
		ON pv.VehicleYear = vy.VehicleYear
WHERE
	vy.VehicleYear IN ('2005', '2006', '2007')
	AND rr.RegistrationRegion = 'Midwest'
GROUP BY
	pv.RegistrationState,
	pv.VehicleMake;

-- Add the appropriate statistics
CREATE STATISTICS s_ParkingViolations_VY_RS_VM ON dbo.ParkingViolationsSQLControl
(
	VehicleYear,
	RegistrationState,
	VehicleMake
) WITH FULLSCAN;

-- Unfortunately, statistics don't help here.
-- The optimizer is not able to pass the implications of these predicates through.
-- Ideally, we would filter on the states which make up registration region and
-- pass the three states in our region in as part of external data retrieval.
SELECT
	pv.RegistrationState,
	pv.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSQLControl pv
	INNER JOIN dbo.RegistrationState rs
		ON pv.RegistrationState = rs.RegistrationState
	INNER JOIN dbo.RegistrationRegion rr
		ON rs.RegistrationRegion = rr.RegistrationRegion
	INNER JOIN dbo.VehicleYear vy
		ON pv.VehicleYear = vy.VehicleYear
WHERE
	vy.VehicleYear IN ('2005', '2006', '2007')
	AND rr.RegistrationRegion = 'Midwest'
GROUP BY
	pv.RegistrationState,
	pv.VehicleMake;
GO

-- Even forcing a particular order won't change this.
SELECT
	pv.RegistrationState,
	pv.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.RegistrationRegion rr
	INNER JOIN dbo.RegistrationState rs
		ON rs.RegistrationRegion = rr.RegistrationRegion
	INNER JOIN dbo.ParkingViolationsSQLControl pv
		ON pv.RegistrationState = rs.RegistrationState
	INNER JOIN dbo.VehicleYear vy
		ON pv.VehicleYear = vy.VehicleYear
WHERE
	vy.VehicleYear IN ('2005', '2006', '2007')
	AND rr.RegistrationRegion = 'Midwest'
GROUP BY
	pv.RegistrationState,
	pv.VehicleMake
OPTION(FORCE ORDER);
GO

-- Specifying states will help...if you can.
SELECT
	pv.RegistrationState,
	pv.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSQLControl pv
	INNER JOIN dbo.RegistrationState rs
		ON pv.RegistrationState = rs.RegistrationState
	INNER JOIN dbo.RegistrationRegion rr
		ON rs.RegistrationRegion = rr.RegistrationRegion
	INNER JOIN dbo.VehicleYear vy
		ON pv.VehicleYear = vy.VehicleYear
WHERE
	vy.VehicleYear IN ('2005', '2006', '2007')
	AND pv.RegistrationState IN ('OH', 'WI', 'IN')
GROUP BY
	pv.RegistrationState,
	pv.VehicleMake;
GO

-- Another option is to use dynamic SQL.
DECLARE
	@StatesList NVARCHAR(50) = N'',
	@sql NVARCHAR(MAX);

SELECT
	@StatesList = STRING_AGG(CONCAT('''', rs.RegistrationState, ''''), ',')
FROM dbo.RegistrationState rs
WHERE
	rs.RegistrationRegion = 'Midwest';

SET @sql = N'SELECT
	pv.RegistrationState,
	pv.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSQLControl pv
	INNER JOIN dbo.RegistrationState rs
		ON pv.RegistrationState = rs.RegistrationState
	INNER JOIN dbo.RegistrationRegion rr
		ON rs.RegistrationRegion = rr.RegistrationRegion
	INNER JOIN dbo.VehicleYear vy
		ON pv.VehicleYear = vy.VehicleYear
WHERE
	vy.VehicleYear IN (''2005'', ''2006'', ''2007'')
	AND pv.RegistrationState IN (' + @StatesList + ')
GROUP BY
	pv.RegistrationState,
	pv.VehicleMake;'

EXEC(@sql);