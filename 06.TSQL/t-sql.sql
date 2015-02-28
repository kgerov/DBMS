-- Problem 1.	Create a database with two tables
CREATE TABLE Persons (
	PersonId int IDENTITY NOT NULL,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,
	SSN nvarchar(150),
	CONSTRAINT PK_Persons PRIMARY KEY(PersonId)
)

GO

CREATE TABLE Accounts (
	AccountId int IDENTITY NOT NULL,
	PersonId int NOT NULL,
	BALANCE money NOT NULL,
	CONSTRAINT PK_Accounts PRIMARY KEY(AccountId),
	CONSTRAINT FK_Accounts_Persons FOREIGN KEY(PersonId) REFERENCES Persons(PersonId)
)

GO

USE Test
GO

CREATE PROC dbo.usp_SelectFullNames
AS
	SELECT FirstName + ' ' + LastName AS [Full Name]
	FROM Persons
GO

EXEC usp_SelectFullNames

-- Problem 2.	Create a stored procedure

USE Test
GO

CREATE PROC usp_SelectAboveBalance (@bottomBalance int = 0)
AS
	SELECT FirstName + ' ' + LastName
	FROM Persons p
	JOIN Accounts a
		on p.PersonId = a.PersonId
	WHERE a.Balance >= @bottomBalance

GO
	
EXEC usp_SelectAboveBalance 10000

-- Problem 3.	Create a function with parameters

CREATE FUNCTION ufn_CalcSum(@sum money, @intRateYear float, @numMonths int) RETURNS money
AS
BEGIN
	DECLARE @intRateMonth money = @intRateYear / 12
	RETURN @sum * (1 + (@numMonths * @intRateMonth/100))
END

SELECT FirstName, LastName, dbo.ufn_CalcSum(a.Balance, 12, 24) as [Future Value]
FROM Persons p
JOIN Accounts a
	ON p.PersonId = a.AccountId

-- Problem 4.	Create a stored procedure that uses the function from the previous example.

USE Test
GO

CREATE PROC dbo.usp_GetSumForUser (@AccountId int, @intRate float)
AS
	SELECT FirstName, LastName, dbo.ufn_CalcSum(a.Balance, @intRate, 1) as [Future Value]
	FROM Persons p
	JOIN Accounts a
		ON p.PersonId = a.AccountId
	WHERE a.AccountId = @AccountId
	
EXEC usp_GetSumForUser 1, 12

-- Problem 5.	Add two more stored procedures WithdrawMoney and DepositMoney.

USE Test
GO 

CREATE PROC dbo.usp_WithdrawMoney (@AccountId int, @Amount money)
AS
	BEGIN TRAN
		IF (@Amount < 0)
			BEGIN
				RAISERROR('Amount must be positive', 16, 1)
				ROLLBACK
			END

		DECLARE @updatedBalance int = (SELECT Balance FROM Accounts WHERE AccountId = @AccountId) - @Amount
		IF (@updatedBalance >= 0)
			BEGIN
				UPDATE Accounts
				SET Balance = @updatedBalance
				WHERE AccountId = @AccountId
				COMMIT
			END
		ELSE
			BEGIN
				RAISERROR('Not enough money', 16, 1)
				ROLLBACK
			END

GO 

CREATE PROC dbo.usp_DepositMoney (@AccountId int, @Amount money)
AS
	BEGIN TRAN
		IF (@Amount < 0)
			BEGIN
				RAISERROR('Amount must be positive', 16, 1)
				ROLLBACK
			END

		DECLARE @updatedBalance int = (SELECT Balance FROM Accounts WHERE AccountId = @AccountId) + @Amount
		UPDATE Accounts
		SET Balance = @updatedBalance
		WHERE AccountId = @AccountId
		COMMIT

-- Problem 6.	Create table Logs.

CREATE TABLE Logs  (
	LogId int IDENTITY NOT NULL,
	AccountId int NOT NULL,
	OldSum money NOT NULL,
	NewSum money NOT NULL,
	CONSTRAINT PK_Logs PRIMARY KEY(LogId),
	CONSTRAINT FK_Logs_Accounts FOREIGN KEY(AccountId) REFERENCES Accounts(AccountId)
)

GO

CREATE TRIGGER tr_LogAccounts ON Accounts
  FOR UPDATE AS
BEGIN
    INSERT INTO Logs (AccountId, OldSum, NewSum)
    VALUES ((SELECT AccountId FROM deleted), (SELECT Balance FROM deleted), (SELECT Balance FROM inserted))
    RETURN;
END

-- Problem 7.	Define function in the SoftUni database.

CREATE FUNCTION ufn_WordComparator (@word nvarchar(150), @letters nvarchar(150))
RETURNS bit
AS
	BEGIN
		SET @word = LOWER(@word)
		SET @letters = LOWER(@letters)
		DECLARE @wordLen int = LEN(@word)
		DECLARE @iter int = 1
		WHILE (@iter <= @wordLen)
			BEGIN
				IF(CHARINDEX(SUBSTRING(@word, @iter, 1), @letters) = 0)
					RETURN 0
				SET @iter = @iter+1
			END
		
		RETURN 1
	END
GO

CREATE FUNCTION ufn_FindSubstrings (@letters nvarchar(150))
RETURNS TABLE
AS
	RETURN(
		SELECT Word FROM (SELECT FirstName + COALESCE(MiddleName, '') + LastName AS Word FROM Employees
		UNION
		SELECT Name AS Word FROM Towns) a
			WHERE dbo.ufn_WordComparator(Word, @letters) = 1)




SELECT * FROM dbo.ufn_FindSubstrings('oistmiahf')


-- Problem 8.	Using database cursor write a T-SQL

DECLARE townCursor CURSOR READ_ONLY FOR
  SELECT Name FROM Towns ORDER BY TownID

OPEN townCursor
DECLARE @firstName char(50), @lastName char(50)
DECLARE @cmpfirstName char(50), @cmplastName char(50)
DECLARE @townName char(50)
FETCH NEXT FROM townCursor INTO @townName

WHILE @@FETCH_STATUS = 0
  BEGIN
	DECLARE empCursor CURSOR READ_ONLY FOR
		SELECT FirstName, LastName FROM Employees e JOIN Addresses a ON e.AddressID = a.AddressID JOIN Towns t ON t.TownID = a.TownID WHERE t.Name = @townName

	OPEN empCursor
	FETCH NEXT FROM empCursor INTO @cmpfirstName, @cmplastName
	FETCH NEXT FROM empCursor INTO @firstName, @lastName

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @townName + ': ' + @cmpfirstName + ' ' + @cmplastName + ' | ' + @firstName + ' ' + @lastName
			FETCH NEXT FROM empCursor INTO @firstName, @lastName
		END

	CLOSE empCursor
	DEALLOCATE empCursor

    FETCH NEXT FROM townCursor 
    INTO @townName
  END

CLOSE townCursor
DEALLOCATE townCursor



-- Problem 9.	Define a .NET aggregate function

-- Write a T-SQL script

DECLARE townCursor CURSOR READ_ONLY FOR
  SELECT Name FROM Towns ORDER BY TownID

OPEN townCursor
DECLARE @firstName char(50), @lastName char(50)
DECLARE @townName char(50)
DECLARE @line NVARCHAR(MAX)
FETCH NEXT FROM townCursor INTO @townName

WHILE @@FETCH_STATUS = 0
  BEGIN
	SET @line = @townName + ' -> '
	DECLARE empCursor CURSOR READ_ONLY FOR
		SELECT FirstName, LastName FROM Employees e JOIN Addresses a ON e.AddressID = a.AddressID JOIN Towns t ON t.TownID = a.TownID WHERE t.Name = @townName

	OPEN empCursor
	FETCH NEXT FROM empCursor INTO @firstName, @lastName
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET  @line = @line + @firstName + ' ' + @lastName
			FETCH NEXT FROM empCursor INTO @firstName, @lastName
			IF (@@FETCH_STATUS != -1)
			  BEGIN
				SET @line = @line + ', '
			  END
		END

	PRINT @line
	CLOSE empCursor
	DEALLOCATE empCursor

    FETCH NEXT FROM townCursor 
    INTO @townName
  END

CLOSE townCursor
DEALLOCATE townCursor
