-- This is an example of creating an external data source which connects
-- to a SQL Server instance.  Change the name SQLWIN10 to your instance
-- name.  You will also need to change (or create) the PolyBaseUser login
-- and fill in a password.

USE [PolyBaseRevealed]
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.database_scoped_credentials dsc
	WHERE
		dsc.name = N'SqlWin10Credentials'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL SqlWin10Credentials
	WITH IDENTITY = 'PolyBaseUser', Secret = '<<Some Password>>';
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources e
	WHERE
		e.name = N'SQLWIN10'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE SQLWIN10 WITH
	(
		LOCATION = 'sqlserver://SQLWIN10',
		PUSHDOWN = ON,
		CREDENTIAL = SqlWin10Credentials
	);
END
GO
