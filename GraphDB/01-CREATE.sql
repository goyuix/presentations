DROP TABLE IF EXISTS Meetup
DROP TABLE IF EXISTS Technology

CREATE TABLE Meetup 
  (ID INTEGER PRIMARY KEY, Title VARCHAR(100))
  AS NODE;

CREATE TABLE Technology (Tag VARCHAR(100)) 
  AS EDGE;

SELECT * FROM Meetup

SELECT * FROM Technology

INSERT INTO Meetup VALUES(1, 'SLCSQL')
INSERT INTO Meetup VALUES(2, 'UTSPUG')
INSERT INTO Meetup VALUES(3, 'CRMUG')

INSERT INTO Technology VALUES(
  (SELECT $node_id FROM Meetup WHERE Title = 'SLCSQL'),
  (SELECT $node_id FROM Meetup WHERE Title = 'UTSPUG'),
  'Microsoft SQL Server'
)
