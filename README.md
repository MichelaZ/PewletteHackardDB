# Pewlett Hackard
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

5. Using the count and group by functions I gathered the number of employees in each department that were retirement eligible.
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

### Counts and Percentages:
I made a new table storing all the current employees to make it easier to compare the data from the retirement eligible and mentorship eligible employees.
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
I performed count functions on the unique titles and all current employee tables to get the total employees. 
```
SELECT COUNT(ut.emp_no)
from unique_titles as ut;

SELECT COUNT(ace.emp_no)
from all_current_emp as ace;
```
I created [another table](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/title_counts.csv) storing the counts of mentorship eligible, retirement eligible, and all current employees by title and department. 

```
select 
	d.dept_name,
	t.title,
	count(me.emp_no) as mentorship_eligibil,
	count (ut.emp_no) as retiring,
	count(ace.emp_no) as current_emp
into emp_status_counts
FROM all_current_emp as ace
	Left join unique_titles as ut
		ON (ace.emp_no = ut.emp_no)
	Left join mentorship_eligibilty as me
		ON (ace.emp_no = me.emp_no)		
	inner join dept_emp as de
		ON (ace.emp_no = de.emp_no)
		INNER JOIN departments as d
				ON (de.dept_no = d.dept_no)	
	inner join titles as t
		ON (ace.emp_no = t.emp_no)
group by d.dept_name, t.title		
ORDER BY d.dept_name, t.title DESC;
```
Then I used this data to calculate the percent of employees retirement eligible, the percent of employees eligible for the mentorship program, and the percent of positions these employees would fill. To see the data grouped by department and title view the [percentages csv in the resources folder](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/percentage2.png).
```
select 
	esc.dept_name,
	esc.title,	
	esc.retiring*100.0/ esc.current_emp as percent_retiring,
	esc.mentorship_eligibil*100.0/esc.current_emp as percent_mentorship_eligibil
into percentages
FROM emp_status_count as esc
ORDER BY esc.dept_name, esc.title DESC;	
	
select 
	esc.dept_name,
	round(sum(esc.retiring)*100.0/ sum(esc.current_emp)) as percent_retiring,
	round(sum(esc.mentorship_eligibil)*100.0/sum(esc.current_emp)) as percent_mentorship_eligibil,
	round(sum(esc.mentorship_eligibil)*100.0/sum(esc.retiring)) as percent_ME_vs_RE
FROM emp_status_count as esc
group by esc.dept_name		
ORDER BY esc.dept_name DESC;
```
__Percentages by Department__
![Percentages by department](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/percentage2.png)


## Conclusions:

|Mentorship Eligible|Retirement Eligible|All Current|
|---|---|---|
|1549|72,458|240,124|

Thirty percent of Pewlette Hackard's employees are retirement eligible. You can see in the table above how many employees are needed to fill these jobs. If it is the intent for the mentorship eligible employees to fill these posts, they will hardly make a scratch as they only account for about 1% of employees. When the distinct titles from the mentorship eligible employees (in table below do not cover all the titles of the retirement eligible employees from the [retiring_titles.csv](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Submission/retiring_titles.csv). I would look to expand the mentorship beyond the current requirements. I think years of service would be a better metric, so I gathered data on average [years of service for each position](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/avg_yos.csv). 

![Mentorship eligible titles](https://github.com/MichelaZ/PewletteHackardDB/blob/main/ME%20_titles.png)

### Years of Service

```
SELECT e.emp_no,
DATE_PART('year', '1999-01-01'::date)-DATE_PART('year', e.hire_date::date) as YOS
into years_of_service
from employees as e;


select 
	d.dept_name,
	t.title,
	round(avg(y.YOS)) as avg_yos
into dept_title_avg_yos
FROM all_current_emp as ace
	inner join years_of_service as y
		ON (ace.emp_no = y.emp_no)
	inner join dept_emp as de
		ON (ace.emp_no = de.emp_no)
		INNER JOIN departments as d
				ON (de.dept_no = d.dept_no)	
		inner join employees as e
		ON (ace.emp_no = e.emp_no)
		inner join titles as t
		ON (ace.emp_no = t.emp_no)
WHERE (e.birth_date not BETWEEN '1952-01-01' AND '1955-12-31')
group by d.dept_name, t.title		
ORDER BY d.dept_name DESC;	

select 
	d.dept_name,
	t.title,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (y.YOS) ) as med_yos
into med_yos
FROM all_current_emp as ace
	inner join years_of_service as y
		ON (ace.emp_no = y.emp_no)
	inner join dept_emp as de
		ON (ace.emp_no = de.emp_no)
		INNER JOIN departments as d
				ON (de.dept_no = d.dept_no)	
		inner join employees as e
		ON (ace.emp_no = e.emp_no)
		inner join titles as t
		ON (ace.emp_no = t.emp_no)
WHERE (e.birth_date not BETWEEN '1952-01-01' AND '1955-12-31')
group by d.dept_name, t.title		
ORDER BY d.dept_name DESC;
```
Here are the average years of service by department. The median YOS are about the same. They are also about the same if you filter out the retiring employees, so I only chose to save the average years of service as a png.
![YOS by department](https://github.com/MichelaZ/PewletteHackardDB/blob/main/Resources/avg_yos_all_emps.png)

I used the percentile_cont function to find the quartiles and max to find the max years of service for all current employees.
```
select 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (y.YOS) ) as med_yos
from years_of_service as y;

select 
max (y.YOS) as max_yos
from years_of_service as y;	   
```	

|Q1|Q2|Q3|Max|
|--|--|--|--|
|7|10|12|14|

Looking at the years of service data there are many experienced employees to fill posts as retirement eligible employees leave the workforce. Even though there are a large number of employees leaving senior positions there are many employees with 7+ years of experience who could be trained in to fill those rolls. The average years of service is 10 years which is significantly higher than the Bureau of Labor Statistics average of about 4 years, so it seems that PH's biggest problem is most likely hiring and/or retaining entry level employees. I recommend increasing annual new hires and focusing on how you can improve the experience of these workers. 

PH's Human Resource department should consider the following questions to find why are there so few employees who have been with the company for less than 7 years:
- Is there high entry level turnover?
	- Is there something about the workplace culture that specifically detracts entry level employees?
	- Are there sufficient growth opportunities?
	- what are competitors doing?
- How are satisfied are your employees?
	- How flexible is your scheduling?
	- Are employees happy with their compensation and benefits? How quickly do they get access to these benefits?
	- How do employees feel about company practices in regards to inclusion/diversity?
	- Do they have a sense of autonomy in the workplace?
	- Do employees feel supported by their management teams?
	
This data does not necessarily count years of experice certain position orof experience with another company. Looking deeper into those data points would also be good metrics to find good mentors. Another idea I prefer to the 1965 year filter would be to ask employees and leadership staff for recommendations.	

### Result Summary:
- 30% of Pewlett Hackard employees are retirement eligible.
- Only 1% of employees are eligible for the mentorship program.
	- These employees do not have experience in all the positions of the retirement eligible employees.	
- Pewlett Hackard employees have higher average years of service then most companies.
- Increase hiring generally.
- Improve conditions for entry-level employees.

__Reference:__

EMPLOYEE TENURE IN 2020. *Bureau of Labor statistics.* 9/22/2020. https://www.bls.gov/news.release/pdf/tenure.pdf 5/15/22.

##### Authors notes:

I had some issues with the ambiguity of the brief:
- I'm not sure what year it's supposed to be. Is it 2000 and all these people are retiring at age 45? Even if you are retirement eligible at 45, I think a significant number of people would stay for the extra social security benefits at 62. Since COVID-19 many people have been retiring early, but if it's somewhere between 2017-2022 then a lot of data is missing. 
- Additionally would be nice to have some information on the mentorship program. Why are only people born in 1965 eligible?
- It is important to acknowledge that training requirements for the same position in different departments may very, so in the queries I preformed I tried to group by either department or title and department.
- There are some other examples of me playing around with queries in the schema file and some examples of outputs that I didn't fit into the narrative of my analysis, but feel free to check them out.



