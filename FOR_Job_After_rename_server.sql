use msdb
go
update sysjobs set
originating_server=replace(originating_server,'OLD_Name','NEW_Name')
go