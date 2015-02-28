-- 1
SELECT Title
FROM Questions
ORDER BY Title

-- 2
SELECT Content, CreatedOn
FROM Answers
WHERE CreatedOn BETWEEN '06-15-2012' AND '03-21-2013'
ORDER BY CreatedOn, Id


-- 3

SELECT Username, LastName, CASE WHEN PhoneNumber IS NULL THEN 0 ELSE 1 END AS [Has Phone]
FROM Users
ORDER BY LastName, Id

-- 4

SELECT q.Title as [Question Title], u.Username as [Author]
FROM Questions q
JOIN Users u
ON q.UserId = u.Id
ORDER BY q.Id

-- 5

SELECT a.Content as [Answer Content], a.CreatedOn, u.Username as [Answer Author], q.Title as [Question Title], c.Name as [Category Name]
FROM Answers a
JOIN Users u
	ON u.Id = a.UserId
JOIN Questions q
	ON q.Id = a.QuestionId
JOIN Categories c
	ON q.CategoryId = c.Id
ORDER BY c.Name, u.Username, a.CreatedOn

-- 6

SELECT c.Name, q.Title, q.CreatedOn
FROM Categories c
LEFT OUTER JOIN Questions q
	ON q.CategoryId = c.Id
ORDER BY c.Name, q.Title

-- 7

SELECT Id, Username, FirstName, PhoneNumber, RegistrationDate, Email
FROM Users u
WHERE (u.PhoneNumber IS NULL)
	AND (u.Id NOT IN (SELECT u.Id FROM Questions q JOIN Users u ON q.UserId = u.Id))
ORDER BY u.RegistrationDate

-- 8 

SELECT * 
FROM (SELECT MIN(CreatedOn) as MinDate
FROM Answers a
WHERE a.CreatedOn BETWEEN '2012-01-01' AND '2012-12-31') q, (SELECT MAX(CreatedOn) as MaxDate
FROM Answers a
WHERE a.CreatedOn BETWEEN '2014-01-01' AND '2014-12-31') r

-- 9

SELECT TOP 10 a.Content, a.CreatedOn, u.Username
FROM Answers a
JOIN Users u
	ON u.Id = a.UserId
ORDER BY a.CreatedOn

-- 10

SELECT a.Content as [Answer Content], q.Title as [Question], c.Name as [Category]
FROM Answers a
JOIN Questions q
	ON a.QuestionId = q.Id
JOIN Categories c
	ON c.Id = q.CategoryId
WHERE a.IsHidden = 1 AND
	  YEAR(a.CreatedOn) = (SELECT MAX(YEAR(CreatedOn)) FROM Answers) AND
	  (MONTH(a.CreatedOn) = (SELECT MAX(MONTH(CreatedOn)) FROM Answers) OR MONTH(a.CreatedOn) = (SELECT MIN(MONTH(CreatedOn)) FROM Answers))
ORDER BY c.Name

-- 11

SELECT c.Name as [Category], COUNT(a.Id) as [Answers Count]
FROM Answers a
FULL OUTER JOIN Questions q
	ON q.Id = a.QuestionId
FULL OUTER JOIN Categories c
	ON c.Id = q.CategoryId
GROUP BY c.Name
ORDER BY [Answers Count] DESC

-- 12

SELECT c.Name as [Category], u.Username, u.PhoneNumber, COUNT(a.Id) as [Answers Count] 
FROM Answers a
JOIN Users u
	ON u.Id = a.UserId
JOIN Questions q
	ON q.Id = a.QuestionId
JOIN Categories c
	ON q.CategoryId = c.Id
WHERE u.PhoneNumber IS NOT NULL
GROUP BY c.Name, u.Username, u.PhoneNumber
ORDER BY [Answers Count] DESC


-- 13 

CREATE TABLE Towns (
	Id int IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_Towns PRIMARY KEY(Id)
)


ALTER TABLE Users
ADD TownId int

ALTER TABLE Users
ADD CONSTRAINT FK_Users_Towns FOREIGN KEY(TownId) REFERENCES Towns(Id)

UPDATE Users 
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Paris')
WHERE datename(dw, RegistrationDate) = 'Friday'

UPDATE Answers
SET QuestionId = (SELECT Id FROM Questions q WHERE q.Title = 'Java += operator')
WHERE (DATEPART(weekday ,CreatedOn) = 1 OR DATEPART(weekday ,CreatedOn) = 2) AND
		(MONTH(CreatedOn) = 2)
		
BEGIN TRAN

SELECT Id
INTO #Target
FROM Answers a
WHERE (SELECT SUM(Value) FROM Votes v JOIN Answers aa ON aa.Id = v.AnswerId WHERE aa.Id = a.Id) < 0

DELETE Votes
WHERE AnswerId IN (SELECT Id FROM #Target)


DELETE Answers
WHERE Id IN (SELECT Id FROM #Target)

DROP TABLE #Target

COMMIT


INSERT INTO Questions
VALUES ('Fetch NULL values in PDO query', 
	'When I run the snippet, NULL values are converted to empty strings. How can fetch NULL values?',
	 (SELECT Id FROM Categories WHERE Name = 'Databases'),
	 (SELECT Id FROM Users WHERE Username = 'darkcat'),
	 GETDATE())

SELECT t.Name as [Town], u.Username, COUNT(a.Id) as AnswersCount
FROM Users u
FULL OUTER JOIN Towns t
	ON u.TownId = t.Id
FULL OUTER JOIN Answers a
	ON a.UserId = u.Id
GROUP BY t.Name, u.Username
ORDER BY [AnswersCount] DESC, u.Username

-- 14

CREATE VIEW [AllQuestions] AS
SELECT 
	u.Id as UId,
	u.Username,
	u.FirstName,
	u.LastName,
	u.Email,
	u.PhoneNumber,
	u.RegistrationDate,
	q.Id as QId,
	q.Title,
	q.Content,
	q.CategoryId,
	q.UserId,
	q.CreatedOn
FROM Questions q
RIGHT OUTER JOIN Users u
	ON q.UserId = u.Id


SELECT * FROM AllQuestions

--

CREATE FUNCTION ufn_ListUsersQuestions() 
	RETURNS @UserQuestions table (UserName NVARCHAR(MAX), Questions NVARCHAR(MAX))
AS
BEGIN
	DECLARE userCursor CURSOR READ_ONLY FOR
		SELECT DISTINCT Username FROM AllQuestions ORDER BY Username
	
	OPEN userCursor
	DECLARE @username NVARCHAR(MAX)
	FETCH NEXT FROM userCursor INTO @username

	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE questionCursor CURSOR READ_ONLY FOR
				SELECT Title FROM AllQuestions WHERE Username = @username ORDER BY Title DESC

			OPEN questionCursor
			DECLARE @question NVARCHAR(MAX)
			DECLARE @questionList NVARCHAR(MAX) = ''
			FETCH NEXT FROM questionCursor INTO @question

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @questionList = @questionList + @question
					FETCH NEXT FROM questionCursor INTO @question
					IF (@@FETCH_STATUS != -1)
						BEGIN
							SET @questionList = @questionList + ', '
						END
				END

			INSERT INTO @UserQuestions
			VALUES (@username, @questionList)

			CLOSE questionCursor
			DEALLOCATE questionCursor

			FETCH NEXT FROM userCursor INTO @userName
		END

	CLOSE userCursor
	DEALLOCATE userCursor
	RETURN;
END
GO


SELECT * FROM ufn_ListUsersQuestions()
