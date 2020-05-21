USE employees;

#Exercise 1
#Find the average salary of the male and female employees in each department. 

select d.dept_name, e.gender, avg(s.salary) from salaries s
join employees e on s.emp_no=e.emp_no
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
group by d.dept_name,e.gender
order by de.dept_no;

#Exercise 2
#Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number.
 
select min(dept_no) from dept_emp;
select max(dept_no) from dept_emp;

#Exercise 3
# Obtain a table containing the following three fields for all individuals whose employee number is no greater than 10040:
# - employee number
# - the smallest department number among the departments where an employee has worked in (use a subquery to retrieve this value from the 'dept_emp' table)
# - assign '110022' as 'manager' to all individuals whose employee number is less than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive (use a CASE statement to create the third field).

SELECT 
    e.emp_no,
    (SELECT 
            MIN(dept_no)
        FROM
            dept_emp de
        WHERE
            e.emp_no = de.emp_no) AS dept_no,
    CASE
        WHEN emp_no <= 10020 THEN '110022'
        ELSE '110039'
    END AS manager
FROM
    employees e
WHERE
    emp_no <= 10040;
    
#Exercise 4
#Retrieve a list of all employees that have been hired in 2000.

select first_name,last_name,hire_date from employees where hire_date between'2000-01-01'and '2000-12-31';

#Exercise 5
#Retrieve a list of all employees from the ‘titles’ table who are engineers.  
#Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers. 

select emp_no, title from titles where title='engineer';
select emp_no, title from titles where title like('%senior engineer%');

#Exercise 6
#Create a procedure that asks you to insert an employee number and that will obtain an output containing the same number, as well as the number and name of the last department the employee has worked in. 
#Finally, call the procedure for employee number 10010. 

DROP PROCEDURE IF EXISTS last_dept;

DELIMITER $$
CREATE PROCEDURE last_dept(IN p_emp_no INT)
begin
select e.emp_no, de.dept_no, d.dept_name from employees e
join dept_emp de on e.emp_no=de.emp_no
join departments d on de.dept_no=d.dept_no
where e.emp_no=p_emp_no 
and de.from_date=(select max(from_date) from dept_emp where emp_no=p_emp_no);
END$$
DELIMITER ;

call employees.last_dept(10010);

#Exercise 7
#How many contracts have been registered in the ‘salaries’ table with duration of more than one year and of value higher than or equal to $100,000?

SELECT to_date,from_date,
DATEDIFF(to_date, from_date) AS diff_in_days,salary
FROM salaries
where salary>=100000 and DATEDIFF(to_date, from_date)>=365;
SELECT count(distinct emp_no)
FROM salaries
where salary>=100000 and DATEDIFF(to_date, from_date)>=365;

#Exercise 8
# Create a trigger that checks if the hire date of an employee is higher than the current date. 
# If true, set the hire date to equal the current date. Format the output appropriately (YY-mm-dd). 

DROP TRIGGER IF EXISTS trig_hire_date;

DELIMITER $$
CREATE TRIGGER trig_hire_date
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	DECLARE today date;
    SELECT date_format(sysdate(), '%Y-%m-%d') INTO today;
	IF NEW.hire_date>today THEN
		SET NEW.hire_date = today;
    END IF;
END $$
DELIMITER ;

#Exercise 9
#Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356.  
#In addition, what is the lowest contract salary value of the same employee? 

DROP FUNCTION IF EXISTS f_emp_max_salary;

DELIMITER $$
CREATE FUNCTION f_emp_max_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
DECLARE v_max_salary DECIMAL(10,2);
SELECT 
    max(s.salary)
INTO v_max_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;
RETURN v_max_salary;
END$$
DELIMITER ;
SELECT f_emp_max_salary(11356);

DROP FUNCTION IF EXISTS f_emp_min_salary;

DELIMITER $$
CREATE FUNCTION f_emp_min_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
DECLARE v_min_salary DECIMAL(10,2);
SELECT 
    min(s.salary)
INTO v_min_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;
RETURN v_min_salary;
END$$
DELIMITER ;

#Exercise 10
# Based on the previous example, you can now try to create a function that accepts also a second parameter which would be a character sequence. 
# Evaluate if its value is 'min' or 'max' and based on that retrieve either the lowest or the highest salary (using the same logic and code 
# from Exercise 9). If this value is a string value different from ‘min’ or ‘max’, then the output of the function should return 
# the difference between the highest and the lowest salary.

DROP FUNCTION IF EXISTS f_emp_salary;

DELIMITER $$
CREATE FUNCTION f_emp_salary (p_emp_no INTEGER, p_min_or_max varchar(10)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_salary_info DECIMAL(10,2);

SELECT
    CASE
        WHEN p_min_or_max = 'max' THEN MAX(s.salary)
        WHEN p_min_or_max = 'min' THEN MIN(s.salary)
        ELSE MAX(s.salary) - MIN(s.salary)
    END AS salary_info
INTO v_salary_info FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;

RETURN v_salary_info;
END$$
DELIMITER ;

select employees.f_emp_salary(11356, 'min');
select employees.f_emp_salary(11356, 'max');
select employees.f_emp_salary(11356, 'inoign');