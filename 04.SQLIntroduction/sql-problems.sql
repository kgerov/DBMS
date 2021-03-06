-- Problem 4.	Write a SQL query to find all information about all departments.

SELECT d.DepartmentID, d.Name, FirstName + LastName as [Manager] FROM Departments d
JOIN Employees e
ON d.ManagerID = e.ManagerID

-- Problem 5. Write a SQL query to find all department names.

SELECT Name FROM Departments

-- Problem 6. Write a SQL query to find the salary of each employee.

SELECT FirstName + ' ' + COALESCE(MiddleName, '') + ' ' + LastName as [Full Name], Salary FROM Employees

-- Problem 7. Write a SQL to find the full name of each employee. 

SELECT FirstName + ' ' + LastName as [Full Name] FROM Employees

-- Problem 8. Write a SQL query to find the email addresses of each employee.

SELECT FirstName + ' ' + LastName as [Full Name], FirstName + '.' + LastName + '@softuni.bg' as [Full Email Addresses] FROM Employees

-- Problem 9.	Write a SQL query to find all different employee salaries.

SELECT DISTINCT Salary FROM Employees

-- Problem 10. Write a SQL query to find all information about the employees whose job title is “Sales Representative“.

SELECT * FROM Employees
WHERE JobTitle = 'Sales Representative'


-- Problem 11.	Write a SQL query to find the names of all employees whose first name starts with "SA".

SELECT FirstName + '' + LastName AS [Full Name] FROM Employees
WHERE FirstName LIKE 'SA%'


-- Problem 12. Write a SQL query to find the names of all employees whose last name contains "ei".

SELECT FirstName + '' + LastName AS [Full Name] FROM Employees
WHERE LastName LIKE '%ei%'


-- Problem 13. Write a SQL query to find the salary of all employees whose salary is in the range [20000…30000].

SELECT FirstName + '' + LastName AS [Full Name], Salary FROM Employees
WHERE Salary BETWEEN 20000 AND 30000


-- Problem 14.	Write a SQL query to find the names of all employees whose salary is 25000, 14000, 12500 or 23600.

SELECT FirstName + '' + LastName AS [Full Name], Salary FROM Employees
WHERE Salary = 25000 OR Salary = 14000 OR Salary = 12500  OR Salary = 23600 
ORDER BY Salary

SELECT FirstName + '' + LastName AS [Full Name], Salary FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600)
ORDER BY Salary

-- Problem 15. Write a SQL query to find all employees that do not have manager.

SELECT * FROM Employees
WHERE ManagerID IS NULL

-- Problem 16. Write a SQL query to find all employees that have salary more than 50000. Order them in decreasing order by salary.

SELECT * FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC

-- Problem 17. Write a SQL query to find the top 5 best paid employees.

SELECT TOP 5 * FROM Employees
ORDER BY Salary DESC

-- Problem 18.	Write a SQL query to find all employees along with their address.

SELECT FirstName + ' ' + LastName AS [FULL NAME], a.AddressText, t.Name 
FROM Employees e
JOIN Addresses a
	ON a.AddressID = e.AddressID
JOIN Towns t
	ON t.TownID = a.TownID

-- Problem 19.	Write a SQL query to find all employees and their address.

SELECT FirstName + ' ' + LastName AS [FULL NAME], a.AddressText, t.Name 
FROM Employees e, Addresses a, Towns t 
WHERE a.AddressID = e.AddressID AND t.TownID = a.TownID

-- Problem 20.	Write a SQL query to find all employees along with their manager.

SELECT e.FirstName + ' ' + e.LastName AS [Employee Name], m.EmployeeID AS [Manager Employee ID], m.FirstName + ' ' + m.LastName AS [Manager Name]
FROM Employees e
LEFT OUTER JOIN Employees m
	ON m.EmployeeID = e.ManagerID 

-- Problem 21. Write a SQL query to find all employees, along with their manager and their address.

SELECT e.FirstName + ' ' + e.LastName AS [Employee Name], a.AddressText, t.Name AS [Town Name],
	m.EmployeeID AS [Manager Employee ID], m.FirstName + ' ' + m.LastName AS [Manager Name]
FROM Employees e
JOIN Addresses a
	ON e.AddressID = a.AddressID
JOIN Towns t
	ON a.TownID = t.TownID
LEFT OUTER JOIN Employees m
	ON m.EmployeeID = e.ManagerID
ORDER BY [Manager Employee ID]

-- Problem 22. Write a SQL query to find all departments and all town names as a single list.

SELECT Name
FROM Departments
UNION
SELECT Name
FROM Towns


-- Problem 23. Write a SQL query to find all the employees and the manager for each of them along with 
-- the employees that do not have manager. 

SELECT e.FirstName + ' ' + e.LastName as [Employee Full Name],
	m.EmployeeID as [Manager Employee ID],
	m.FirstName + ' ' + m.LastName as [Manager Full Name]
FROM Employees e
RIGHT OUTER JOIN Employees m
	ON e.ManagerID = m.EmployeeID
	
SELECT e.FirstName + ' ' + e.LastName as [Employee Full Name],
	m.EmployeeID as [Manager Employee ID],
	m.FirstName + ' ' + m.LastName as [Manager Full Name]
FROM Employees e
LEFT OUTER JOIN Employees m
	ON e.ManagerID = m.EmployeeID

-- Problem 24. Write a SQL query to find the names of all employees from the departments "Sales" and "Finance" 
-- whose hire year is between 1995 and 2005.

SELECT e.FirstName + ' ' + e.LastName as [Employee Full Name], d.Name AS [Department Name], e.HireDate
FROM Employees e
JOIN Departments d
	ON (e.DepartmentID = d.DepartmentID
	AND e.HireDate >= '1/1/1995'
	AND e.HireDate <= '12/31/2005')
WHERE d.Name in ('Sales', 'Finance')