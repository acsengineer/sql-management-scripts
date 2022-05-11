dbcc checkdb WITH NO_INFOMSGS 
go
exec sp_msForEachTable "dbcc dbreindex('?') WITH NO_INFOMSGS"
go
exec sp_updatestats
go
dbcc checkalloc WITH NO_INFOMSGS
go
sp_spaceused @updateusage = 'TRUE'
go
