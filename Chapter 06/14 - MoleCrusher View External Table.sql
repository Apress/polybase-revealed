USE [PolyBaseRevealed]
GO
IF (OBJECT_ID('dbo.vMoleCrusherSqlWin10') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE [dbo].[vMoleCrusherSqlWin10]
	(
		[RunID] [int] NOT NULL,
		[CustomerID] [int] NOT NULL,
		[RunStart] [datetime2](0) NOT NULL,
		[NumberOfSecondsInRun] [decimal](6, 2) NOT NULL,
		[NumberOfSecondsBeforeNextRunBegins] [decimal](6, 2) NOT NULL,
		[MolesWhacked] [int] NOT NULL
	)
	WITH
	(
		LOCATION = 'PolyBaseRevealed.dbo.vMoleCrusher',
		DATA_SOURCE = SQLWIN10
	);
END
GO