-- boot.ini сервера добавить ключ /PAE

sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'awe enabled', 1
RECONFIGURE
GO
sp_configure 'max server memory', 24576 --24 √б
RECONFIGURE
GO

--sp_configure 'awe enabled'

--select cntr_value/1024 [memory_sqlserver, mb] from master..sysperfinfo 
--where counter_name = 'Total Server Memory (KB)'