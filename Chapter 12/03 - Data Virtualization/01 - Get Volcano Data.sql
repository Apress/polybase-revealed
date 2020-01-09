USE [PolyBaseRevealed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

CREATE OR ALTER PROCEDURE dbo.Volcano_GetVolcanoData
AS
BEGIN
	SELECT *
	INTO #Volcanoes
	FROM dbo.Volcano;

	SELECT
		_id,
		v.VolcanoName,
		v.Country,
		v.Region,
		v.Location_Type AS LocationType,
		STRING_AGG(v.Volcano_Coordinates, ',') AS Coordinates,
		v.Elevation,
		v.Type,
		v.Status,
		v.LastEruption
	FROM #Volcanoes v
	GROUP BY
		_id,
		v.VolcanoName,
		v.Country,
		v.Region,
		v.Location_Type,
		v.Elevation,
		v.Type,
		v.Status,
		v.LastEruption
	ORDER BY
		v.Elevation ASC;
END
GO
