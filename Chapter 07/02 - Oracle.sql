USE [PolyBaseRevealed]
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_scoped_credentials dsc
    WHERE
        dsc.name = N'OracleCredential'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL OracleCredential
    WITH IDENTITY = '<Your User>', Secret = '<Your PWD>';
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'Oracle'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE Oracle WITH
    (
        LOCATION = 'oracle://SQLWIN10:1521',
        CREDENTIAL = OracleCredential,
        PUSHDOWN = ON
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'Employees'
)
BEGIN
    CREATE EXTERNAL TABLE Employees
    (
        EMPLOYEE_ID DECIMAL(38),
        FIRST_NAME VARCHAR(100),
        LAST_NAME VARCHAR(100),
        EMAIL VARCHAR(255),
        PHONE_NUMBER VARCHAR(20),
        HIRE_DATE DATE,
        JOB_ID VARCHAR(10),
        SALARY DECIMAL(38,16),
        COMMISSION_PCT DECIMAL(2,2),
        MANAGER_ID DECIMAL(38)
    )
    WITH
    (
        LOCATION = '[XE].[HR].[EMPLOYEES]',
        DATA_SOURCE = Oracle
    );
END
GO

-- A basic SELECT * to ensure that everything returns as expected.
SELECT * FROM dbo.Employees;
