-- Must be run in the user database, e.g., csdw.
CREATE USER DataLoaderRC60 FOR LOGIN DataLoaderRC60;
GRANT CONTROL ON DATABASE::[csdw] TO DataLoaderRC60;
EXEC sp_addrolemember 'staticrc60', 'DataLoaderRC60';
GO
