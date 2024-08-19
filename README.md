Projekt podzielony na 5 kroków (query).

SQL SERVER 2022

1. Tworzenie tabel oraz triggerów działających na tabelach.
2. Stworzenie procedur, które dodają niezbędne dane.
3. Wywołanie procedur wraz z instrukcja SELECT dla zmienionej tabeli.
4. ustalanie róznych statusów oraz priorytetów na tabeli z zadaniami.
5. Widoki dla menadzera/ pracownika.


W większosci dodawanych danych została zastosowana funckja newid() tak, aby zachować losowość otrzymanych rekordów. Data zgłoszenia również jest "losowana" z przedziału dat od dzisiaj do dzisiaj-100.
W kodzie do dodawania danych do tabel zostały zastosowane różne rozwiazania kursor, pętle, inser into z selecta. Na poczet losowości i danego rozwiązania, została zastosowana dana logika. W przypadku dokładnych danych biznesowych i braku wymusoznej losowości, 
odpowiednio trzeba dostosować dane procedury do procesu, tak aby były najbardziej wydajne.

Jeśli chodzi o widoki, procedury z punktu 5. są przysotowane tak, aby w przypadku braku parametrów wejściowych "losować" rekord i wedle niego pokazać widok. Są przystosowane tak, że pokazuja dane zarówno dane usera, jak i te dostosowane dla niego, w zależności czy to podgląd menadzera czy pracownika.
Menadzer widzi zadania pracowników swojego działu. Zaś pracownik widzi zadania swoje oraz pracowników ze swojej firmy,ze swojego działu. W podglądzie została dodana kolumna tak, aby było widoczne, które zadania są przypisane do niego.   

Aspekty, które trzeba by jeszcze zaimplementować oprócz samego interejsu (ewentualnych logów do niego) na którym pracowaliby pracownicy to:
- archiwizacja logów - przykładowo rekordy starsze niż 30 dni są przenoszone do tabeli archiwizujące - wykonanie w JOBIE w nocy na bazie, kiedy obciążenie jest mniejsze. (Im większa ilość zadań, użytkowników, firm tym potrzeba ewentualnego zwiększenia podzialu w logach większa- kolejna archiwizacja)
- archwizacja zadań - jeśli menadzerowi potrzeba np danych tylko z tego miesiąca to poprzednie są przenoszone do logów / zadania zakończone z odpowiednio dostosowaną ilością dni do wymagań biznesowych - przenieść do archiwizacji
- dodanie logowania z interefejsu - co dany użytkownik wywołuje.
- zakładając, że interfejs opiera się na SQL-u, stworzenie i dostosowanie procedur umożliwiających pracę na danych, zmiane statusów,priorytetów,właścicieli zgłoszeń, tworzenie zadań, ewentualnie dodanie możliwości komenatrza do wykonywanego zadania itp.

Ewentualne kolejne zmiany czy procesy do opracowania zależa od dokladnych wymagań biznesowych.
 
