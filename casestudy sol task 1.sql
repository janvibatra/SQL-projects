CREATE DATABASE LOANS
USE LOANS

SELECT NAME
FROM sys.databases

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE'

SELECT TOP 5 * FROM Banker_INFO
SELECT TOP 5 * FROM Customer_INFO
SELECT TOP 5 * FROM Home_Loan
SELECT TOP 5 * FROM Loan_Records

--TASK 2 

-- Q Find the ID, first name, and last name of the top 2 bankers (and corresponding transaction count) involved in the highest number of distinct loan records.
SELECT A.banker_id,A.first_name,A.last_name, COUNT(B.transaction_date) AS TRANSACTION_COUNT
FROM BANKER_INFO AS A
INNER JOIN Loan_Records AS B 
ON A.banker_id=B.banker_id
WHERE A.banker_id IN 
				(SELECT TOP 2 banker_id 
				  FROM Loan_Records
				  GROUP BY banker_id
				  ORDER BY COUNT(loan_id) DESC )
GROUP BY A.banker_id,A.first_name,A.last_name

-- Q Find the average age (at the point  transaction, in years and nearest integer) of female customers who took a non-joint loan for townhomes.
SELECT AVG(DATEDIFF(YEAR,dob,GETDATE())) AS AVG_AGE
FROM Customer_INFO AS A
INNER JOIN Loan_Records AS B
ON A.customer_id = B.customer_id
INNER JOIN Home_Loan AS C
ON B.loan_id = C.loan_id
WHERE GENDER='Female'
		AND
	property_type LIKE 'town%'
		AND
	joint_loan= 0


-- Q. Find the total number of different cities for which home loans have been issued.
SELECT COUNT(City) AS TOT_CITIES
FROM(
		SELECT DISTINCT city
		FROM Home_Loan
 ) AS X


 -- Q. Find the maximum property value (using appropriate alias) of each property type, ordered by the maximum property value in descending order.
SELECT property_type, MAX(property_value) AS MAX_PROP_VALUE
FROM Home_Loan
GROUP BY property_type
ORDER BY MAX(property_value) DESC


--Q. Find the average loan term for loans not for semi-detached and townhome property types, and are in the following list of cities: Sparks, Biloxi, Waco, Las Vegas, and Lansing. 
SELECT AVG(loan_term) AS AVG_LOAN_TERM 
FROM Home_Loan
WHERE property_type<> 'semi-detached'
	AND property_type<> 'townhome'
	AND city IN ('Sparks','Biloxi','Waco','Las Vegas','Lansing')




--Q. Find the city name and the corresponding average property value (using appropriate alias) for cities where the average property value is greater than $3,000,000.
SELECT city,AVG(property_value) AS AVG_PROP_VALUE
FROM Home_Loan
GROUP BY city
HAVING AVG(property_value)>3000000


--Q. Find the number of home loans issued in San Francisco.
SELECT COUNT(loan_id) AS TOT_LOANS
FROM Home_Loan
WHERE city='San Francisco'


--Q. Find the customer ID, first name, last name, and email of customers whose email address contains the term 'amazon'.
SELECT customer_id, first_name, last_name, email
FROM Customer_INFO
WHERE email LIKE '%amazon%'


--Q. Find the names of the top 3 cities (based on descending alphabetical order) and corresponding loan percent (in ascending order) with the lowest average loan percent. 
SELECT DISTINCT  TOP 3 city, AVG(loan_percent) AS AVG_LOAN_PERCENT
FROM Home_Loan
GROUP BY city
ORDER BY  city DESC,AVG(loan_percent) ASC


--Q. Find the average age of male bankers (years, rounded to 1 decimal place) based on the date they joined WBG 
	SELECT FORMAT(BANKERS_AGE,'0.0') AS AVG_AGE
	FROM
		(SELECT AVG(DATEDIFF(YEAR,dob,date_joined)) AS BANKERS_AGE
		FROM Banker_INFO
		WHERE gender='Male')
 AS X



 --- TASK 3

 --Q. Find the top 3 transaction dates (and corresponding loan amount sum) for which the sum of loan amount issued on that date is the highest.
 SELECT TOP 3 B.Transaction_date , SUM(ROUND((A.property_value* A.loan_percent/ 100), 2)) AS LOAN_AMT
 FROM Home_Loan AS A
 INNER JOIN Loan_Records AS B
 ON A.loan_id=B.loan_id
 GROUP BY B.transaction_date


 --Q. Find the number of bankers involved in loans where the loan amount is greater than the average loan amount. 
  SELECT COUNT(TOT_BANKERS) AS NO_OF_BANKERS
  FROM (
          SELECT C.banker_id AS TOT_BANKERS,ROUND((A.property_value* A.loan_percent/ 100), 2) AS LOAN_AMNT 
          FROM Home_Loan AS A
          INNER JOIN Loan_Records AS B
          ON A.loan_id=B.loan_id
          INNER JOIN Banker_INFO AS C
          ON B.banker_id=C.banker_id
          WHERE ROUND((A.property_value* A.loan_percent/ 100), 2) >
                (     SELECT AVG(ROUND((property_value* loan_percent/ 100), 2)) AS AVG_LOAN_AMT
          	         FROM Home_Loan
          ) 
	) AS X


--Q. Find the ID, first name and last name of customers with properties of value between $1.5 and $1.9 million, along with a new column 'tenure' that categorizes how long the customer has been with WBG. 

--The 'tenure' column is based on the following logic:
--Long: Joined before 1 Jan 2015
--Mid: Joined on or after 1 Jan 2015, but before 1 Jan 2019
--Short: Joined on or after 1 Jan 2019
SELECT A.customer_id, A.first_name, A.last_name, A.customer_since, C.property_value,
CASE 
     WHEN customer_since < '2015-01-01' THEN 'LONG'
	 WHEN customer_since >= '2015-01-01' AND customer_since < '2019-01-01' THEN 'MID'
	 ELSE 'SHORT'
 END AS TENURE
FROM Customer_INFO AS A
INNER JOIN Loan_Records AS B
ON A.customer_id= B.customer_id
INNER JOIN Home_Loan AS C
ON B.loan_id= C.loan_id
WHERE property_value BETWEEN 1500000 AND 1900000


--Q. Find the number of Chinese customers with joint loans with property values less than $2.1 million, and served by female bankers.
SELECT COUNT(C.customer_id) AS TOT_CUST
FROM Banker_INFO AS A
INNER JOIN Loan_Records AS B
ON A.banker_id= B.banker_id
INNER JOIN Customer_INFO AS C
ON B.customer_id= C.customer_id
INNER JOIN Home_Loan AS D
ON B.loan_id= D.loan_id
 WHERE D.property_value < 2100000
      AND A.gender= 'Female'
	  AND C.nationality LIKE 'Chin%'

--Q. Find the ID and full name (first name concatenated with last name) of customers who were served by bankers aged below 30 (as of 1 Aug 2022).
SELECT A.customer_id, CONCAT(A.first_name,' ',A.last_name)
FROM Customer_INFO AS A
INNER JOIN Loan_Records AS B
ON A.customer_id= B.customer_id
INNER JOIN Banker_INFO AS C
ON B.banker_id= C.banker_id
WHERE DATEDIFF(YEAR,C.dob,'2022-08-01') < 30 


--Q. Find the sum of the loan amounts ((i.e., property value x loan percent / 100) for each banker ID, excluding properties based in the cities of Dallas and Waco. The sum values should be rounded to nearest integer.  
SELECT C.banker_id, SUM(ROUND((A.property_value * A.loan_percent / 100), 2)) AS TOT_LOAN_AMT
FROM Home_Loan AS A
INNER JOIN Loan_Records AS B
ON A.loan_id= B.loan_id
INNER JOIN Banker_INFO AS C
ON B.banker_id= C.banker_id
WHERE A.city <> 'Dallas'
		AND
      A.city <> 'Waco'
GROUP BY C.banker_id


--Q. Create a view called `dallas_townhomes_gte_1m` which returns all the details of loans involving properties of townhome type, located in Dallas, and have loan amount of >$1 million.
CREATE VIEW 
dallas_townhomes_gte_1m AS 
       SELECT loan_id, property_type, country, city, property_value, loan_percent, loan_term, postal_code,
       joint_loan
       FROM Home_Loan
       WHERE property_type = 'townhouse'
             AND city = 'Dallas'
	     AND property_value * loan_percent / 100 > 1000000


--Q. Create a stored procedure called `recent_joiners` that returns the ID, concatenated full name, date of birth, and join date of bankers who joined within the recent 2 years (as of 1 Sep 2022) 

--Call the stored procedure `recent_joiners` you created above
GO
CREATE PROCEDURE recent_joiners
AS
BEGIN
		DECLARE @STARTDATE DATE = DATEADD(YEAR,-2,'2022-09-01');
		DECLARE @ENDDATE DATE = '2022-09-01';

SELECT banker_id, CONCAT(first_name,' ',last_name) AS FULLNAME, dob, date_joined
FROM Banker_INFO
WHERE date_joined BETWEEN @STARTDATE AND @ENDDATE;
END;


--Q. Create a stored procedure called `city_and_above_loan_amt` that takes in two parameters (city_name, loan_amt_cutoff) that returns the full details of customers with loans for properties in the input city and with loan amount greater than or equal to the input loan amount cutoff.  

--Call the stored procedure `city_and_above_loan_amt` you created above, based on the city San Francisco and loan amount cutoff of $1.5 million 
  
  
   GO
CREATE PROCEDURE city_and_above_loan_amt

    @city_name NVARCHAR(50),
    @loan_amt_cutoff DECIMAL(18, 2)
AS
BEGIN
    SELECT C.customer_id,CONCAT(c.first_name,+ ' '+c.last_name) as Cust_Name, c.email,c.dob,c.phone,
	c.gender, property_value*loan_percent/100 as LoanAmount
    FROM Home_Loan as A
	inner join Loan_Records as B
	on A.loan_id = B.loan_id
	inner join Customer_INFO as C
	on b.customer_id = c.customer_id
    WHERE A.city = @city_name AND (Select property_value*loan_percent/100 ) >= @loan_amt_cutoff;
END;

EXEC city_and_above_loan_amt 'San Francisco', 1500000;