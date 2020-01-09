CREATE DATABASE PolyBaseRevealed
GO
USE PolyBaseRevealed
GO
CREATE TABLE dbo.Person
(
    PersonID INT NOT NULL,
    FirstName NVARCHAR(75) NOT NULL,
    LastName NVARCHAR(75) NOT NULL
);

INSERT INTO dbo.Person
(
    PersonID,
    FirstName,
    LastName
)
VALUES
(1, N'Test', N'User'),
(2, N'Second', N'User'),
(3, N'Another', N'Person');

CREATE TABLE dbo.Location
(
    LocationID INT PRIMARY KEY NOT NULL,
    LocationName NVARCHAR(75) NOT NULL
);

INSERT INTO dbo.[Location] 
(
    LocationID,
    LocationName
)
VALUES
(1, N'Sheboygan'),
(2, N'Walla Walla'),
(3, N'Okeechobee');
