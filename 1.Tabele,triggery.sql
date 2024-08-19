
IF NOT EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'TEST')
BEGIN
	CREATE DATABASE TEST
END
go
use TEST

--====== TABLE 

--================ CUSTOMER
IF OBJECT_ID('CUSTOMER') is not null 
drop table CUSTOMER

CREATE TABLE CUSTOMER
(
 CUSTNMBR varchar(10) PRIMARY KEY
,[NAME] varchar(100)
)

--================ DEPARTMENT 
IF OBJECT_ID('DEPARTMENT') is not null 
drop table DEPARTMENT

CREATE TABLE DEPARTMENT
(
 ID_DEPARTMENT int identity(1,1) PRIMARY KEY
,Name_DEPARTMENT varchar(50)
)



--================ Employee
IF OBJECT_ID('Employee') is not null 
drop table Employee

CREATE TABLE Employee
(
 Employe_ID int identity(1,1) PRIMARY KEY
,[Name] varchar(50)
,[Last_Name] varchar(50)
,[Login] varchar(30) unique
,Department int
,CUSTNMBR varchar(10)
,manager int default 0
,CONSTRAINT FK_E_Department FOREIGN KEY (Department) REFERENCES DEPARTMENT(ID_DEPARTMENT)
,CONSTRAINT FK_E_Customer FOREIGN KEY (CUSTNMBR) REFERENCES CUSTOMER(CUSTNMBR)
)
CREATE NONCLUSTERED INDEX idx_employee ON Employee(Employe_ID,CUSTNMBR,Department)

  


--=== PRIORITY
if object_ID('PRIORITY_TABLE') is not null
drop table PRIORITY_TABLE

CREATE TABLE PRIORITY_TABLE
(
 Prio_ID int PRIMARY KEY
,Prio_name varchar(30)
)

--=== Status
if object_ID('Status_TABLE') is not null
drop table Status_TABLE

CREATE TABLE Status_TABLE
(
 Status_ID int PRIMARY KEY
,Status_name varchar(30)
)


--================ TASK_NEW
IF object_ID('TASK_NEW') is not null
drop table TASK_NEW

CREATE TABLE TASK_NEW
(
 TASK_ID int identity(1,1) PRIMARY KEY
,CR_DATE datetime default getdate()
,LastUpdate_DATE datetime default getdate()
,[Owner] int default 0
,HeaderName varchar(50)
,[Desc] varchar(50)
,[Status] int default 0 
,[Priority] int default 0
,CONSTRAINT FK_T_Owner FOREIGN KEY ([Owner]) REFERENCES Employee(Employe_ID)
,CONSTRAINT FK_T_Status FOREIGN KEY ([Status]) REFERENCES Status_TABLE(Status_ID)
,CONSTRAINT FK_T_Priority FOREIGN KEY ([Priority]) REFERENCES PRIORITY_TABLE(Prio_ID)
)
CREATE NONCLUSTERED INDEX idx_owner ON TASK_NEW([Owner],CR_DATE desc)

--================ TASK_LOG
IF object_ID('TASK_LOG') is not null
drop table TASK_LOG
	CREATE TABLE TASK_LOG
(
 DEX_ROW_ID int identity(1,1)
,[CR_User] varchar(100)
,cr_date datetime default getdate()
,Task_ID int 
,[desc] varchar(100)
,[column] varchar(50)
,VAL_OLD varchar(100)
,VAL_NEW varchar(100)
,CONSTRAINT FK_TLog_Task FOREIGN KEY (Task_ID) REFERENCES TASK_NEW(TASK_ID)
)
CREATE NONCLUSTERED INDEX idx_taskid ON TASK_LOG(Task_ID desc)
CREATE NONCLUSTERED INDEX idx_date on TASK_LOG(cr_date desc)





--if object_ID('TASK_ARCH') is not null
--drop table TASK_ARCH
----=== TASK_ARCH
--CREATE TABLE TASK_ARCH
--(
--	 TASK_ID int 
--	,CR_DATE datetime 
--	,LastUpdate_DATE datetime 
--	,[Owner] int 
--	,HeaderName varchar(50)
--	,[Desc] varchar(50)
--	,[Status] int 
--	,[Priority] int 
--	,[archDate] datetime
--)


--===================== TRIGERS TASK
GO
--==== Data ostatniej aktualizacji 
CREATE TRIGGER updateLastUpdateDate
ON TASK_NEW 
FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON

	update n set n.LastUpdate_DATE=getdate()
	FROM TASK_NEW n(NOLOCK)
	JOIN inserted i on n.Task_ID=i.Task_ID

INSERT INTO TASK_LOG (	[CR_User]	,[desc]								,[column]				,[VAL_OLD]										,[VAL_NEW]										,Task_ID)
SELECT					suser_name()	,'Zmiana daty ostatniego updatu'	,'LastUpdate_DATE'	,CAST(d.LastUpdate_DATE AS VARCHAR(100))		,CAST(i.LastUpdate_DATE AS VARCHAR(100))		,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID

END
GO


-- UPDATE
CREATE TRIGGER UpdateTask 
ON TASK_NEW
FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON
   
   INSERT INTO TASK_LOG (	[CR_User]		,[desc]							,[column]	,[VAL_OLD]								,[VAL_NEW]								,Task_ID)
   SELECT					suser_name()	,'zmiana w³aœciciela zadania'	,'Owner'	,CAST(d.[Owner] AS VARCHAR(100))		,CAST(i.[Owner] AS VARCHAR(100))		,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID and i.[Owner]<>d.[Owner]

   INSERT INTO TASK_LOG (	[CR_User]		,[desc]							,[column]	,[VAL_OLD]								,[VAL_NEW]							,Task_ID)
   SELECT					suser_name()	,'zmiana Statusu zadania'	,'STATUS'		,CAST(d.[Status] AS VARCHAR(100))		,CAST(i.[Status] AS VARCHAR(100))	,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID and d.[Status]<>i.[Status]

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]						,[column]		,[VAL_OLD]								,[VAL_NEW]							,Task_ID)
	SELECT					suser_name()	,'zmiana Priorytetu'		,'Priority'		,CAST(d.[Priority] AS VARCHAR(100))		,CAST(i.[Priority] AS VARCHAR(100))	,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID and i.[Priority]<>d.[Priority]

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]					,[column]			,[VAL_OLD]									,[VAL_NEW]							,Task_ID)
	SELECT					suser_name()	,'zmiana nag³ówka'		,'HeaderName'		,CAST(d.HeaderName AS VARCHAR(100)) 		,CAST(i.HeaderName AS VARCHAR(100))	,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID and d.HeaderName<>i.HeaderName

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]				,[column]	,[VAL_OLD]							,[VAL_NEW]							,Task_ID)
	SELECT					suser_name()	,'zmiana opisu'		,'Desc'		,CAST(d.[Desc] AS VARCHAR(100))		,CAST(i.[Desc] AS VARCHAR(100))		,i.Task_ID FROM inserted i join deleted d on i.Task_ID=d.Task_ID
	 and i.[Desc]<>d.[Desc]
END
GO
-- INSERT
CREATE TRIGGER InsertTASK 
ON TASK_NEW
FOR INSERT
AS 
BEGIN
	SET NOCOUNT ON
   
   INSERT INTO TASK_LOG (	[CR_User]		,[desc]							,[column]	,[VAL_OLD]	,[VAL_NEW]							,Task_ID)
   SELECT					suser_name()	,'Dodanie w³aœciciela zadania'	,'Owner'	,NULL		,CAST(i.[Owner] AS VARCHAR(100))	,i.Task_ID FROM inserted i

   INSERT INTO TASK_LOG (	[CR_User]		,[desc]							,[column]	,[VAL_OLD]	,[VAL_NEW]								,Task_ID)
   SELECT					suser_name()	,'Dodanie Statusu zadania'	,'STATUS'		,NULL		,CAST(i.[Status] AS VARCHAR(100))		,i.Task_ID FROM inserted i

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]						,[column]		,[VAL_OLD]	,[VAL_NEW]							,Task_ID)
	SELECT					suser_name()	,'Dodanie Priorytetu'		,'Priority'		,NULL		,CAST(i.[Priority] AS VARCHAR(100))	,i.Task_ID FROM inserted i

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]					,[column]			,[VAL_OLD]	,[VAL_NEW]								,Task_ID)
	SELECT					suser_name()	,'Dodanie nag³ówka'		,'HeaderName'		,NULL		,CAST(i.HeaderName AS VARCHAR(100))		,i.Task_ID FROM inserted i

	INSERT INTO TASK_LOG (	[CR_User]		,[desc]				,[column]	,[VAL_OLD]	,[VAL_NEW]							,Task_ID)
	SELECT					suser_name()	,'Dodanie opisu'	,'Desc'		,NULL		,CAST(i.[Desc] AS VARCHAR(100))		,i.Task_ID FROM inserted i

END


--===================== TRIGERS TASK END




