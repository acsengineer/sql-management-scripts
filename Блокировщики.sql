set nocount on
print 'Блокировщики'
print ''
select distinct 
substring(loginame,1,15) Логин
,substring(hostname,1,15) Хост
,substring(N273,1,20) ФИО_блокировщика 
,status
,spid
from master..sysprocesses,fn74
where 
spid in 
(select blocked from master..sysprocesses where blocked<>0)
and blocked=0 and 
rtrim(nt_username)=rtrim(D686)
and nt_username <> ''
go
-- Пожиратели ресурсов
print 'Пожиратели ресурсов'
print ''
select blocked, cpu, cpu * 100.0 / (select sum(cpu) from
master..sysprocesses) cpu_part,
memusage*100/(select sum(memusage) from master..sysprocesses) memo_part,
physical_io, physical_io * 100.0 / (select sum(physical_io) from
master..sysprocesses) io_part,
loginame, memusage, cmd
from master..sysprocesses where (select cpu * 100.0 / (select sum(cpu) from
master..sysprocesses))>1 order by io_part desc,physical_io desc,memusage desc

