USE [PolyBaseRevealed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF (OBJECT_ID('dbo.MoleCrusher') IS NULL)
BEGIN
	CREATE TABLE [dbo].[MoleCrusher]
	(
		[RunID] [int] IDENTITY(1,1) NOT NULL,
		[CustomerID] [int] NOT NULL,
		[RunStart] [datetime2](0) NOT NULL,
		[NumberOfSecondsInRun] [decimal](6, 2) NOT NULL,
		[NumberOfSecondsBeforeNextRunBegins] [decimal](6, 2) NOT NULL,
		[MolesWhacked] [int] NOT NULL,
		CONSTRAINT [PK_MoleCrusher] PRIMARY KEY NONCLUSTERED 
		(
			[RunID] ASC
		)WITH (DATA_COMPRESSION = PAGE)
	);
	CREATE COLUMNSTORE INDEX [IX_MoleCrusher] ON dbo.MoleCrusher;
END
GO
-- This process adds 1 million arbitrary rows to the data set.
-- If you have sufficient disk space available, you can expand the number,
-- or you can run it multiple times to generate enough rows.
DECLARE
    @NumberOfRecords INT = 1000000,
    @NumberOfCustomers INT = 200000,
    @StartDate DATETIME2(0) = '2018-12-18 15:00:00',
	-- Can be up to 8 years from the start date.
	@NumberOfSeconds INT = 8 * 365.25 * 24 * 3600,
    @MaxRunLengthInSeconds DECIMAL(5,2) = 90.0,
    @MaxNumberOfSecondsBeforeNextRunBegins DECIMAL(6,2) = 1400.0,
	@MaxMolesWhacked INT = 90;
 
WITH
L0 AS(SELECT 1 AS c UNION ALL SELECT 1),
L1 AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
L2 AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
L3 AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
L4 AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
L5 AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS n FROM L5)
SELECT TOP (@NumberOfRecords)
    CAST(RAND(CHECKSUM(NEWID())) * @NumberOfCustomers AS INT) + 1 AS CustomerID,
	DATEADD(SECOND, CAST(RAND(CHECKSUM(NEWID())) * @NumberOfSeconds AS INT), @StartDate) AS RunStart,
	RAND(CHECKSUM(NEWID())) * @MaxRunLengthInSeconds AS NumberOfSecondsInRun,
	RAND(CHECKSUM(NEWID())) * @MaxNumberOfSecondsBeforeNextRunBegins AS NumberOfSecondsBeforeNextRunBegins,
	CAST(RAND(CHECKSUM(NEWID())) * @MaxMolesWhacked AS INT) AS MolesWhacked
FROM Nums;