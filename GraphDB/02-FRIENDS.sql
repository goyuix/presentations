-- Cleanup if needed
DROP TABLE IF EXISTS Person 
DROP TABLE IF EXISTS Friend

-- Create person node table
CREATE TABLE Person (ID INTEGER PRIMARY KEY, Name VARCHAR(50)) AS NODE
CREATE TABLE Friend (DummyDate DATE) AS EDGE

-- Insert into node table
INSERT INTO Person VALUES (1, 'Andrea')
INSERT INTO Person VALUES (2, 'Greg')
INSERT INTO Person VALUES (3, 'Matt')

-- Insert into edge table
INSERT INTO Friend VALUES ((SELECT $node_id FROM Person WHERE Name = 'Andrea'),
       (SELECT $node_id FROM Person WHERE Name = 'Greg'), '11/14/2018')
INSERT INTO Friend VALUES ((SELECT $node_id FROM Person WHERE Name = 'Andrea'),
       (SELECT $node_id FROM Person WHERE Name = 'Matt'), '11/14/2018')

INSERT INTO Friend VALUES ((SELECT $node_id FROM Person WHERE Name = 'Greg'),
       (SELECT $node_id FROM Person WHERE Name = 'Andrea'), '10/15/2018')

INSERT INTO Friend VALUES ((SELECT $node_id FROM Person WHERE Name = 'Matt'),
       (SELECT $node_id FROM Person WHERE Name = 'Greg'), '10/15/2018')

-- use MATCH in SELECT to find friends of Andrea, then Greg
SELECT Person2.Name AS FriendName
FROM Person Person1, Friend, Person Person2
WHERE MATCH(Person1-(Friend)->Person2)
AND Person1.Name = 'Andrea'

SELECT Person2.Name AS FriendName
FROM Person Person1, Friend, Person Person2
WHERE MATCH(Person1-(Friend)->Person2)
AND Person1.Name = 'Greg'


SELECT Person0.Name AS Person, Person1.Name AS Friend1, Person2.Name AS Friend2
FROM Person Person1, Friend friend1,
     Person Person2, Friend friend2, 
     Person Person0
WHERE MATCH(Person1-(Friend1)->Person0<-(Friend2)-Person2)

SELECT Person1.name AS Friend1, Person2.name AS Friend2
FROM Person Person1, Friend friend1, 
     Person Person2, Friend friend2,
     Person Person0
WHERE MATCH(Person1-(Friend1)->Person0 AND Person2-(Friend2)->Person0)