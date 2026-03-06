USE [24L-0583 Lab 5]

-- Q1
SELECT fname, lname
FROM doctor 
WHERE salary >
(SELECT AVG(salary)
FROM doctor);

-- Q2
SELECT fname, lname
FROM doctor
WHERE ssn IN
(SELECT essn 
FROM performed_by
)

-- Q3
SELECT fname, lname
FROM doctor d1
WHERE salary >
(SELECT AVG(salary) 
FROM doctor d2
WHERE d2.sno = d1.sno);

-- Q4
SELECT AVG(hours)
FROM performed_by p1
WHERE 
(SELECT SUM(p2.hours)
FROM performed_by p2
WHERE p2.essn = p1.essn) > 10;

-- Q5
SELECT sname 
FROM specialization s
WHERE snumber IN
(SELECT sno FROM performed_by p1
WHERE (SELECT COUNT(*)
FROM performed_by p2 
WHERE p1.sno = p2.sno) > 3);

-- Q6
SELECT sname
FROM specialization s
WHERE mgrssn IS NOT NULL
AND NOT EXISTS (
SELECT 1 FROM performed_by p
WHERE s.mgrssn = p.essn);

-- Q7
SELECT *
FROM doctor 
WHERE ssn IN 
(SELECT DISTINCT essn
FROM performed_by p1
WHERE hours >
(SELECT AVG(hours) 
FROM performed_by p2));

-- Q8
SELECT COUNT(*) AS Doctors_Count
FROM doctor d1 
WHERE d1.salary > 
(SELECT d2.salary FROM doctor d2
WHERE d2.ssn = d1.superssn
);

-- Q9
SELECT * FROM surgery sg
WHERE snumber IN 
(SELECT sno FROM performed_by p
WHERE hours > 
(SELECT MAX(hours) FROM performed_by p2
WHERE sno =
(SELECT snum FROM surgery sg2
WHERE sg2.snum = 
(SELECT snumber FROM specialization sp
WHERE sname = 'Immunology'))
));

-- Q10
SELECT fname, lname FROM doctor d
WHERE d.ssn IN 
(SELECT p1.essn FROM performed_by p1
WHERE p1.hours > 2 * (
SELECT AVG(p2.hours)
FROM performed_by p2
WHERE p2.sno = p1.sno
AND p2.essn <> p1.essn
)) AND d.ssn IN 
(SELECT dp1.essn FROM dependent dp1
WHERE (SELECT COUNT(*)
FROM dependent dp2
WHERE dp2.essn = dp1.essn) > 1);

-- Q11 (Practice)
SELECT sp.sname 
FROM specialization sp
WHERE (
(SELECT MAX(dep_count) - MIN(dep_count)
FROM (SELECT 
(SELECT COUNT(*) 
FROM dependent d1 
WHERE d1.essn = dc.ssn) AS dep_count
FROM doctor dc WHERE dc.sno = sp.snumber
) AS sub)) >= 1.25 * (
SELECT COUNT(*) 
FROM spec_locations sl
WHERE sl.snumber = sp.snumber);
