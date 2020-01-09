-- This is an example of creating linked server which connects
-- to a SQL Server instance.  Change the name SQLCONTROL to your instance
-- name.  You will also need to change (or create) the PolyBaseUser login
-- and fill in a password.

USE [master]
GO
EXEC master.dbo.sp_addlinkedserver @server = N'SQLCONTROL', @srvproduct=N'SQL Server'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SQLCONTROL',@useself=N'False',@locallogin=NULL,@rmtuser=N'PolyBaseUser',@rmtpassword='########'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'rpc', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'rpc out', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'SQLCONTROL', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
