USE [PolyBaseRevealed]
GO
SELECT
	mc.CustomerID,
	SUM(mc.MolesWhacked) AS MolesWhacked,
	SUM(mc.NumberOfSecondsInRun) AS NumberOfSecondsInRun,
	COUNT(1) AS NumberOfAttempts
FROM dbo.MoleCrusherSqlWin10 mc
WHERE
	mc.RunStart > '2019-01-01'
GROUP BY
	mc.CustomerID
HAVING
	COUNT(1) > 260
ORDER BY
	MolesWhacked DESC;
GO
