-- Procedura a poni�ej tabela kt�r� nabija
use TEST


EXEC DodajPriority
	SELECT * FROM PRIORITY_TABLE p(NOLOCK)

EXEC DodajStatus
	SELECT * FROM Status_TABLE s(NOLOCK)

EXEC DodajDepartment
	SELECT * FROM DEPARTMENT d(NOLOCK)

EXEC DodajFirmy
	SELECT * FROM CUSTOMER c(NOLOCK)

EXEC dodajU�ytkownik�w
	SELECT * FROM Employee e(NOLOCK)

EXEC DodajZadania
	SELECT * FROM TASK_NEW t(NOLOCK) order by TASK_ID desc



-- SELECT dla tabeli log�w Zada�
/*

SELECT * FROM TASK_LOG t(NOLOCK)

*/
