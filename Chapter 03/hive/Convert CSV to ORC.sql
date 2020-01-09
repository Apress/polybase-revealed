CREATE EXTERNAL TABLE IF NOT EXISTS ParkingViolations
(
    SummonsNumber STRING,
    PlateID STRING,
    RegistrationState STRING,
    PlateType STRING,
    IssueDate STRING,
    ViolationCode STRING,
    VehicleBodyType STRING,
    VehicleMake STRING,
    IssuingAgency STRING,
    StreetCode1 STRING,
    StreetCode2 STRING,
    StreetCode3 STRING,
    VehicleExpirationDate STRING,
    ViolationLocation STRING,
    ViolationPrecinct STRING,
    IssuerPrecinct STRING,
    IssuerCode STRING,
    IssuerCommand STRING,
    IssuerSquad STRING,
    ViolationTime STRING,
    TimeFirstObserved STRING,
    ViolationCounty STRING,
    ViolationInFrontOfOrOpposite STRING,
    HouseNumber STRING,
    StreetName STRING,
    IntersectingStreet STRING,
    DateFirstObserved STRING,
    LawSection STRING,
    SubDivision STRING,
    ViolationLegalCode STRING,
    DaysParkingInEffect STRING,
    FromHoursInEffect STRING,
    ToHoursInEffect STRING,
    VehicleColor STRING,
    UnregisteredVehicle STRING,
    VehicleYear STRING,
    MeterNumber STRING,
    FeetFromCurb STRING,
    ViolationPostCode STRING,
    ViolationDescription STRING,
    NoStandingorStoppingViolation STRING,
    HydrantViolation STRING,
    DoubleParkingViolation STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
location '/PolyBaseData/NYCParkingTickets/'
tblproperties ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS ParkingViolationsORC
(
    SummonsNumber STRING,
    PlateID STRING,
    RegistrationState STRING,
    PlateType STRING,
    IssueDate STRING,
    ViolationCode STRING,
    VehicleBodyType STRING,
    VehicleMake STRING,
    IssuingAgency STRING,
    StreetCode1 STRING,
    StreetCode2 STRING,
    StreetCode3 STRING,
    VehicleExpirationDate STRING,
    ViolationLocation STRING,
    ViolationPrecinct STRING,
    IssuerPrecinct STRING,
    IssuerCode STRING,
    IssuerCommand STRING,
    IssuerSquad STRING,
    ViolationTime STRING,
    TimeFirstObserved STRING,
    ViolationCounty STRING,
    ViolationInFrontOfOrOpposite STRING,
    HouseNumber STRING,
    StreetName STRING,
    IntersectingStreet STRING,
    DateFirstObserved STRING,
    LawSection STRING,
    SubDivision STRING,
    ViolationLegalCode STRING,
    DaysParkingInEffect STRING,
    FromHoursInEffect STRING,
    ToHoursInEffect STRING,
    VehicleColor STRING,
    UnregisteredVehicle STRING,
    VehicleYear STRING,
    MeterNumber STRING,
    FeetFromCurb STRING,
    ViolationPostCode STRING,
    ViolationDescription STRING,
    NoStandingorStoppingViolation STRING,
    HydrantViolation STRING,
    DoubleParkingViolation STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC
location '/PolyBaseData/NYCParkingTicketsORC/';

INSERT INTO ParkingViolationsORC SELECT * FROM ParkingViolations;