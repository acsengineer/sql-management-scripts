-- —крипт предназначен дл€ синхронизации пользователей
-- после переноса базы из одного домена в другой.
-- ѕри выполнении скрипта подразумеваетс€, что логины пользователей уже существуют.
-- ≈сли в базе существует пользователь, у которого нет аналогичного имени в логинах,
-- то логин Ќ≈ создаетс€. 
--
-- Ќекоторые замечани€ по поводу параметров.
--
-- ѕараметр @ReplaceExist
-- »спользуетс€ в случае, если в SQL существуют логины пользователей
-- из разных доменов, но с одинаковыми именами.
-- ѕример: в SQL существуют два логина Domain1\user и Domain2\user.
--   базе подключен пользователь Domain1\user. “огда, в случае параметра =0,
-- ситуаци€ не изменитс€, а в случае =1 - к базе будет подключен логин Domain2\user.
-- –екомендуемое значение =0
--
-- ѕараметр @SinchSQLUsers 
-- »спользуетс€, если необходимо синхронизировать логины, созданные по SQL-авторизации.
-- ¬ случае, если синхронизируютс€ пользователи SQL (=0), им€ домена, заданное
-- в параметре @DomainName и значение параметра @ReplaceExist игнорируетс€.

sp_configure 'allow updates',1
go
RECONFIGURE WITH OVERRIDE
go

declare @DomainName varchar(30)
declare @ShowOnly tinyint
declare @ReplaceExist tinyint
declare @SinchSQLUsers tinyint

-- ѕараметр @ShowOnly 
-- =0 - синхронизировать пользователей
-- =1 - только показать список пользователей, которых можно синхронизировать
select @ShowOnly = 0

-- ѕараметр @ReplaceExist
-- =0 - не замен€ть логины другого домена
-- =1 - замен€ть логины другого домена
select @ReplaceExist = 0

-- ѕараметр @SinchSQLUsers 
-- =0 - синхронизировать пользователей домена
-- =1 - синхронизировать пользователей SQL
select @SinchSQLUsers = 1

-- ¬ следующей строке подставить им€ текущего домена
select @DomainName = 'Ifns42'

declare @tname sysname, @u_sid varbinary(85), @l_sid varbinary(85)
declare @sl table (tname sysname, tsid varbinary(85))

if @SinchSQLUsers = 0
	begin
	insert into @sl 
		select substring (sl.name, charindex('\',sl.name)+1,len(sl.name)-charindex('\',sl.name)) name, sid 
			from master..syslogins as sl
			where charindex (@DomainName + '\',sl.name)<>0 and sl.isntuser = 1
		if @ReplaceExist = 0
			begin
			declare crNoSinc cursor for 
				select su.name, su.sid, sl.tsid from sysusers as su 
					join @sl as sl on sl.tname = su.name and sl.tsid <> su.sid
					where su.sid not in (select sid from master..syslogins)
					and su.isntuser = 1
			end
		else
			begin
			declare crNoSinc cursor for 
				select su.name, su.sid, sl.tsid from sysusers as su 
					join @sl as sl on sl.tname = su.name and sl.tsid <> su.sid
					where su.isntuser = 1
			end
	end
else
	begin
	insert into @sl 
		select name, sid
			from master..syslogins as sl
			where charindex('\',sl.name)=0  and sl.isntuser = 0
		declare crNoSinc cursor for 
			select su.name, su.sid, sl.tsid from sysusers as su 
				join @sl as sl on sl.tname = su.name and sl.tsid <> su.sid
				where su.sid not in (select sid from master..syslogins)
				and su.issqluser = 1
	end

open crNoSinc
fetch next from crNoSinc into
	@tname, @u_sid, @l_sid

print ''
print ''
WHILE @@FETCH_STATUS = 0
BEGIN
	print @tname
	if @ShowOnly = 0
	begin
		update sysusers set sid = @l_sid where sid = @u_sid
	end
	fetch next from crNoSinc into
		@tname, @u_sid, @l_sid
END
print ''
print ''

close crNoSinc
deallocate crNoSinc
go

sp_configure 'allow updates',0
go
RECONFIGURE WITH OVERRIDE
go

