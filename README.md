# Pewlett Hackard
## Purpose
Pewlett Hackard is expecting to have a lot of their employees retiring soon and they are worried about having enough skilled employees to fill these positions. They have asked me to analyze their employee data to provide insight to this problem. To do this I found the current retirement eligible employees and their current titles. Pewlett Hackard is also looking to start a mentorship program for it’s employees born in 1965, so I found the current employees born in 1965 and their titles. 

## Methods - Deliverable 1: The Number of Retiring Employees by Title
1. First I used QuickDBD to create an ERD for the data I was provided.

![ERD](https://github.com/MichelaZ/PewletteHackardDB/blob/main/EmployeeDP.png)

2. In the module I created tables and imported data into the employee, department, department employee, salary, department manager and titles tables.

```
-- Departments
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

-- Employees
CREATE TABLE employees ( emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

-- dept_manager
CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

--Salaries
CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

-- Titles
CREATE TABLE Titles (
  emp_no INT NOT NULL,
  title VARCHAR (50) NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no, title, from_date)
);

-- dept_emp
CREATE TABLE dept_emp (
	dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
```
3. I used an inner join to get the employee names, title, start and end date for that position for all retirement eligible employees into a new table called retirement_titles.
```
SELECT e.emp_no,
e.first_name,
e.last_name,
t.title,
t.from_date,
t.to_date
INTO retirement_titles
FROM employees as e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY emp_no, to_date DESC;
```
![Retirement titles.]( https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/retirement_titles.png)

4. I used the distinct function to get rid of repeating values and filtered to only include current titles by setting the to date from the retirement titles table to '9999-01-01'. I added this to a new table called unique_titles and exported it.

```
SELECT DISTINCT ON (rt.emp_no) rt.emp_no,
rt.first_name,
rt.last_name,
rt.title,
rt.from_date,
rt.to_date
INTO unique_titles
FROM retirement_titles AS rt
WHERE (rt.to_date = '9999-01-01')
ORDER BY emp_no, to_date DESC;
```
![unique titles.]( https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/unique_titles.png)

5. Using the count and group by functions I gathered a the number of employees in each department that were retirement eligible.
```
Select * from unique_titles 
SELECT COUNT(ut.emp_no), ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title;
```
![Retiring titles.]( https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/retiring_titles.png)

## Methods: Deliverable 2: The Employees Eligible for the Mentorship Program

6. To get all the “mentorship eligible” employees I found all the distinct employees who were currently employed and born '1965-01-01' between '1965-12-31'
```
SELECT DISTINCT ON (e.emp_no) e.emp_no,
e.first_name,
e.last_name,
t.title,
t.from_date,
t.to_date
INTO  mentorship_eligibilty
FROM employees as e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND (t.to_date = '9999-01-01')
ORDER BY emp_no, to_date DESC;
```
![ mentorship eligible employees.]( https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/mentorship_eligibilty.png)

### Retiring Managers
I found the mangers who are retirement eligible.
```
SELECT DISTINCT ON (dm.emp_no) dm.emp_no,
e.first_name,
e.last_name,
d.dept_name,
dm.from_date,
dm.to_date
INTO retiring_managers
FROM dept_manager as dm
	inner join employees as e
	ON (dm.emp_no = e.emp_no)
		INNER JOIN departments as d
				ON (dm.dept_no = d.dept_no)
	INNER JOIN titles AS t
		ON (dm.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (dm.to_date = '9999-01-01')
ORDER BY emp_no, to_date DESC;
```
![Retirement eligible managers]()

### All Current Employees
I made a new table storing all the current employees to make it easier to compare the data from the retirement eligible and mentoship eligible employees.
```
SELECT e.emp_no,
    e.first_name,
    e.last_name,
de.to_date
INTO all_current_emp
FROM employees as e
LEFT JOIN dept_emp as de
ON e.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
```
I performed count functions on the unique titles and all current employee tables to get the total number of current employees.

|Retirement Eligible|All Current| %|
|72,458|240,124|30|
