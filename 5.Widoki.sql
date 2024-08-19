use TEST

--======= WIDOKI

-- najpierw skrypt tworz¹cy procedure, potem EXECUTE 


--======= PODGL¥D MENADZERA NA ZADANIA PRACOWNIKÓW JEGO DZIA£U


go
CREATE or ALTER PROC ShowManagerView 
@userid int = null
,@month int = null
as 
BEGIN
DECLARE @err_msg varchar(255) = 'brak parametru '
	if isnull(@userid,'')=''
	--ustalanie losowego menadzera 
		SELECT top 1 @userid = Employe_ID FROM Employee e(NOLOCK) where e.manager=1 order by newid()

	--if isnull(@userid,'')=''
	--	BEGIN
	--		set @err_msg = @err_msg + 'ID u¿ytkownika';
	--		THROW 50000,@err_msg,1
	--	END


	if isnull(@month,'')=''
		BEGIN
			IF OBJECT_ID('tempdb..#months') is not null 
			drop table #months
			
			CREATE TABLE #months(nb int,nameMonth varchar(20))
			
			INSERT INTO #months(nb,nameMonth)
			SELECT 5 ,'Maj' 
			UNION 
			SELECT 6 ,'Czerwiec'
			UNION 
			SELECT 7 ,'Lipiec'
			UNION 
			SELECT 8,'Sierpieñ'
			UNION
			SELECT 9,'Wrzesieñ'
				
			SELECT top 1 @month= nb FROM #months order by newid()
		END


	SELECT 'Menadzera' as 'Dane dla'

	SELECT e.Employe_ID,e.[Name],e.[Last_Name],e.[Login],d.Name_DEPARTMENT,c.[NAME] as 'Customer Name'
	FROM Employee e (NOLOCk)
	JOIN Department d(NOLOCK) on e.Department=d.ID_Department
	JOIN CUSTOMER c(NOLOCK) on c.CUSTNMBR=e.CUSTNMBR
	where e.Employe_ID=@userid

	SELECT  'dzia³u menadzera' as 'Pracownicy'

-- SELECT KOÑCOWY
	SELECT
		 ee.Employe_ID
		 ,ee.[Name]
		,ee.[Last_Name]
		,t0.countTask as 'Zadania ogó³em'
		,t.countTask as 'Wszystkie zadania w miesi¹cu'
		,t1.countTask as 'Zadania nieprzypisane'
		,t2.countTask as 'Zadania nowe'
		,t3.countTask as 'Zadania w toku'
		,t4.countTask as 'Zadania zrealizowane'
		,m.nameMonth as 'miesi¹c'
	
	FROM Employee e(NOLOCK) 
	JOIN Employee ee(NOLOCK) on e.Department=ee.Department and e.CUSTNMBR=ee.CUSTNMBR and e.Employe_ID<>ee.Employe_ID
	JOIN #months m on m.nb=@month
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK)  group by [Owner]) as t0 on t0.[Owner]=ee.Employe_ID
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK) where MONTH(t.CR_DATE)=@month group by [Owner]) as t on t.[Owner]=ee.Employe_ID
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK) where MONTH(t.CR_DATE)=@month and t.[Priority]=0 group by [Owner]) as t1 on t1.[Owner]=ee.Employe_ID
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK) where MONTH(t.CR_DATE)=@month and t.[Priority]=1 group by [Owner]) as t2 on t2.[Owner]=ee.Employe_ID
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK) where MONTH(t.CR_DATE)=@month and t.[Priority]=2 group by [Owner]) as t3 on t3.[Owner]=ee.Employe_ID
	LEFT JOIN (SELECT [Owner],COUNT(TASK_ID) as 'countTask' FROM  TASK_NEW t(NOLOCK) where MONTH(t.CR_DATE)=@month and t.[Priority]=3 group by [Owner]) as t4 on t4.[Owner]=ee.Employe_ID
	
	where e.Employe_ID=@userid  

END


--=========== wywo³anie
GO
EXEC ShowManagerView




--============================ WIDOK PRACOWNIKA

GO 
CREATE or ALTER PROC ShowEmployeView
@userID int = null
AS
BEGIN
	if isnull(@userID,'')=''
--ustalanie losowego pracownika 
		SELECT top 1 @userID = Employe_ID FROM Employee e(NOLOCK) where e.manager=0 order by newid()


	SELECT 'PRACOWNIKA' as 'Dane dla '	
		SELECT e.Employe_ID,e.[Name],e.[Last_Name],e.[Login],d.Name_DEPARTMENT,c.[NAME] as 'Customer Name'
		FROM Employee e (NOLOCk)
		JOIN Department d(NOLOCK) on e.Department=d.ID_Department
		JOIN CUSTOMER c(NOLOCK) on c.CUSTNMBR=e.CUSTNMBR
		where e.Employe_ID=@userID

SELECT 'zadania' as 'POKA¯'
	SELECT '*' as 'Twoje zadanie',e.[Name],e.[Last_Name],t.*
	
	FROM Employee e(NOLOCK) 
	JOIN Task_NEW t(NOLOCk) on e.Employe_ID=t.[Owner]
	where e.Employe_ID=@userID
		UNION
	SELECT '' as 'Twoje zadanie',ee.[Name],ee.[Last_Name],t.*
	
	FROM Employee e(NOLOCK) 
	JOIN Employee ee(NOLOCK) on e.Department=ee.Department and e.CUSTNMBR=ee.CUSTNMBR and e.Employe_ID<>ee.Employe_ID and ee.manager=0
	JOIN Task_NEW t(NOLOCk) on ee.Employe_ID=t.[Owner]
	where e.Employe_ID=@userID
		order by [Twoje zadanie] desc
END


--=========== wywo³anie PRACOWNIK
GO
EXEC ShowEmployeView
