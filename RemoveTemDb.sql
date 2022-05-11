Use master 
go 
ALTER DATABASE TEMPDB 
MODIFY FILE (NAME='tempdev', FILENAME='E:\MSSQL\TEMPDB\tempdb.mdf') 
go 
ALTER DATABASE TEMPDB 
MODIFY FILE (NAME='templog', FILENAME='E:\MSSQL\TEMPDB\templog.ldf') 
go 
