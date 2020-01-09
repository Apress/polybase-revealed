CREATE EXTERNAL TABLE IF NOT EXISTS NorthCarolinaPopulation
(
    SummaryLevel INT,
    CountyID INT,
    PlaceID INT,
    IsPrimaryGeography BOOLEAN,
    Name STRING,
    PopulationType STRING,
    Year INT,
    Population INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
location '/PolyBaseData/NorthCarolinaPopulation/'
tblproperties ("skip.header.line.count"="1");