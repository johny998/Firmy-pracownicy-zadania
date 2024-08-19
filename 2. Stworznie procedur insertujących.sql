
-- tworzenie bazy danych w objectExplorer

use TEST


GO
CREATE or ALTER PROC DodajPriority
as 
BEGIN
 
	INSERT INTO PRIORITY_TABLE(Prio_name,Prio_ID) VALUES ('NIE WYZNACZONY',0 )
	INSERT INTO PRIORITY_TABLE(Prio_name,Prio_ID) VALUES ( 'NISKI',1 )
	INSERT INTO PRIORITY_TABLE(Prio_name,Prio_ID) VALUES('ŒREDNI',2 )
	INSERT INTO PRIORITY_TABLE(Prio_name,Prio_ID) VALUES('WYSOKI',3 )

	

END


GO
CREATE or ALTER PROC DodajStatus
as 
BEGIN
	INSERT INTO Status_TABLE(Status_name,Status_ID) VALUES('NIEPRZYPISANE',0 ) 
	INSERT INTO Status_TABLE(Status_name,Status_ID) VALUES('NOWE',1  ) 
	INSERT INTO Status_TABLE(Status_name,Status_ID) VALUES('W TOKU',2  ) 
	INSERT INTO Status_TABLE(Status_name,Status_ID) VALUES('ZREALIZOWANE',3 )
	
END


GO
CREATE or ALTER PROC DodajDepartment
as 
BEGIN
	INSERT INTO DEPARTMENT(Name_DEPARTMENT)
	SELECT 'IT' UNION SELECT 'HR' UNION SELECT 'SALES' UNION SELECT 'CUSTOMER SUPPORT' UNION SELECT 'MARKETING' UNION SELECT 'FINANCE'
	
END



GO
CREATE or ALTER PROC DodajFirmy
as 
BEGIN

DECLARE 
	 @custnmbr varchar(10) 
	,@name varchar(100)

while ((SELECT COUNT(*) FROM CUSTOMER c(NOLOCK)) <10 )  
	BEGIN
		WITH n as (
		SELECT 'Rower'as 'nazwa'
		UNION SELECT 'Krzes³o'
		UNION SELECT 'Mapa'
		UNION SELECT 'Samochód'
		UNION SELECT 'Szafa'
		),
		f as 
		(
		SELECT 'sp. z o.o.' as 'forma'
		UNION SELECT 'SK'
		UNION SELECT 'JD'
		UNION SELECT 'SC'
		)
		SELECT TOP 1 @name= n.nazwa+' '+f.forma 
		FROM n CROSS JOIN f order by newid()

		SELECT @CUSTNMBR=CONVERT(varchar(10),cast(ROUND(RAND()*1000000000,0) as int))

		IF NOT EXISTS( SELECT 1 FROM CUSTOMER c(NOLOCK) WHERE c.CUSTNMBR = @custnmbr OR c.[NAME] = @name )
		BEGIN	
			INSERT INTO CUSTOMER(CUSTNMBR,[NAME])
			SELECT @custnmbr,@name
		END

	END

END



GO
CREATE or ALTER PROC dodajU¿ytkowników
AS
BEGIN
--====================

IF OBJECT_ID('tempdb..#i') is not null 
drop table #i

CREATE TABLE #i (imie VARCHAR(50))

INSERT INTO #i (imie)
SELECT 'Dariusz' as 'imie' UNION SELECT 'Mariusz'  UNION SELECT 'Pawe³' UNION SELECT 'Ilona' UNION SELECT 'Ewa' UNION SELECT 'Nina' UNION SELECT 'Piotr' UNION SELECT 'Natalia' UNION SELECT 'Anna' 
UNION SELECT 'Tomasz' UNION SELECT 'Katarzyna' UNION SELECT 'Rafa³' UNION SELECT 'Krzystof' UNION SELECT 'Jacek' UNION SELECT 'Magdalena' UNION SELECT 'Agata' UNION SELECT 'Joanna' UNION SELECT 'Adam'
UNION SELECT 'Aneta'UNION SELECT 'Marta'UNION SELECT 'Zofia' UNION  SELECT 'El¿bieta' UNION SELECT 'Wojciech' UNION SELECT 'Mateusz' UNION SELECT 'Klaudia'UNION SELECT 'S³awomir' UNION SELECT 'Grzegorz' UNION
SELECT 'Andrzej' UNION SELECT 'Barbara' UNION SELECT 'Cezary' UNION SELECT 'Dorota' UNION SELECT 'Janusz'

IF OBJECT_ID('tempdb..#n') is not null 
drop table #n

CREATE TABLE #n (nazwisko VARCHAR(50))

INSERT INTO #n (nazwisko)
  SELECT 'Makota' as 'nazwisko' UNION SELECT 'Krawczyk' UNION SELECT 'G³owacki' UNION SELECT 'Dudek' UNION SELECT 'WoŸniak' UNION SELECT 'Adamczyk' UNION SELECT 'Pietrzak' UNION SELECT 'Kaczmarczyk'
  UNION SELECT 'Manazwisko' UNION SELECT 'Nowak' UNION SELECT 'Lis' UNION SELECT 'Baran' UNION SELECT 'Mazur' UNION SELECT 'Mapsa' UNION SELECT 'Strzelczyk'  UNION SELECT 'Kot' UNION SELECT 'Pies'
  UNION SELECT 'Sowa'


	  DECLARE @name varchar(50)
		,@ln varchar(50)
		,@f_login varchar(30)
		,@department int
		,@CUSTNMBR varchar(10)
		,@dep_name varchar(3)
		,@maxAdLog int
		,@login varchar(30)
		,@i int
		,@totEmploye int
		,@totDep int

DECLARE addUser CURSOR FOR
	SELECT c.CUSTNMBR FROM CUSTOMER c(NOLOCK)	
OPEN addUser

FETCH NEXT FROM addUser INTO @CUSTNMBR

WHILE @@FETCH_STATUS=0
BEGIN

	set @totDep = (SELECT COUNT(*) FROM DEPARTMENT(NOLOCK))
	set @i = 1

	WHILE @i <= @totDep
		BEGIN 
			SELECT TOP 1 @name = imie FROM #i order by newid()
			SELECT TOP 1 @ln = nazwisko FROM #n order by newid()
			SELECT TOP 1 @department = d.ID_DEPARTMENT FROM DEPARTMENT d (NOLOCK) where d.ID_DEPARTMENT = @i
				SELECT TOP 1 @dep_name=LEFT(Name_DEPARTMENT,3) FROM DEPARTMENT d(NOLOCK) where d.ID_DEPARTMENT=@department

			SET @f_Login = @CUSTNMBR +'.'+ LEFT(@dep_name, 3) + '.' + LEFT(@name, 3) + LEFT(@ln, 3)
			SET @login = @f_Login
			
			IF EXISTS (SELECT top 1 1 FROM Employee e(NOLOCK) where e.Login=@login)
				BEGIN
					SELECT @maxAdLog = ISNULL(MAX(CAST(SUBSTRING(e.[Login], LEN(@f_login) + 1, LEN(e.[Login])) AS INT)), 1)
					FROM Employee e(NOLOCK)
					WHERE e.[Login] LIKE @login + '%'

					SET @login = @f_login+CONVERT(varchar(3),(@maxAdLog+1))
				END

			INSERT INTO Employee ([Name], Last_Name, [Login], Department, CUSTNMBR)
			SELECT @name, @ln, @login, @department, @CUSTNMBR
        
			set @i = @i+ 1

		END

	WHILE @i<=100
		BEGIN

			SELECT top 1 @name=i.imie FROM #i i(NOLOCK) order by newid()
			SELECT TOP 1 @ln=n.nazwisko FROM #n n(NOLOCK) order by newid()
			SELECT top 1 @department=d.ID_DEPARTMENT FROM DEPARTMENT d(NOLOCK) order by newid()
				SELECT TOP 1 @dep_name=LEFT(Name_DEPARTMENT,3) FROM DEPARTMENT d(NOLOCK) where d.ID_DEPARTMENT=@department

			SELECT @f_login = @CUSTNMBR+'.'+LEFT(@dep_name,3) + '.'+LEFT(@name,3)+LEFT(@ln,3)
			set @login=@f_login

			IF EXISTS (SELECT top 1 1 FROM Employee e(NOLOCK) where e.Login=@login)
				BEGIN
					SELECT @maxAdLog = ISNULL(MAX(CAST(SUBSTRING(e.[Login], LEN(@f_login) + 1, LEN(e.[Login])) AS INT)), 1)
					FROM Employee e(NOLOCK)
					WHERE e.[Login] LIKE @login + '%'

					SET @login = @f_login+CONVERT(varchar(3),(@maxAdLog+1))
				END

			INSERT INTO Employee(	Name	,Last_Name	,Login	,Department		,Custnmbr)
			SELECT					@name	,@ln		,@Login ,@department	,@CUSTNMBR

			set @i = @i+ 1 

		END
	FETCH NEXT FROM addUser INTO @CUSTNMBR
END
CLOSE addUser
DEALLOCATE addUser

-- ustawienie menago

--SELECT * 
update e set e.manager=1
FROM Employee e(NOLOCK)
where e.Employe_ID in 
(
SELECT 
	MIN(e.Employe_ID) as id

FROM Employee e(NOLOCK)
group by e.Custnmbr,e.Department
)

END





GO
CREATE or ALTER PROC DodajZadania
as
BEGIN

	INSERT INTO TASK_NEW([Owner],HeaderName	,[Desc]	,CR_DATE)
	SELECT 
			 e.Employe_ID
			 ,LEFT(REPLACE(n.randomString,'-',''),15)
			,REPLACE(n.randomString,'-','')
			,DATEADD(dd,- (ABS(CHECKSUM(n.randomString) % 100)),getdate())
		
	FROM Employee e(NOLOCK)
	CROSS JOIN (SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS 'number',REPLACE(newid(),'-','') as 'randomString'  FROM Employee e(NOLOCK)) as [n]
	where e.manager=0
	order by e.Employe_ID

END






