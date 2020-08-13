#1. +Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.
SELECT * 
FROM client  
WHERE length(FirstName)<6;

#2. +Вибрати львівські відділення банку.+

SELECT * FROM department 
WHERE DepartmentCity = 'Lviv';
#3. +Вибрати клієнтів з вищою освітою та посортувати по прізвищу.

SELECT * 
FROM client  
WHERE Education='high' 
ORDER BY LastName;

#4. +Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.

SELECT * 
FROM application 
ORDER BY idApplication DESC 
LIMIT 5 OFFSET 10;

#5. +Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.

SELECT * 
FROM client  
WHERE LastName LIKE '%OVA'  OR LastName LIKE '%OV';

#6. +Вивести клієнтів банку, які обслуговуються київськими відділеннями.

SELECT * 
FROM client c 
	JOIN  department d ON c.Department_idDepartment=d.idDepartment 
WHERE d.DepartmentCity='Kyiv';

#7. +Вивести імена клієнтів та їхні номера телефону, погрупувавши їх за іменами.

SELECT count(FirstName), FirstName, Passport 
FROM client 
GROUP BY FirstName;

#8. +Вивести дані про клієнтів, які мають кредит більше ніж на 5000 тисяч гривень.
SELECT * FROM client c
JOIN application a ON a.Client_idClient= c.idClient 
WHERE Sum>5000 AND Currency ='Cryvnia'  ;

#9. +Порахувати кількість клієнтів усіх відділень та лише львівських відділень.

SELECT count(idClient), d.DepartmentCity 
FROM client c
	JOIN  department d ON c.Department_idDepartment=d.idDepartment;

SELECT count(idClient) 
FROM client c
	JOIN  department d ON c.Department_idDepartment=d.idDepartment
WHERE d.DepartmentCity='Lviv';

#10. Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.
SELECT  Sum, Client_idClient,  Client_idClient, idClient, FirstName 
FROM client c
	JOIN application a ON a.Client_idClient= c.idClient 
GROUP BY Client_idClient;


#11. Визначити кількість заявок на крдеит для кожного клієнта.

SELECT  Count(Client_idClient) AS NumberCredits,  FirstName, LastName 
FROM client c
	JOIN application a ON a.Client_idClient= c.idClient 
GROUP BY Client_idClient;

#12. Визначити найбільший та найменший кредити.

SELECT  max(Sum) AS MaxCredit,  min(Sum) AS MinCredit 
FROM client c
	JOIN application a ON a.Client_idClient= c.idClient ;

#13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.

SELECT  Count(a.Client_idClient) AS NumberCredits,  c.FirstName, c.LastName, c.Education 
FROM client c 
	JOIN application a ON a.Client_idClient= c.idClient  
WHERE c.Education='high' 
GROUP BY a.Client_idClient;


#14. Вивести дані про клієнта, в якого середня сума кредитів найвища.

SELECT max(maxCredit), idClient ,FirstName, LastName, Education, Passport, City, Age, Department_idDepartment 
FROM(
	SELECT  avg(a.Sum) AS maxCredit ,  c.idClient ,c.FirstName, c.LastName, c.Education, c.Passport, c.City, c.Age, c.Department_idDepartment 
    FROM client c 
		JOIN application a ON a.Client_idClient= c.idClient  
    GROUP BY a.Client_idClient
) AS avgCredit ;

#15. Вивести відділення, яке видало в кредити найбільше грошей

SELECT max(sumMax), idDepartment, DepartmentCity, CountOfWorkers 
FROM(
	SELECT sum(a.Sum) AS sumMax , d.idDepartment, d.DepartmentCity, d.CountOfWorkers 
    FROM client c JOIN application a ON a.Client_idClient= c.idClient 
		JOIN department d ON  d.idDepartment= c.Department_idDepartment 
	group by c.Department_idDepartment
) AS sumCredit ;

#16. Вивести відділення, яке видало найбільший кредит.

SELECT max(a.Sum) AS sumMax , d.idDepartment, d.DepartmentCity, d.CountOfWorkers 
FROM client c 
	JOIN application a ON a.Client_idClient= c.idClient 
    JOIN department d ON  d.idDepartment= c.Department_idDepartment;

#17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.

UPDATE client c 
	JOIN application a ON a.Client_idClient= c.idClient  
SET a.Sum= 6000, Currency='Gryvnia' 
WHERE c.Education='high';

#18. Усіх клієнтів київських відділень пересилити до Києва.
UPDATE client c
	JOIN  department d ON c.Department_idDepartment=d.idDepartment
SET c.City= 'Kyiv'
WHERE d.DepartmentCity='Kyiv';

#19. Видалити усі кредити, які є повернені.


set sql_safe_updates = 0;
DELETE FROM application 
WHERE CreditState='Returned';
set sql_safe_updates = 1;

#20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.
set sql_safe_updates = 0;
DELETE FROM application 
WHERE Client_idClient IN ( 
	SELECT idClient FROM client WHERE 
								LastName LIKE '_a%' OR
                                LastName LIKE '_o%' OR
                                LastName LIKE '_e%' OR
                                LastName LIKE '_i%' );
set sql_safe_updates = 1;
#Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000
SELECT idDepartment, DepartmentCity, CountOfWorkers 
FROM(
	SELECT sum(a.Sum) AS sumCredit , d.idDepartment, d.DepartmentCity, d.CountOfWorkers 
	FROM client c 
		JOIN application a ON a.Client_idClient= c.idClient 
		JOIN department d ON  d.idDepartment= c.Department_idDepartment 
	WHERE d.DepartmentCity ='Lviv'
	group by c.Department_idDepartment
) AS lvivDepartment
WHERE  sumCredit>500;


#Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000

SELECT * 
FROM client c 
	JOIN application a ON a.Client_idClient= c.idClient 
WHERE a.CreditState='Returned' AND a.Sum>5000;

/* Знайти максимальний неповернений кредит.*/

SELECT max(a.Sum) , a.CreditState, c.FirstName 
FROM client c 
	JOIN application a ON a.Client_idClient= c.idClient 
WHERE a.CreditState='Not returned';


/*Знайти клієнта, сума кредиту якого найменша*/

SELECT min(a.Sum) , c.idClient , c.FirstName, c.LastName, c.Education, c.Passport, c.City, c.Age, c.Department_idDepartment 
FROM client c 
	JOIN application a ON a.Client_idClient= c.idClient;


/*Знайти кредити, сума яких більша за середнє значення усіх кредитів*/

SELECT * FROM application
WHERE Sum>(
SELECT avg(Sum) FROM application);

#/*Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів*/
SELECT  idClient , FirstName, LastName, Education, Passport, City, Age, Department_idDepartment 
FROM client
WHERE City=(
			SELECT City
			FROM( SELECT count(a.Client_idClient) AS numberCredit,c.City
				FROM client c 
						JOIN application a ON a.Client_idClient= c.idClient
				group by a.Client_idClient
				order by numberCredit DESC 
				limit 1
			) AS t
		) ;


#місто чувака який набрав найбільше кредитів
SELECT City
FROM( 
	SELECT count(a.Client_idClient) AS numberCredit,c.City
	FROM client c 
		JOIN application a ON a.Client_idClient= c.idClient
	group by a.Client_idClient
	order by numberCredit DESC 
    limit 1
) AS t;