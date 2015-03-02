-- 1

SELECT p.PeakName
FROM Peaks p
ORDER BY p.PeakName

--2 

SELECT TOP 30 c.CountryName, c.Population
FROM Countries c
JOIN Continents co
	ON co.ContinentCode = c.ContinentCode
WHERE co.ContinentName = 'Europe'
ORDER BY c.Population DESC

-- 3

SELECT c.CountryName, 
	c.CountryCode, 
	(CASE 
		WHEN c.CurrencyCode = 'EUR'
		THEN 'Euro'
		ELSE 'Not Euro'
	END) AS Currency
FROM Countries c
ORDER BY c.CountryName

-- 4

SELECT CountryName as [Country Name], IsoCode as [ISO Code]
FROM Countries c
WHERE (SELECT (len(UPPER(c.CountryName)) - len(replace(UPPER(c.CountryName), 'A',''))) / LEN('A')) >= 3
ORDER BY IsoCode

-- 5

SELECT p.PeakName, m.MountainRange as Mountain, p.Elevation
FROM Peaks p
LEFT OUTER JOIN Mountains m
	ON p.MountainId = m.Id
ORDER BY p.Elevation DESC

-- 6

SELECT p.PeakName, m.MountainRange as [Mountain], CountryName, ContinentName 
FROM Peaks p
JOIN Mountains m
	ON p.MountainId = m.Id
JOIN (
	SELECT MountainId, CountryName, ContinentName 
	FROM MountainsCountries mc
	JOIN Countries c ON c.CountryCode = mc.CountryCode
	JOIN Continents co ON c.ContinentCode = co.ContinentCode) cou
	ON cou.MountainId = m.Id
ORDER BY p.PeakName, CountryName

-- 7

SELECT RiverName as River, COUNT(r.Id) as [Countries Count]
FROM Rivers r
LEFT OUTER JOIN (
	SELECT RiverId, CountryName 
	FROM CountriesRivers cr
	JOIN Countries c ON c.CountryCode = cr.CountryCode) rc
	ON rc.RiverId = r.Id
GROUP BY RiverName
HAVING COUNT(r.Id) >= 3
ORDER BY RiverName

-- 8

SELECT *
FROM (SELECT MAX(Elevation) as [MaxElevation] FROM Peaks) a, 
	(SELECT MIN(Elevation) as [MinElevation] FROM Peaks) b,
	(SELECT AVG(Elevation) as [AverageElevation] FROM Peaks) c

	
-- 9

SELECT CountryName, ContinentName, COUNT(RiverName) as [RiversCount], COALESCE(SUM(Length), 0) as [TotalLength]
FROM Countries c
LEFT OUTER JOIN (
	SELECT CountryCode, RiverName, Length
	FROM CountriesRivers cr
	JOIN Rivers r ON cr.RiverId = r.Id) rc
	ON rc.CountryCode = c.CountryCode
LEFT OUTER JOIN Continents co
	ON co.ContinentCode = c.ContinentCode
GROUP BY CountryName, ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, CountryName

-- 10

SELECT cu.CurrencyCode, Description as [Currency], COUNT(co.CountryName) as [NumberOfCountries]
FROM Currencies cu
LEFT OUTER JOIN Countries co
	ON cu.CurrencyCode = co.CurrencyCode
GROUP BY cu.CurrencyCode, Description
ORDER BY NumberOfCountries DESC, Description 

-- 11

SELECT co.ContinentName, SUM(CAST(AreaInSqKm AS BIGINT)) as CountriesArea, SUM(CAST(Population AS BIGINT)) as CountriesPopulation
FROM Continents co
LEFT OUTER JOIN Countries c
	ON co.ContinentCode = c.ContinentCode
GROUP BY co.ContinentName
ORDER BY CountriesPopulation DESC

-- 12 

SELECT c.CountryName, MAX(Elevation) as [HighestPeakElevation], MAX(RiverLength) as [LongestRiverLength]
FROM Countries c
LEFT OUTER JOIN (
	SELECT CountryCode, Length as [RiverLength]
	FROM CountriesRivers cr
	JOIN Rivers r ON cr.RiverId = r.Id) rc
	ON rc.CountryCode = c.CountryCode
LEFT OUTER JOIN (
	SELECT CountryCode, Elevation 
	FROM MountainsCountries mc
	JOIN Mountains m ON m.Id = mc.MountainId
	LEFT OUTER JOIN Peaks p ON p.MountainId = m.Id) mp
	ON c.CountryCode = mp.CountryCode
GROUP BY CountryName
ORDER BY [HighestPeakElevation] DESC, [LongestRiverLength] DESC, c.CountryName

-- 13

CREATE TABLE #PeaksRivers (
	PeakName NVARCHAR(MAX) NOT NULL,
	RiverName NVARCHAR(MAX) NOT NULL,
	Mix NVARCHAR(MAX) NOT NULL
)

DECLARE peakCursor CURSOR READ_ONLY FOR
	SELECT PeakName FROM Peaks ORDER BY PeakName

OPEN peakCursor
DECLARE @peak NVARCHAR(MAX)
FETCH NEXT FROM peakCursor INTO @peak

WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE riverCursor CURSOR READ_ONLY FOR
			SELECT RiverName FROM Rivers ORDER BY RiverName

			OPEN riverCursor
			DECLARE @river NVARCHAR(MAX)
			FETCH NEXT FROM riverCursor INTO @river

			WHILE @@FETCH_STATUS = 0
				BEGIN 
					IF (SUBSTRING(LOWER(@river), 1, 1) = SUBSTRING(LOWER(@peak), LEN(@peak), 1))
						BEGIN
							INSERT INTO #PeaksRivers
							VALUES (@peak, @river, (LOWER(@peak) + LOWER(SUBSTRING(@river, 2, LEN(@river) - 1))))
						END

					FETCH NEXT FROM riverCursor INTO @river
				END

			CLOSE riverCursor
			DEALLOCATE riverCursor

			FETCH NEXT FROM peakCursor INTO @peak
	END

CLOSE peakCursor
DEALLOCATE peakCursor


SELECT * FROM #PeaksRivers

-- 14

SELECT CountryName as Country,
	COALESCE(PeakName, '(no highest peak)') as [Highest Peak Name],
	COALESCE(Elevation, 0) as [Highest Peak Elevation], 
	COALESCE(MountainRange, '(no mountain)') as [Mountain]
FROM Countries c
LEFT OUTER JOIN (
	SELECT CountryCode, PeakName, Elevation, MountainRange
	FROM MountainsCountries mc
	FULL OUTER JOIN Mountains m ON mc.MountainId = m.Id
	FULL OUTER JOIN Peaks p ON p.MountainId = m.Id) mp
	ON mp.CountryCode = c.CountryCode
WHERE Elevation = (
	SELECT MAX(Elevation)
	FROM Countries con
	LEFT OUTER JOIN (
		SELECT CountryCode, PeakName, Elevation, MountainRange
		FROM MountainsCountries mc
		JOIN Mountains m ON mc.MountainId = m.Id
		LEFT OUTER JOIN Peaks p ON p.MountainId = m.Id) mp
		ON mp.CountryCode = con.CountryCode
	WHERE CountryName = c.CountryName) OR
	(SELECT MAX(Elevation)
	FROM Countries con
	LEFT OUTER JOIN (
		SELECT CountryCode, PeakName, Elevation, MountainRange
		FROM MountainsCountries mc
		JOIN Mountains m ON mc.MountainId = m.Id
		LEFT OUTER JOIN Peaks p ON p.MountainId = m.Id) mp
		ON mp.CountryCode = con.CountryCode
	WHERE CountryName = c.CountryName) IS NULL
ORDER BY CountryName, PeakName


-- 15

CREATE TABLE Monasteries (
	Id int IDENTITY NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	CountryCode CHAR(2) NOT NULL,
	CONSTRAINT PK_Monasteries PRIMARY KEY(Id),
	CONSTRAINT FK_Monasteries_Countries FOREIGN KEY(CountryCode) REFERENCES Countries(CountryCode)
)

ALTER TABLE Countries
ADD IsDeleted BIT DEFAULT 0 

UPDATE Countries
SET IsDeleted = 0

SELECT c.CountryCode
INTO #Target
FROM Countries c
LEFT OUTER JOIN (
	SELECT CountryCode, RiverName
	FROM CountriesRivers cr
	JOIN Rivers r ON cr.RiverId = r.Id) rc
	ON rc.CountryCode = c.CountryCode
GROUP BY c.CountryCode, CountryName
HAVING COUNT(RiverName) > 3

UPDATE Countries
SET IsDeleted = 1
WHERE CountryCode IN (SELECT * FROM #Target)

SELECT m.Name as Monastery, CountryName as Country 
FROM Monasteries m
LEFT OUTER JOIN Countries c
	ON m.CountryCode = c.CountryCode
WHERE IsDeleted = 0
ORDER BY m.Name

-- 16

UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries
VALUES ('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries
VALUES ('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

SELECT ContinentName, CountryName, COUNT(m.Id) as [MonasteriesCount]
FROM Continents co
LEFT OUTER JOIN Countries c
	ON co.ContinentCode = c.ContinentCode
LEFT OUTER JOIN Monasteries m
	ON  m.CountryCode = c.CountryCode
WHERE IsDeleted = 0
GROUP BY ContinentName, CountryName
ORDER BY COUNT(m.Id) DESC, CountryName

-- 17


CREATE FUNCTION fn_MountainsPeaksJSON ()
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @json NVARCHAR(MAX)
	SET @json = '{"mountains":['
	
	DECLARE mountainCursor CURSOR READ_ONLY FOR
		SELECT MountainRange, Id FROM Mountains ORDER BY MountainRange

	OPEN mountainCursor
	DECLARE @mountain NVARCHAR(MAX)
	DECLARE @id int
	FETCH NEXT FROM mountainCursor INTO @mountain, @id

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @json = @json + '{"name":"' + @mountain + '","peaks":['
			DECLARE peakCursor CURSOR READ_ONLY FOR
				SELECT PeakName, Elevation FROM Peaks WHERE MountainId = @id ORDER BY PeakName 
				
				OPEN peakCursor
				DECLARE @peak NVARCHAR(MAX)
				DECLARE @elevation int
				FETCH NEXT FROM peakCursor INTO @peak, @elevation

				WHILE @@FETCH_STATUS = 0
					BEGIN 
						SET @json = @json + '{"name":"' + @peak + '","elevation":' + convert(nvarchar(MAX), @elevation) + '}'

						FETCH NEXT FROM peakCursor INTO @peak, @elevation

						IF (@@FETCH_STATUS != -1)
							BEGIN
								SET @json = @json + ','
							END
					END

				CLOSE peakCursor
				DEALLOCATE peakCursor

				SET @json = @json + ']}'

				FETCH NEXT FROM mountainCursor INTO @mountain, @id

				IF (@@FETCH_STATUS != -1)
					BEGIN
						SET @json = @json + ','
					END
		END

	CLOSE mountainCursor
	DEALLOCATE mountainCursor

	SET @json = @json + ']}'

	RETURN @json;
END




--DROP FUNCTION fn_MountainsPeaksJSON

SELECT dbo.fn_MountainsPeaksJSON()


-- 18

DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings` CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;

DROP TABLE IF EXISTS `courses`;

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `training_centers`;

CREATE TABLE `training_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text,
  `url` text,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `timetable`;

CREATE TABLE `timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `training_center_id` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_timetable_courses_idx` (`course_id`),
  KEY `fk_timetable_training_centers_idx` (`training_center_id`),
  CONSTRAINT `fk_timetable_courses` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_timetable_training_centers` FOREIGN KEY (`training_center_id`) REFERENCES `training_centers` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

SELECT tc.Name, start_date, c.name, COALESCE(c.description, 'NULL')
FROM timetable t
JOIN courses c ON t.course_id = c.id
JOIN training_centers tc ON tc.id = t.training_center_id 
ORDER BY start_date, t.id