-- Run this on the same server as the MoleCrusher table.
USE PolyBaseRevealed
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.views v
	WHERE
		v.name = N'vMoleCrusher'
)
BEGIN
	CREATE VIEW dbo.vMoleCrusher AS
	SELECT * FROM dbo.MoleCrusher;
END
GO
