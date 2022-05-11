if (object_id('tempdb..##proc') is not null)
 exec(N'drop table tempdb..##proc')

select distinct
 [Process ID] = p.spid,
 [Blocked By] = p.blocked,
 [Blocking]   = 0,
 [Host]       = p.hostname,
 [User Name]  = p.nt_username,
 [Application]= p.program_name
into ##proc 
from master.dbo.sysprocesses p with (NOLOCK) 
--where db_name(p.dbid) like 'TaxesTrNew'
order by p.spid

update ##proc 
set [Blocking] = 1 
where [Process ID] in (select [Blocked By] from ##proc where [Blocked By] > 0)

select 
 P.[Process ID], 
 P.[Blocking],
 P.[Blocked By],
 P.[Application],
 P.[Host],
 P.[User Name]
from ##proc  P 
where ((P.[Blocking] > 0)or(P.[Blocked By] > 0))
order by P.[Blocking]

if (object_id('tempdb..##proc') is not null)
 exec(N'drop table tempdb..##proc')