USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- Start with a query
SELECT
	p.RegistrationState,
	p.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSpark p
WHERE
    p.VehicleYear = '2015'
GROUP BY
	p.RegistrationState,
	p.VehicleMake;

-- Look for the execution
SELECT
	e.*
FROM sys.dm_exec_distributed_requests e
ORDER BY
	e.start_time DESC;

-- Get details for that execution
SELECT
	s.step_index,
	s.operation_type,
	s.location_type,
	s.[row_count],
	s.command
FROM sys.dm_exec_distributed_request_steps s 
WHERE
	s.execution_id = 'QID1054';

-- Add the appropriate statistics
CREATE STATISTICS s_ParkingViolationsSpark_VehicleYear_RegistrationState_VehicleMake ON dbo.ParkingViolationsSpark
(
	VehicleYear,
	RegistrationState,
	VehicleMake
) WITH FULLSCAN;

-- Now try the query again and see how stats change
SELECT
	p.RegistrationState,
	p.VehicleMake,
	COUNT(1) AS NumberOfRows
FROM dbo.ParkingViolationsSpark p
WHERE
    p.VehicleYear = '2015'
GROUP BY
	p.RegistrationState,
	p.VehicleMake;