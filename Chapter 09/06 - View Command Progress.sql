SELECT
	r.command,
	s.request_id,
	r.status,
	count(distinct input_name) as nbr_files,
	sum(s.bytes_processed)/1024/1024/1024.0 as gb_processed
FROM 
	sys.dm_pdw_exec_requests r
	INNER JOIN sys.dm_pdw_dms_external_work s
	ON r.request_id = s.request_id
WHERE
	r.[label] IN
	(
		'CTAS : Load [dbo].[Date]',
		'CTAS : Load [dbo].[Geography]',
		'CTAS : Load [dbo].[HackneyLicense]',
		'CTAS : Load [dbo].[Medallion]',
		'CTAS : Load [dbo].[Time]',
		'CTAS : Load [dbo].[Weather]',
		'CTAS : Load [dbo].[Trip]'
	)
GROUP BY
	r.command,
	s.request_id,
	r.status
ORDER BY
	nbr_files desc,
	gb_processed desc;
GO