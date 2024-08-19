--==================== LOSOWE UPDATY
use TEST

UPDATE t set [Priority]=1
FROM TASK_NEW t (NOLOCk)

where t.TASK_ID in 
(
	SELECT top 20000 TASK_ID
	FROM TASK_NEW t(NOLOCK)
	order by newid()
)

UPDATE t set [Priority]=2
FROM TASK_NEW t (NOLOCk)
where t.TASK_ID in 
(
	SELECT top 20000 TASK_ID
	FROM TASK_NEW t(NOLOCK) 
	where t.Priority not in (1)
	order by newid() 
)

UPDATE t set [Priority]=3
FROM TASK_NEW t (NOLOCk)
where t.TASK_ID in 
(
	SELECT top 20000 TASK_ID
	FROM TASK_NEW t(NOLOCK) 
	where t.Priority not in (1,2)
	order by newid() 
)


SELECT DISTINCT [Priority] FROM TASK_NEW t(NOLOCK)


--=== STATUS

UPDATE t set [Status]=1
FROM task_NEW t (NOLOCk)
where t.TASK_ID in 
(
	SELECT top 50000 TASK_ID
	FROM TASK_NEW t(NOLOCK)
	order by newid()
)

UPDATE t set [Status]=2
FROM task_NEW t (NOLOCk)
where t.TASK_ID in 
(
	SELECT top 30000 TASK_ID
	FROM TASK_NEW t(NOLOCK)
	where t.status=1
	order by newid()
)

UPDATE t set [Status]=3
FROM task_NEW t (NOLOCk)
where t.TASK_ID in 
(
	SELECT top 10000 TASK_ID
	FROM TASK_NEW t(NOLOCK)
	where t.status=2
	order by newid()
)


SELECT DISTINCT [STATUS] FROM TASK_NEW t(NOLOCK)



--===================== SELECT tabel 
/*

SELECT top 1000 * FROM TASK_NEW t(NOLOCK) order by t.LastUpdate_DATE desc

SELECT TOP 1000 * FROM TASK_LOG l(NOLOCk) order by dex_row_Id desc

*/
