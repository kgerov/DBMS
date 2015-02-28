-- Problem 1.	Create a table in SQL Server

CREATE DATABASE Test2
GO
USE Test2
GO
-- Change database size and autogrowth
CREATE TABLE DateText (
	EntryDate datetime,
	SampleText nvarchar(10)
)

BEGIN TRAN
	DECLARE @iter int = 9000000
	DECLARE @date datetime = '01-01-01'

	WHILE @iter >= 0
		BEGIN
			INSERT INTO DateText
			VALUES (@date, 'Tozi tekst')
			SET @iter = @iter - 1
			SET @date = DATEADD(MINUTE, 1, @date)
		END
COMMIT

GO

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO

SELECT EntryDate, SampleText 
FROM DateText
WHERE EntryDate BETWEEN '2001-01-01' AND '2015-03-03'

-- Problem 2.	Add an index to speed-up the search by date 

CREATE INDEX IDX_Date
ON DateText(EntryDate)

CHECKPOINT; DBCC DROPCLEANBUFFERS;

SELECT EntryDate, SampleText 
FROM DateText
WHERE EntryDate BETWEEN '2001-01-01' AND '2015-03-03'


-- Problem 3.	Create the same table in MySQL
CREATE DATABASE testpartitioning

CREATE TABLE datetext (
	entry_date datetime,
	entry_text varchar(10),
);


ALTER TABLE datetext 
PARTITION BY RANGE COLUMNS (entry_date) ( 
	PARTITION p_1990 VALUES LESS THAN ('1990-01-01'), 
	PARTITION p_2000 VALUES LESS THAN ('2000-01-01'), 
	PARTITION p_2010 VALUES LESS THAN ('2010-01-01') 
)


DELIMITER $$
CREATE PROCEDURE generateData()
BEGIN
	SET @iter = 1000000;
	SET @date = STR_TO_DATE('19900202 1030','%Y%m%d %h%i');

	START TRANSACTION;
		WHILE (@iter > 0) DO
            INSERT INTO datetext   
            VALUES(@date , 'Nqkakvo tekstche');
            SET @iter= @iter - 1;
            SET @date = DATE_ADD(@date, INTERVAL 10 MINUTE);
		END WHILE;
	COMMIT;
END

DELIMITER $$


CALL generateData();


SELECT entry_date, entry_text
FROM datetext
WHERE entry_date BETWEEN str_to_date('01/01/1991', '%m/%d/%Y') AND str_to_date('01/01/1999', '%m/%d/%Y') 


SELECT entry_date, entry_text
FROM datetext
WHERE entry_date BETWEEN str_to_date('01/01/1980', '%m/%d/%Y') AND str_to_date('01/01/1999', '%m/%d/%Y') 