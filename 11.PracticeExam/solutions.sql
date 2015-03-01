-- 1

SELECT Title
FROM Ads
ORDER BY TITLE

-- 2

SELECT Title, Ads.Date
FROM Ads
WHERE Ads.Date BETWEEN '12-26-2014' AND '01-02-2015'
ORDER BY Date

-- 3

SELECT Title, 
		Date,
		CASE
			WHEN ImageDataURL IS NULL THEN 'no'
			ELSE 'yes'
		END AS [Has Image] 
FROM Ads
ORDER BY Id

-- 4

SELECT * 
FROM Ads
WHERE ImageDataURL IS NULL OR
	CategoryId IS NULL OR
	TownId IS NULL
	
-- 5 

SELECT a.Title, t.Name as [Town]
FROM Ads a
LEFT OUTER JOIN Towns t
	ON a.TownId = t.Id
ORDER BY a.Id

-- 6

SELECT a.Title, c.Name as [CategoryName], t.Name as [TownName], stat.Status
FROM Ads a
LEFT OUTER JOIN Towns t
	ON a.TownId = t.Id
LEFT OUTER JOIN Categories c
	ON c.Id = a.CategoryId
LEFT OUTER JOIN AdStatuses stat
	ON stat.Id = a.StatusId
ORDER BY a.Id

-- 7

SELECT a.Title, c.Name as [CategoryName], t.Name as [TownName], stat.Status
FROM Ads a
JOIN Towns t
	ON a.TownId = t.Id
JOIN Categories c
	ON c.Id = a.CategoryId
JOIN AdStatuses stat
	ON stat.Id = a.StatusId
WHERE stat.Status = 'Published' AND
	t.Name IN ('Sofia', 'Blagoevgrad', 'Stara Zagora')
ORDER BY a.Title


-- 8

SELECT * 
FROM (SELECT MIN(Date) as [MinDate] FROM Ads) a,
(SELECT MAX(Date) as [MaxDate] FROM Ads) b


-- 9

SELECT TOP 10 Title, Date, st.Status 
FROM Ads a
JOIN AdStatuses st
	ON a.StatusId = st.Id
ORDER BY Date DESC


-- 10

SELECT a.Id, Title, Date, st.Status 
FROM Ads a
JOIN AdStatuses st
	ON a.StatusId = st.Id
WHERE st.Status <> 'Published' AND
	YEAR(Date) = (SELECT YEAR(MIN(Date)) FROM ADS) AND
	MONTH(Date) = (SELECT MONTH(MIN(Date)) FROM ADS)
ORDER BY a.Id

-- 11

SELECT st.Status, COUNT(a.Id) as [Count]
FROM Ads a
JOIN AdStatuses st
	ON a.StatusId = st.Id
GROUP BY st.Status
ORDER BY st.Status

-- 12

SELECT t.Name as [Town Name], st.Status, COUNT(a.Id) as [Count]
FROM Ads a
JOIN AdStatuses st
	ON a.StatusId = st.Id
JOIN Towns t
	ON t.Id = a.TownId
GROUP BY st.Status, t.Name
ORDER BY t.Name, st.Status

-- 13

SELECT u.UserName, COUNT(a.Id) as [AdsCount], CASE WHEN ur.RoleId IS NOT NULL THEN 'yes'ELSE 'no' END AS [IsAdministrator]
FROM AspNetUsers u
LEFT OUTER JOIN Ads a
	ON u.Id = a.OwnerId
LEFT OUTER JOIN AspNetUserRoles ur
	ON u.Id = ur.UserId AND ur.RoleId = (SELECT Id FROM AspNetRoles WHERE Name = 'Administrator')
GROUP BY u.UserName, ur.RoleId
ORDER BY u.UserName

-- 14

SELECT COUNT(a.Id) as [AdsCount], COALESCE(t.Name, '(no town)') as Town
FROM Ads a
LEFT OUTER JOIN Towns t
	ON a.TownId = t.Id
GROUP BY t.Name
HAVING COUNT(a.Id) = 3 
	OR COUNT(a.Id) = 2
	
-- 15

CREATE TABLE #dates (
	FirstDate datetime NOT NULL,
	SecondDate datetime NOT NULL
)

DECLARE dateCursor CURSOR READ_ONLY FOR
	SELECT Date FROM Ads ORDER BY Date

OPEN dateCursor
DECLARE @date1 datetime
FETCH NEXT FROM dateCursor INTO @date1

WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE dateCursorInner CURSOR READ_ONLY FOR
			SELECT Date FROM Ads  WHERE Date > @date1 ORDER BY Date

		OPEN dateCursorInner
		DECLARE @date2 datetime
		FETCH NEXT FROM dateCursorInner INTO @date2

		WHILE @@FETCH_STATUS = 0
			BEGIN
				IF (DATEDIFF(hour, @date1 , @date2) < 12)
					BEGIN
						INSERT INTO #dates
						VALUES (@date1, @date2)	
					END

				FETCH NEXT FROM dateCursorInner INTO @date2
			END
		
		CLOSE dateCursorInner
		DEALLOCATE dateCursorInner

		FETCH NEXT FROM dateCursor INTO @date1
	END

	CLOSE dateCursor
	DEALLOCATE dateCursor


SELECT * FROM #dates
ORDER BY FirstDate, SecondDate

DROP TABLE #dates


-- 16

CREATE TABLE Countries (
	Id int IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_Countries PRIMARY KEY(Id)
)

ALTER TABLE Towns
ADD CountryId int

CREATE TABLE Countries (
	Id int IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_Countries PRIMARY KEY(Id)
)

ALTER TABLE Towns
ADD CountryId int

ALTER TABLE Towns
ADD CONSTRAINT FK_Towns_Countries FOREIGN KEY(CountryId) REFERENCES Towns(Id)


INSERT INTO Countries(Name) VALUES ('Bulgaria'), ('Germany'), ('France')
UPDATE Towns SET CountryId = (SELECT Id FROM Countries WHERE Name='Bulgaria')
INSERT INTO Towns VALUES
('Munich', (SELECT Id FROM Countries WHERE Name='Germany')),
('Frankfurt', (SELECT Id FROM Countries WHERE Name='Germany')),
('Berlin', (SELECT Id FROM Countries WHERE Name='Germany')),
('Hamburg', (SELECT Id FROM Countries WHERE Name='Germany')),
('Paris', (SELECT Id FROM Countries WHERE Name='France')),
('Lyon', (SELECT Id FROM Countries WHERE Name='France')),
('Nantes', (SELECT Id FROM Countries WHERE Name='France'))


UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Paris')
WHERE DATEPART(weekday, Date) = 6 

UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Hamburg')
WHERE DATEPART(weekday, Date) = 5

BEGIN TRAN 

SELECT a.Id
INTO #Target
FROM Ads a
JOIN AspNetUsers u
	ON u.Id = a.OwnerId
JOIN AspNetUserRoles ur
	ON ur.UserId = u.Id AND ur.RoleId = (SELECT Id FROM AspNetRoles WHERE Name = 'Partner')


DELETE Ads
Where Id IN (SELECT Id FROM #Target)

ROLLBACK

INSERT INTO Ads
VALUES ('Free Book', 'Free C# Book', NULL, (SELECT Id FROM AspNetUsers WHERE UserName = 'nakov'), NULL, NULL, GETDATE(), (SELECT Id FROM AdStatuses WHERE AdStatuses.Status = 'Waiting Approval'))

-- 17

CREATE VIEW AllAds
AS
SELECT
	a.Id,
	a.Title,
	u.UserName as Author,
	a.Date,
	t.Name as Town,
	c.Name as Category,
	st.Status
FROM
  Ads a
  LEFT OUTER JOIN Towns t ON t.Id = a.TownId
  LEFT OUTER JOIN Categories c ON c.Id = a.CategoryId
  LEFT OUTER JOIN AdStatuses st ON st.Id = a.StatusId
  LEFT OUTER JOIN AspNetUsers u ON u.Id = a.OwnerId

  SELECT * FROM AllAds
  
 
 CREATE FUNCTION fn_ListUsersAds ()
	RETURNS @UserAds table (UserName NVARCHAR(MAX), AdDates NVARCHAR(MAX))
AS
BEGIN 
	DECLARE userCursor CURSOR READ_ONLY FOR
		SELECT UserName FROM AspNetUsers

	OPEN userCursor

	DECLARE @user NVARCHAR(MAX)
	FETCH NEXT FROM userCursor INTO @user

	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE dateCursor CURSOR READ_ONLY FOR
				SELECT Author, Date FROM AllAds WHERE Author = @user ORDER BY Date

			OPEN dateCursor

			DECLARE @date datetime
			DECLARE @userCmp NVARCHAR(MAX)
			DECLARE @dateLine NVARCHAR(MAX) = ''

			FETCH NEXT FROM dateCursor INTO @userCmp, @date

			WHILE @@FETCH_STATUS = 0
				BEGIN
					IF (@user = @userCmp)
						BEGIN
							SET @dateLine = @dateLine + CONVERT(VARCHAR(MAX), @date, 112)
						END

					FETCH NEXT FROM dateCursor INTO @userCmp, @date

					IF (@@FETCH_STATUS != -1)
						BEGIN
							SET @dateLine = @dateLine + '; '
						END
				END

			IF (@dateLine = '')
				BEGIN
					INSERT INTO @UserAds
					VALUES (@user, NULL)
				END
			ELSE
				BEGIN
					INSERT INTO @UserAds
					VALUES (@user, @dateLine)
				END

			CLOSE dateCursor
			DEALLOCATE dateCursor

			FETCH NEXT FROM userCursor INTO @user
		END

	CLOSE userCursor
	DEALLOCATE userCursor

	RETURN;
END

SELECT * FROM fn_ListUsersAds()
ORDER BY UserName DESC


-- 18

SELECT name as product_name, 
	(SELECT COUNT(*) FROM order_items WHERE productId = p.Id) as num_orders, 
    COALESCE(SUM(quantity), 0) as quantity, 
    price, 
    COALESCE((price * SUM(quantity)), 0.0000) as total_price
FROM products p 
LEFT OUTER JOIN order_items oi ON p.Id = oi.productId
GROUP BY p.name
ORDER BY p.name
