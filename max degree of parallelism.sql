exec sp_configure 'max degree of parallelism', 1
go
RECONFIGURE WITH OVERRIDE
go
exec sp_configure