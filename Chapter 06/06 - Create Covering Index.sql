USE [PolyBaseRevealed]
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.indexes i
	WHERE
		i.name = N'IX_ParkingViolationsLocal_VehicleYear_RegistrationState'
)
BEGIN
	CREATE NONCLUSTERED INDEX [IX_ParkingViolationsLocal_VehicleYear_RegistrationState] ON [dbo].[ParkingViolationsLocal]
	(
		[VehicleYear] ASC,
		[RegistrationState] ASC
	)
	INCLUDE
	( 
		[VehicleBodyType],
		[VehicleMake]
	) WITH (DATA_COMPRESSION = PAGE);
END
GO
