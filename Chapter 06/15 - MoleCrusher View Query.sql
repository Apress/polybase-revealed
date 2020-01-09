-- Run on the instance with the vMoleCrusherSqlWin10 external table,
-- not the instance with the base MoleCrusher table.
USE [PolyBaseRevealed]
GO
SELECT
	mc.CustomerID,
	SUM(mc.MolesWhacked) AS MolesWhacked,
	SUM(mc.NumberOfSecondsInRun) AS NumberOfSecondsInRun,
	COUNT(1) AS NumberOfAttempts
FROM dbo.vMoleCrusherSqlWin10 mc
WHERE
	mc.RunStart > '2019-01-01'
GROUP BY
	mc.CustomerID
HAVING
	COUNT(1) > 260
ORDER BY
	MolesWhacked DESC;