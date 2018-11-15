DROP TABLE IF EXISTS Employee

CREATE TABLE Employee  (ID INTEGER PRIMARY KEY, Name VARCHAR(50), Manager INTEGER)

INSERT INTO Employee VALUES(1, 'Andrea', NULL)

INSERT INTO Employee VALUES(2, 'Greg', 1)

INSERT INTO Employee VALUES(3, 'Matt', 2)

SELECT * FROM Employee

SELECT e1.Name as Employee, e2.Name as Manager
 FROM Employee e1 JOIN Employee e2 ON e1.Manager = e2.ID

WITH Emps AS (
    SELECT ID, Name, Name AS Manager FROM Employee WHERE Manager IS NULL
    UNION ALL
    SELECT e.ID, e.Name, Emps.Name AS Manager
    FROM Employee e INNER JOIN Emps ON e.Manager = Emps.ID
)
SELECT ID, Name, Manager FROM Emps