-- Q1
CREATE VIEW v_doctor_info AS
SELECT d.fname + ' ' + d.lname AS 'Full Name', s.sname AS Specialization, d.salary AS Salary
FROM doctor d INNER JOIN specialization s
ON d.sno = s.snumber;

-- Q2
CREATE VIEW v_specialization_managers AS
SELECT s.sname AS 'Specialization Name', d.fname + ' ' + d.lname AS 'Doctor Name',
mgrstartdate AS 'Management Start Date'
FROM specialization s INNER JOIN doctor d
ON s.mgrssn = d.ssn;

-- Q3
CREATE VIEW v_doctor_dependents AS
SELECT d.lname AS 'Doctor Last Name', dp.dependent_name AS 'Dependent Name', 
dp.relationship AS 'Relationship'
FROM doctor d INNER JOIN dependent dp
ON d.ssn = dp.essn;

-- Q4
CREATE VIEW v_surgery_details AS
SELECT sg.sname AS 'Surgery Name', sg.slocation AS 'Surgery Location', 
sp.sname AS 'Specialization Name'
FROM surgery sg INNER JOIN specialization sp
ON sg.snum = sp.snumber;

-- Q5
CREATE VIEW v_senior_doctors AS
SELECT * FROM doctor
WHERE salary > 60000;

INSERT INTO v_senior_doctors (fname, minit, lname, ssn, address, sex, salary, superssn, sno)
VALUES ('Asjad', 'M', 'Raza', '123451789', 'Lahore', 'M', 75000, '123456789', 3);

SELECT * FROM v_senior_doctors;

INSERT INTO v_senior_doctors (fname, minit, lname, ssn, address, sex, salary, superssn, sno)
VALUES ('Asjad', 'M', 'Raza', '123452789', 'Lahore', 'M', 45000, '123456789', 3);

SELECT * FROM v_senior_doctors;
SELECT * FROM doctor;

-- Q6
CREATE PROCEDURE sp_GetDoctorsBySpec
    @SpecializationName VARCHAR(50)
    AS
BEGIN
    SELECT d.fname + ' ' + d.lname AS 'Full Name', s.sname AS 'Specialization', d.salary AS 'Salary'
    FROM doctor d INNER JOIN specialization s
    ON d.sno = s.snumber
    WHERE s.sname = @SpecializationName;
END;

EXEC sp_GetDoctorsBySpec 'Cardiology';

-- Q7
CREATE PROCEDURE sp_RaiseSalary
    @DoctorSSN CHAR(9),
    @Percentage FLOAT
    AS
BEGIN
    UPDATE doctor
    SET salary = salary + (salary * @Percentage / 100)
    WHERE ssn = @DoctorSSN;
END;

SELECT * FROM Doctor;
EXEC sp_RaiseSalary '112233445', 15;
SELECT * FROM Doctor;

-- Q8
CREATE PROCEDURE sp_AddSurgeryPerformance
    @essn CHAR(9),
    @sno INT,
    @hours FLOAT
    AS
BEGIN
    INSERT INTO performed_by
    VALUES(@essn, @sno, @hours);
END;

SELECT * FROM performed_by;
EXEC sp_AddSurgeryPerformance '123456789', 4, 13.5;
SELECT * FROM performed_by;

-- Q9
CREATE PROCEDURE sp_CountDependents
    @ssn CHAR(9),
    @count INT OUTPUT
    AS
BEGIN
    SELECT @count = COUNT(*) FROM dependent WHERE essn = @ssn; 
END;

DECLARE @DependentCount INT;
EXEC sp_CountDependents '123456789', @DependentCount OUTPUT;
PRINT @DependentCount;

-- Q10
CREATE PROCEDURE sp_TransferDoctor
    @ssn CHAR(9),
    @snumber INT
    AS
BEGIN
    UPDATE Doctor
    SET sno = @snumber WHERE ssn = @ssn;
    UPDATE Doctor
    SET superssn = (SELECT mgrssn FROM specialization WHERE snumber = @snumber) WHERE ssn = @ssn;
END;

SELECT * FROM Doctor;
EXEC sp_TransferDoctor '123456789', 2;
SELECT * FROM Doctor;

-- Practice Question 1
CREATE VIEW v_DoctorWorkload
AS
SELECT d.fname + ' ' + d.lname AS 'Full Name', ISNULL(SUM(pb.hours),0) AS 'Total Surgery Hours',
d.salary AS 'Current Salary',
(SELECT COUNT(*) FROM dependent dp WHERE dp.essn = d.ssn) AS 'Dependent Count'
FROM doctor d
LEFT JOIN performed_by pb ON d.ssn = pb.essn
GROUP BY d.ssn, d.fname, d.lname, d.salary;

CREATE PROCEDURE sp_ApplyWorkloadBonus
    @ThresholdHours FLOAT,
    @AffectedDoctorsCount INT OUTPUT
AS
BEGIN
    UPDATE d
    SET d.salary = 
        CASE 
            WHEN vw.[Total Surgery Hours] > @ThresholdHours AND vw.[Dependent Count] > 0 THEN d.salary * 1.10
            WHEN vw.[Total Surgery Hours] > @ThresholdHours AND vw.[Dependent Count] = 0 THEN d.salary * 1.05
            ELSE d.salary
        END
    FROM doctor d
    INNER JOIN v_DoctorWorkload vw ON vw.[Full Name] = d.fname + ' ' + d.lname;

    SELECT @AffectedDoctorsCount = COUNT(*)
    FROM v_DoctorWorkload
    WHERE [Total Surgery Hours] > @ThresholdHours;
END;

SELECT * FROM v_DoctorWorkload;
DECLARE @AffectedDoctorsCount INT;
EXEC sp_ApplyWorkloadBonus 20, @AffectedDoctorsCount OUTPUT;
PRINT @AffectedDoctorsCount;
SELECT * FROM v_DoctorWorkload;

-- Practice Question 2
CREATE VIEW v_SpecSurgeryMismatch AS
SELECT sg.sname AS 'Surgery Name', sg.slocation AS 'Surgery Location', sp.sname AS 'Specialization Name'
FROM surgery sg INNER JOIN specialization sp
ON sg.snum = sp.snumber
WHERE sg.slocation NOT IN (SELECT slocation FROM spec_locations WHERE snumber = sp.snumber);

CREATE PROCEDURE sp_SyncSpecializationLocation
    @SpecializationNumber INT,
    @NewLocation VARCHAR(15)
    AS
BEGIN
    INSERT INTO spec_locations (snumber, slocation)
    VALUES (@SpecializationNumber, @NewLocation);
END;

SELECT * FROM v_SpecSurgeryMismatch;
EXEC sp_SyncSpecializationLocation 3, 'Las Vegas';
SELECT * FROM v_SpecSurgeryMismatch;

