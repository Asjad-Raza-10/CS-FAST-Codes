use [24L-0583 Lab 4];

-- Q1
SELECT fname, lname, ssn FROM employee
WHERE fname LIKE 'J%';

-- Q2
SELECT fname, lname, ssn FROM employee
WHERE lname LIKE '%son';

-- Q3
SELECT fname, lname, ssn FROM employee
WHERE fname LIKE 'A%' OR fname LIKE 'S%';

-- Q4
SELECT TOP 5 * FROM employee;

-- Q5
SELECT employee.fname, employee.lname, department.dname
FROM employee
FULL OUTER JOIN department
ON employee.dno = department.dnumber;

-- Q6
SELECT employee.fname, employee.lname, COUNT(works_on.pno) AS project_count
FROM employee
JOIN works_on ON employee.ssn = works_on.essn
GROUP BY employee.fname, employee.lname
HAVING COUNT(works_on.pno) > 1;

-- Q7
SELECT employee.fname, employee.lname, dependent.dependent_name
FROM employee
LEFT JOIN dependent ON employee.ssn = dependent.essn;

-- Q8
SELECT department.dname, AVG(employee.salary) AS avg_salary
FROM department
JOIN employee ON department.dnumber = employee.dno
GROUP BY department.dname
ORDER BY avg_salary DESC;

-- Q9
SELECT fname, lname, salary FROM employee
ORDER BY salary ASC;

-- Q10
SELECT dname FROM department
WHERE dnumber NOT IN
(SELECT dnum FROM project);

-- Q11
SELECT department.dname, COUNT(employee.ssn) AS total_employees
FROM department
LEFT JOIN employee ON department.dnumber = employee.dno
GROUP BY department.dname;

-- Q12
SELECT department.dname, department.dnumber, employee.fname, employee.lname, employee.ssn
FROM department
LEFT JOIN employee ON department.dnumber = employee.dno;

-- Q13
SELECT project.pname, project.pnumber, employee.fname, employee.lname, employee.ssn, works_on.hours
FROM project
LEFT JOIN works_on ON project.pnumber = works_on.pno
LEFT JOIN employee ON works_on.essn = employee.ssn;

-- Q14
SELECT department.dname, department.dnumber, employee.fname, employee.lname, employee.ssn
FROM department
LEFT JOIN employee ON department.mgrssn = employee.ssn;

-- Q15
SELECT department.dname, COUNT(employee.ssn) AS employee_count
FROM department
JOIN employee ON department.dnumber = employee.dno
GROUP BY department.dname
HAVING COUNT(employee.ssn) > 3;

-- Q16
SELECT dlocation, COUNT(dnumber) AS department_count
FROM dept_locations
GROUP BY dlocation
HAVING COUNT(dnumber) > 1;

-- Practice
SELECT department.dname, SUM(works_on.hours) AS total_hours
FROM department
JOIN employee ON department.dnumber = employee.dno
JOIN works_on ON employee.ssn = works_on.essn
GROUP BY department.dname
HAVING SUM(works_on.hours) >
(SELECT AVG(hours) FROM works_on)
ORDER BY total_hours DESC;