USE [PolyBaseRevealed]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<Your Password Here>';

-- Azure Blob Storage connection.
-- Review chapter 2 for the external data source, file format, and table details.
SELECT
    p.PopulationType,
    p.Year,
    SUM(p.Population) AS Population
FROM dbo.NorthCarolinaPopulation p
GROUP BY
    p.PopulationType,
    p.Year
ORDER BY
    p.Year DESC,
    p.PopulationType ASC;

-- MapReduce job with predicate pushdown.
SELECT
    pv.VehicleYear,
    COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolations pv
GROUP BY
    pv.VehicleYear
ORDER BY
    pv.VehicleYear DESC
OPTION (FORCE EXTERNALPUSHDOWN);

-- SQL Server connection.
SELECT
    pv.FeetFromCurb,
    COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolationsSQLControl pv
GROUP BY
    pv.FeetFromCurb
ORDER BY
    pv.FeetFromCurb DESC;

-- Cosmos DB connection.
SELECT * FROM dbo.Volcano;

-- Spark connection.
SELECT
    pv.FeetFromCurb,
    COUNT(*) AS NumberOfViolations
FROM dbo.ParkingViolationsSpark pv
GROUP BY
    pv.FeetFromCurb
ORDER BY
    pv.FeetFromCurb DESC;

-- For each query, follow the flow:
-- Query external work to get the execution ID.
SELECT
    wk.execution_id,
    wk.input_name,
    wk.read_command,
    wk.[status]
FROM sys.dm_exec_external_work wk
ORDER BY
    execution_id DESC;

-- Fill in the execution ID as needed.
DECLARE
    @execution_id SYSNAME = 'QID2466';

SELECT
    r.*
FROM sys.dm_exec_distributed_requests r
WHERE
    r.execution_id = @execution_id;

SELECT
    rs.execution_id,
    rs.step_index,
    rs.operation_type,
    rs.distribution_type,
    rs.location_type,
    --rs.[status],
    --rs.error_id,
    --rs.start_time,
    --rs.end_time,
    rs.total_elapsed_time,
    rs.row_count,
    rs.command
FROM sys.dm_exec_distributed_request_steps rs
WHERE
    rs.execution_id = @execution_id
ORDER BY
    step_index ASC;