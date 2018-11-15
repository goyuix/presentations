DROP TABLE IF EXISTS Volunteers
DROP TABLE IF EXISTS Mentors

CREATE TABLE Volunteers (ID INTEGER PRIMARY KEY, Name VARCHAR(50)) AS NODE

CREATE TABLE Mentors (StartDate DATE) AS EDGE

INSERT INTO Volunteers VALUES (1, 'Andrea')
INSERT INTO Volunteers VALUES (2, 'Greg')
INSERT INTO Volunteers VALUES (3, 'Matt')

INSERT INTO Mentors VALUES(
    (SELECT $node_id FROM Volunteers WHERE Name = 'Andrea'),
    (SELECT $node_id FROM Volunteers WHERE Name = 'Greg'),
    '09/14/2016'
)
INSERT INTO Mentors VALUES(
    (SELECT $node_id FROM Volunteers WHERE Name = 'Greg'),
    (SELECT $node_id FROM Volunteers WHERE Name = 'Matt'),
    '01/02/2017'
)

SELECT v1.Name AS Volunteer, v2.Name as Mentor
FROM Volunteers v1, Mentors m, Volunteers v2
WHERE MATCH(v1<-(m)-v2)
