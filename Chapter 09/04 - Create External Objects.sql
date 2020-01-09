-- This is a public blob, so we do not need to authenticate.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources eds
	WHERE
		eds.name = N'NYTPublic'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE NYTPublic
	WITH
	(
		TYPE = Hadoop,
		LOCATION = 'wasbs://2013@nytaxiblob.blob.core.windows.net/'
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_file_formats eff
	WHERE
		name = N'CSV'
)
BEGIN
	CREATE EXTERNAL FILE FORMAT CSV WITH
	(
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS
		(
			FIELD_TERMINATOR = ',',
			STRING_DELIMITER = '',
			DATE_FORMAT = '',
			USE_TYPE_DEFAULT = FALSE
		)
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_file_formats eff
	WHERE
		name = N'PipeGzip'
)
BEGIN
	CREATE EXTERNAL FILE FORMAT PipeGzip WITH
	(
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS
		(
			FIELD_TERMINATOR = '|',
			STRING_DELIMITER = '',
			DATE_FORMAT = '',
			USE_TYPE_DEFAULT = FALSE
		),
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
	);
END
GO
-- Create a schema for external data.  This is for ETL
-- rather than data virtualization, so we want to segregate these out.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.schemas s
	WHERE
		s.name = N'ext'
)
BEGIN
	-- CREATE SCHEMA must be the first element in a batch.
	EXEC(N'CREATE SCHEMA ext;');
END
GO
-- Load each of the tables into the external schema.
-- The scripts are slightly modified from https://docs.microsoft.com/en-us/azure/sql-data-warehouse/load-data-from-azure-blob-storage-using-polybase.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Date'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Date] 
	(
		[DateID] int NOT NULL,
		[Date] datetime NULL,
		[DateBKey] char(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfMonth] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DaySuffix] varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayName] varchar(9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfWeek] char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfWeekInMonth] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfWeekInYear] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfQuarter] varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DayOfYear] varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WeekOfMonth] varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WeekOfQuarter] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WeekOfYear] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Month] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MonthName] varchar(9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MonthOfQuarter] varchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Quarter] char(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QuarterName] varchar(9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Year] char(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[YearName] char(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MonthYear] char(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MMYYYY] char(6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FirstDayOfMonth] date NULL,
		[LastDayOfMonth] date NULL,
		[FirstDayOfQuarter] date NULL,
		[LastDayOfQuarter] date NULL,
		[FirstDayOfYear] date NULL,
		[LastDayOfYear] date NULL,
		[IsHolidayUSA] bit NULL,
		[IsWeekday] bit NULL,
		[HolidayUSA] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	WITH
	(
		LOCATION = 'Date',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	); 
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Geography'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Geography]
	(
		[GeographyID] int NOT NULL,
		[ZipCodeBKey] varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[County] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[City] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[State] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Country] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ZipCode] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	WITH
	(
		LOCATION = 'Geography',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0 
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'HackneyLicense'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[HackneyLicense]
	(
		[HackneyLicenseID] int NOT NULL,
		[HackneyLicenseBKey] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[HackneyLicenseCode] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	WITH
	(
		LOCATION = 'HackneyLicense',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Medallion'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Medallion]
	(
		[MedallionID] int NOT NULL,
		[MedallionBKey] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MedallionCode] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	WITH
	(
		LOCATION = 'Medallion',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Time'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Time]
	(
		[TimeID] int NOT NULL,
		[TimeBKey] varchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[HourNumber] tinyint NOT NULL,
		[MinuteNumber] tinyint NOT NULL,
		[SecondNumber] tinyint NOT NULL,
		[TimeInSecond] int NOT NULL,
		[HourlyBucket] varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DayTimeBucketGroupKey] int NOT NULL,
		[DayTimeBucket] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	)
	WITH
	(
		LOCATION = 'Time',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Trip'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Trip]
	(
		[DateID] int NOT NULL,
		[MedallionID] int NOT NULL,
		[HackneyLicenseID] int NOT NULL,
		[PickupTimeID] int NOT NULL,
		[DropoffTimeID] int NOT NULL,
		[PickupGeographyID] int NULL,
		[DropoffGeographyID] int NULL,
		[PickupLatitude] float NULL,
		[PickupLongitude] float NULL,
		[PickupLatLong] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DropoffLatitude] float NULL,
		[DropoffLongitude] float NULL,
		[DropoffLatLong] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PassengerCount] int NULL,
		[TripDurationSeconds] int NULL,
		[TripDistanceMiles] float NULL,
		[PaymentType] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FareAmount] money NULL,
		[SurchargeAmount] money NULL,
		[TaxAmount] money NULL,
		[TipAmount] money NULL,
		[TollsAmount] money NULL,
		[TotalAmount] money NULL
	)
	WITH
	(
		LOCATION = 'Trip2013',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = PipeGzip,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	);
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_tables t
	WHERE
		t.name = N'Weather'
)
BEGIN
	CREATE EXTERNAL TABLE [ext].[Weather]
	(
		[DateID] int NOT NULL,
		[GeographyID] int NOT NULL,
		[PrecipitationInches] float NOT NULL,
		[AvgTemperatureFahrenheit] float NOT NULL
	)
	WITH
	(
		LOCATION = 'Weather',
		DATA_SOURCE = NYTPublic,
		FILE_FORMAT = CSV,
		REJECT_TYPE = value,
		REJECT_VALUE = 0
	);
END
GO
