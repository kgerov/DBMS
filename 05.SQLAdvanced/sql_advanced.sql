-- Problem 1.   Write a SQL query to find the names and salaries of the employees that take the minimal salary in the company.

SELECT FirstName, LastName, Salary 
FROM Employees
WHERE Salary = (SELECT MIN(Salary) FROM Employees)
 
-- Problem 2.   Write a SQL query to find the names and salaries of the employees that have a salary that is up to 10% higher than the minimal salary for the company.

SELECT FirstName, LastName, Salary 
FROM Employees
WHERE Salary <= (SELECT MIN(Salary) FROM Employees) * 1.1
ORDER  BY Salary DESC
 
-- Problem 3.   Write a SQL query to find the full name, salary and department of the employees that take the minimal salary in their department.

SELECT e.FirstName, e.LastName, e.Salary, d.Name
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = (SELECT MIN(Salary) FROM Employees
				WHERE DepartmentID = d.DepartmentID)

 
-- Problem 4.   Write a SQL query to find the average salary in the department #1.

SELECT AVG(Salary) AS [Average Salary]
FROM Employees
WHERE DepartmentID = 1
 
 
-- Problem 5.   Write a SQL query to find the average salary in the "Sales" department.

SELECT AVG(e.Salary) AS [Average Salary in Sales Department]
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'

 
-- Problem 6.   Write a SQL query to find the number of employees in the "Sales" department.

SELECT COUNT(e.EmployeeID) AS [Number of Employees in Sales]
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
 
 
-- Problem 7.   Write a SQL query to find the number of all employees that have manager.

SELECT COUNT(EmployeeID) AS [Employees with a Manager]
FROM Employees
WHERE ManagerID IS NOT NULL
 
-- Problem 8.   Write a SQL query to find the number of all employees that have no manager.
 
 SELECT COUNT(EmployeeID) AS [Employees without a Manager]
FROM Employees
WHERE ManagerID IS NULL
 
-- Problem 9.   Write a SQL query to find all departments and the average salary for each of them.

SELECT d.Name AS [Department], AVG(e.Salary) AS [Average Salary]
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name
 
-- Problem 10.  Write a SQL query to find the count of all employees in each department and for each town.
 
SELECT t.Name AS [Town], d.Name AS [Department], COUNT(e.EmployeeID)
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
JOIN Addresses a
	ON e.AddressID = a.AddressID
	JOIN Towns t
		ON t.TownID = a.TownID
GROUP BY t.Name, d.Name

-- Problem 11.  Write a SQL query to find all managers that have exactly 5 employees.

SELECT m.EmployeeID, m.FirstName, m.LastName, COUNT(e.EmployeeID)
FROM Employees e
JOIN Employees m
	ON e.ManagerID = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) = 5
 
-- Problem 12.  Write a SQL query to find all employees along with their managers.

SELECT e.FirstName + ' ' + e.LastName AS [Employee Name], COALESCE(m.FirstName + ' ' + m.LastName, 'No Manager') AS [Manager Name]
FROM Employees e
LEFT OUTER JOIN Employees m
	ON e.ManagerID = m.EmployeeID

 
-- Problem 13.  Write a SQL query to find the names of all employees whose last name is exactly 5 characters long.

SELECT e.FirstName, e.LastName
FROM Employees e
WHERE LEN(e.LastName) = 5 
 
--Problem 14.   Write a SQL query to display the current date and time in the following format "day.month.year hour:minutes:seconds:milliseconds".
 
SELECT CONVERT(nvarchar, GETDATE(), 4) + ' ' + CONVERT(nvarchar, GETDATE(), 114)
 
-- Problem 15.  Write a SQL statement to create a table Users.

CREATE TABLE Users (
	UserId int IDENTITY,
	Username nvarchar(50) NOT NULL UNIQUE,
	Password nvarchar(50) NOT NULL CHECK (LEN(Password) >= 5),
	FullName nvarchar(100) NOT NULL,
	LastLoginTime int,
	CONSTRAINT PK_Users PRIMARY KEY(UserId)
)

-- Problem 16.  Write a SQL statement to create a view that displays the users from the Users table that have been in the system today.

CREATE VIEW [GetUsers] AS
SELECT TOP 10 FullName FROM Users

GO

SELECT * FROM [GetUsers]
 
-- Problem 17.  Write a SQL statement to create a table Groups.

CREATE TABLE Groups (
	GroupId int IDENTITY,
	Name nvarchar(50) UNIQUE NOT NULL,
	CONSTRAINT PK_Groups PRIMARY KEY(GroupId)
)


 
-- Problem 18.  Write a SQL statement to add a column GroupID to the table Users.

ALTER TABLE Users
ADD GroupId int

GO

ALTER TABLE Users
ADD CONSTRAINT FK_Users_Groups
	FOREIGN KEY (GroupId)
	REFERENCES Groups(GroupId)

-- Problem 19.  Write SQL statements to insert several records in the Users and Groups tables.

INSERT INTO Groups (Name)
VALUES ('Brah1')


INSERT INTO Groups
VALUES ('NqkavaGrupa1')

INSERT INTO Users (Username, Password, FullName, LastLoginTime, GroupId)
VALUES ('kateto', 'parolata', 'KatetoBe', '2014', 1)


INSERT INTO Users (Username, Password, FullName, LastLoginTime, GroupId)
VALUES ('vaseto', 'parolata123', 'VasetoBe', '2014', 2)
 
-- Problem 20.  Write SQL statements to update some of the records in the Users and Groups tables.

UPDATE Groups
SET Name = 'Qka'
WHERE Name = 'Qkata'


UPDATE Users
SET Username = 'katenceto', Password = 'muysecret'
WHERE UserId = 5
 
-- Problem 21.  Write SQL statements to delete some of the records from the Users and Groups tables.

DELETE FROM Groups
WHERE GroupId = 8

DELETE FROM Users
WHERE UserId = 1
 
-- Problem 22.  Write SQL statements to insert in the Users table the names of all employees from the Employees table.

INSERT INTO Users (Username, Password, FullName, LastLoginTime, GroupId)
SELECT
	CASE 
		WHEN(SELECT COUNT(LastName) 
			 FROM Employees m
			 WHERE e.LastName = m.LastName) > 1 THEN CONVERT(varchar(50), NEWID())
		ELSE SUBSTRING(FirstName, 1, 1) + LOWER(LastName)
	END,
	LOWER(SUBSTRING(FirstName, 1, 1)) + LOWER(LastName),
	FirstName + ' ' + LastName, 
	NULL, 
	1
FROM Employees e
GROUP BY FirstName, LastName

-- Problem 23.  Write a SQL statement that changes the password to NULL for all users that have not been in the system since 10.03.2010.

UPDATE Users
SET Password = NULL
WHERE LastLoginTime < '2013-10-03'
 
-- Problem 24.  Write a SQL statement that deletes all users without passwords (NULL password).

DELETE Users
WHERE PASSWORD IS NULL
 
-- Problem 25.  Write a SQL query to display the average employee salary by department and job title.

SELECT d.Name, e.JobTitle, AVG(Salary) as [Average Salary]
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name, e.JobTitle
ORDER BY d.Name

-- Problem 26.  Write a SQL query to display the minimal employee salary by department and job title along with the name of some of the employees that take it.
 
SELECT d.Name, e.JobTitle, e.FirstName, e.Salary
FROM Employees e
JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = (SELECT MIN(Salary) FROM Employees m WHERE m.DepartmentID = e.DepartmentID)
GROUP BY d.Name, e.JobTitle, e.FirstName, e.Salary
ORDER BY d.Name
 
-- Problem 27.  Write a SQL query to display the town where maximal number of employees work.

SELECT TOP 1 t.Name, COUNT(EmployeeID) AS [Number Of Employees]
FROM Employees e
JOIN Addresses a
	ON e.AddressID = a.AddressID
JOIN Towns t
	ON a.TownID = t.TownID
GROUP BY t.TownID, t.Name
ORDER BY [Number Of Employees] DESC
 
-- Problem 28.  Write a SQL query to display the number of managers from each town.

SELECT gt.Name, COUNT(*) AS [Number Of Managers]
FROM 
(SELECT e.FirstName, e.LastName, t.Name
FROM Employees e
JOIN Addresses a
	ON e.AddressID = a.AddressID
JOIN Towns t
	ON a.TownID = t.TownID
WHERE e.EmployeeID IN (SELECT ManagerID From Employees)) as gt
GROUP BY gt.Name
ORDER BY gt.Name
 
-- Problem 29.  Write a SQL to create table WorkHours to store work reports for each employee.

CREATE TABLE WorkHours (
	Id int IDENTITY NOT NULL,
	EmployeeId int NOT NULL,
	WorkDate datetime,
	Tasks nvarchar(255) NOT NULL,
	Hours int NOT NULL,
	Comments ntext,
	CONSTRAINT PK_WorkHours PRIMARY KEY(Id),
	CONSTRAINT FK_WorkHours_Employees FOREIGN KEY(EmployeeId) REFERENCES Employees(EmployeeId)
)
 
-- Problem 30.  Issue few SQL statements to insert, update and delete of some data in the table.

INSERT INTO WorkHours (EmployeeId, WorkDate, Tasks, Hours, Comments)
VALUES (1, GETDATE(), 'Ébasi kakva zadacha', 12, 'Perfectoooo!')

INSERT INTO WorkHours (EmployeeId, WorkDate, Tasks, Hours, Comments)
VALUES (2, GETDATE(), 'Muy Work to do', 32, 'Very job done')

UPDATE WorkHours
SET Comments = 'Perfect job done'
WHERE Id = 1

DELETE WorkHours
WHERE Id = 1

 
-- Problem 31.  Define a table WorkHoursLogs to track all changes in the WorkHours table with triggers.

CREATE TABLE WorkHoursLogs (
	Id int IDENTITY NOT NULL,
	OldId int NOT NULL,
	NewId int NOT NULL,
	Command nvarchar(25) NOT NULL,
	CONSTRAINT PK_WorkHoursLogs PRIMARY KEY(Id),
	CONSTRAINT FK_Old_WorkHoursLogs_WorkHours FOREIGN KEY(OldId) REFERENCES WorkHours(Id),
	CONSTRAINT FK_New_WorkHoursLogs_WorkHours FOREIGN KEY(NewId) REFERENCES WorkHours(Id)
)

CREATE TRIGGER tr_LogChangesWorkHours ON WorkHours
  FOR INSERT, UPDATE, DELETE AS
BEGIN

  -- Detect inserts
  IF EXISTS (select * from inserted) AND NOT EXISTS (select * from deleted)
  BEGIN
    INSERT INTO WorkHoursLogs (OldId, NewId, Command)
    VALUES ((SELECT Id FROM deleted), (SELECT Id FROM inserted), 'INSERT')
    RETURN;
  END

  -- Detect deletes
  IF EXISTS (select * from deleted) AND NOT EXISTS (select * from inserted)
  BEGIN
    INSERT INTO WorkHoursLogs (OldId, NewId, Command)
    VALUES ((SELECT Id FROM deleted), NULL, 'DELETE')
    RETURN;
  END

  -- Update inserts
  IF EXISTS (select * from inserted) AND EXISTS (select * from deleted)
  BEGIN
	INSERT INTO WorkHoursLogs (OldId, NewId, Command)
    VALUES ((SELECT Id FROM deleted), (SELECT Id FROM inserted), 'UPDATED')
    RETURN;
  END

END;

 
-- Problem 32.  Start a database transaction, delete all employees from the 'Sales' department along with all dependent records from the pother tables. At the end rollback the transaction.

BEGIN TRAN
	ALTER TABLE Departments
	DROP CONSTRAINT FK_Departments_Employees

	DELETE FROM Employees
	WHERE DepartmentID = 3
ROLLBACK TRAN
 
-- Problem 33.  Start a database transaction and drop the table EmployeesProjects.

BEGIN TRAN
DROP TABLE EmployeesProjects;
ROLLBACK TRAN

-- Problem 34.  Find how to use temporary tables in SQL Server.

SELECT *
INTO #EmpProjects
FROM EmployeesProjects

DROP TABLE EmployeesProjects

CREATE TABLE EmployeesProjects (
	EmployeeId int NOT NULL,
	ProjectId int NOT NULL,
	CONSTRAINT FK_Employees FOREIGN KEY(EmployeeId) REFERENCES Employees(EmployeeId),
	CONSTRAINT FK_Projects FOREIGN KEY(ProjectId) REFERENCES Projects(ProjectId)
)

INSERT INTO EmployeesProjects
SELECT * FROM #EmpProjects
