-- SELECT Statement
SELECT *
FROM parks_and_recreation.employee_demographics;

SELECT first_name, last_name,birth_date,
(age + 10) * 10 + 10
FROM parks_and_recreation.employee_demographics;
#PEDMAS

SELECT DISTINCT first_name,gender
FROM employee_demographics;

-- Where Clause 

SELECT * 
FROM employee_salary
WHERE salary <= 50000;

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01'
;

-- AND OR NOT -- Logical Operators

SELECT *
FROM employee_demographics
WHERE (first_name = 'leslie' AND age = 44) OR age > 55;

-- LIKE Statements 
-- % and _

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'jer__%';

-- GROUP BY 

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;

-- ORDER BY
SELECT * 
FROM employee_demographics
ORDER BY age, gender;

--- Having and Where
 
SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary) >75000;

-- Limit & Aliasing 

SELECT * 
FROM employee_demographics
ORDER BY age DESC
LIMIT 2,1;	

-- Aliasing

SELECT gender, AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING avg_age;

-- Joins 

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

-- Inner join

SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id;

-- Outer join

SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id;

-- Self Joins

SELECT emp1.employee_id AS emp_santa,
emp1.first_name AS frist_name_sanata,
emp1.last_name AS last_name_sanata,
emp2.employee_id AS emp_name_toy,
emp2.first_name AS frist_name_toy,
emp2.last_name AS last_name_toy
FROM employee_salary emp1
JOIN employee_salary emp2
ON emp1.employee_id = emp2.employee_id;

-- Joining multiple table together
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments AS pd
ON sal.dept_id = pd.department_id;

SELECT *
FROM parks_departments;

-- Unions

SELECT first_name, last_name, 'old man' AS lable 
FROM employee_demographics
WHERE age > 40 AND gender = 'male'
UNION
SELECT first_name, last_name, 'old lady' AS lable
FROM employee_demographics
WHERE age > 40 AND gender = 'female'
UNION 
SELECT first_name, last_name, 'highly paid Employee' AS lable
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name;

-- String Functions
SELECT LENGTH ('skyfall');

SELECT first_name, LENGTH(first_name)
FROM employee_demographics
ORDER BY 2;

SELECT upper('sky');
SELECT LOWER('sky');

SELECT first_name, UPPER(first_name)
FROM employee_demographics;

SELECT RTRIM('chris');

SELECT first_name,
LEFT(first_name,4),
RIGHT(first_name,4),
SUBSTRING(first_name,3,2),
SUBSTRING(birth_date,6,2)
FROM employee_demographics;

SELECT first_name, REPLACE(first_name,'a','p')
FROM employee_demographics;

SELECT first_name, LOCATE('An',first_name)
FROM employee_demographics;

SELECT first_name,last_name,  
CONCAT(first_name,' ',last_name) AS full_name
FROM employee_demographics;  

-- Case Statements

SELECT first_name,last_name,age,
CASE 
  WHEN age <=30 THEN 'Young'
  WHEN age BETWEEN 31 AND 50 THEN 'Old'
  END AS Age_Bracket 
FROM employee_demographics;

SELECT * 
FROM employee_salary;

-- Pay Increase and Bonus 
-- <50000 = 5%
-- >50000 = 7%
-- Finance = 10%

SELECT first_name,last_name,salary,
CASE 
WHEN salary < 50000 THEN salary * 1.05
WHEN salary > 50000 THEN salary * 1.07
END AS New_salary,
CASE 
WHEN dept_id = 6 THEN salary * .10
END AS Bonus
FROM employee_salary;

-- Subqueries 

SELECT * FROM employee_demographics
WHERE employee_id IN 
                  (SELECT employee_id
                  FROM employee_salary
                  WHERE dept_id = 1);

SELECT first_name, salary,
(SELECT AVG(salary)
FROM employee_salary )
FROM employee_salary 
GROUP BY first_name, salary;

-- Window Function

SELECT dem.first_name, dem.last_name, gender, salary, 
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) as Rolling_total
FROM employee_demographics dem
JOIN employee_salary sal
 ON dem.employee_id = sal.employee_id;
 
SELECT dem.employee_id,dem.first_name, dem.last_name, gender, salary, 
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_rank,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) dense_row_rank 
FROM employee_demographics dem
JOIN employee_salary sal
 ON dem.employee_id = sal.employee_id;
 
 -- CTEs
 WITH CTE_example AS
(
SELECT gender, AVG(salary) avg_salary, MAX(salary) Max_salary, MIN(salary) Min_salary, COUNT(salary) Count
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_salary) 
FROM CTE_example
;

-- Temporary Table

CREATE TEMPORARY TABLE temp_table
(first_name VARCHAR (50),
last_name VARCHAR (50),
favorite_movie VARCHAR(50)
);

INSERT INTO temp_table
VALUES('Alex','Freberg','Lord of the Ring: The Two Towers');

SELECT * FROM temp_table;

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * FROM salary_over_50k;

-- Stored Procedure

DELIMITER $$
CREATE PROCEDURE large_salary3()
BEGIN
    SELECT * 
	FROM employee_salary
	WHERE salary >= 50000;
	SELECT * 
	FROM employee_salary
	WHERE salary > 10000;
END $$
DELIMITER ;

CALL large_salary3();


DELIMITER $$
CREATE PROCEDURE large_salary4(P_employee_id INT)
BEGIN
    SELECT salary
	FROM employee_salary
	WHERE employee_id = P_employee_id;
END $$
DELIMITER ;

CALL large_salary4(1);

-- Trigger and Events

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary 
	FOR EACH ROW 
BEGIN 
INSERT INTO employee_demographics (employee_id,first_name,last_name)
VALUES (NEW.employee_id,NEW.first_name,NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary ( employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES(13, 'Susanta','KC', 'Pilot', '100000', '2');

SELECT * FROM employee_demographics;

SELECT * FROM employee_salary;

-- Events

DELIMITER $$
CREATE EVENT delete_retirees3
ON SCHEDULE EVERY 1 minute
DO
BEGIN 
    DELETE
    FROM employee_demograpics
    WHERE age >=60;
END $$
DELIMITER ;

    