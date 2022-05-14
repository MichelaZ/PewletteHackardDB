-- Use Dictinct with Orderby to remove duplicate rows
--The Number of Retiring Employees by Title
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

Select * from retirement_titles 

SELECT DISTINCT ON (ce.emp_no) ce.emp_no,
ce.first_name,
ce.last_name,
t.title,
t.from_date,
t.to_date
INTO retirement_titles
FROM current_emp AS ce
	INNER JOIN titles AS t
		ON (ce.emp_no = t.emp_no)
ORDER BY emp_no, to_date DESC;

SELECT e.emp_no,
e.first_name,
ce.last_name,
t.title,
t.from_date,
t.to_date
INTO retirement_titles
FROM employees as e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
ORDER BY emp_no, to_date DESC;

-- using current_emp
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
t.title,
t.from_date,
t.to_date
INTO retirement_titles
FROM current_emp AS ce
	INNER JOIN titles AS t
		ON (ce.emp_no = t.emp_no)
	INNER JOIN employees as e
		On (ce.emp_no = e.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
ORDER BY emp_no, to_date DESC;

--Current_titles
SELECT DISTINCT ON (ce.emp_no) ce.emp_no,
ce.first_name,
ce.last_name,
t.title,
t.from_date,
t.to_date
INTO unique_titles
FROM current_emp AS ce
	INNER JOIN titles AS t
		ON (ce.emp_no = t.emp_no)
	INNER JOIN employees as e
		On (ce.emp_no = e.emp_no)
ORDER BY emp_no, to_date DESC;

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




Select * from retirement_titles 