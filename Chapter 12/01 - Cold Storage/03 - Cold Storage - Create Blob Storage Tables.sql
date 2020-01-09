USE [PolyBaseRevealed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

DECLARE
	@year INT = 2008,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2018)
BEGIN
	SET @sql = CONCAT(N'DROP EXTERNAL TABLE dbo.FireIncidents', @year);
	EXEC(@sql);
	set @year = @year + 1
END
GO


-- Keep older data in external tables on blob storage.  We'll break out by year and include every year from 2017 back to 2008.
DECLARE
	@year INT = 2008,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2018)
BEGIN
	SET @TableName = CONCAT(N'FireIncidents', @year);
	IF (OBJECT_ID(@TableName) IS NULL)
	BEGIN
		SET @sql = REPLACE(N'
	CREATE EXTERNAL TABLE [dbo].[FireIncidents$YEAR]
	(
		[X] [float] NULL,
		[Y] [float] NULL,
		[OBJECTID] [int] NULL,
		[incident_number] [nvarchar](500) NULL,
		[incident_type] [smallint] NULL,
		[incident_type_description] [nvarchar](500) NULL,
		[arrive_date_time] [datetime2](7) NULL,
		[cleared_date_time] [datetime2](7) NULL,
		[dispatch_date_time] [datetime2](7) NULL,
		[exposure] [tinyint] NULL,
		[platoon] [nvarchar](50) NULL,
		[station] [tinyint] NULL,
		[address] [nvarchar](500) NULL,
		[address2] [nvarchar](500) NULL,
		[apt_room] [nvarchar](500) NULL,
		[GlobalID] [nvarchar](50) NULL,
		[CreationDate] [datetime2](7) NULL,
		[Creator] [nvarchar](50) NULL,
		[EditDate] [datetime2](7) NULL,
		[Editor] [nvarchar](50) NULL
	)
	WITH
	(
		LOCATION = N''FireIncidents$YEAR/'',
		DATA_SOURCE = AzureFireIncidentsBlob,
		FILE_FORMAT = OrcFileFormat,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 1
	);', N'$YEAR', CAST(@year AS NVARCHAR(4)));
		
		EXEC(@sql);
	END

	SET @year = @year + 1;
END
GO
