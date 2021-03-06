-- ������ ������������ ��� ������������� �������������
-- ����� �������� ���� �� ������ ������ � ������.
-- ��� ���������� ������� ���������������, ��� ������ ������������� ��� ����������.
-- ���� � ���� ���������� ������������, � �������� ��� ������������ ����� � �������,
-- �� ����� �� ���������. 
--
-- ��������� ��������� �� ������ ����������.
--
-- �������� @ReplaceExist
-- ������������ � ������, ���� � SQL ���������� ������ �������������
-- �� ������ �������, �� � ����������� �������.
-- ������: � SQL ���������� ��� ������ Domain1\user � Domain2\user.
-- � ���� ��������� ������������ Domain1\user. �����, � ������ ��������� =0,
-- �������� �� ���������, � � ������ =1 - � ���� ����� ��������� ����� Domain2\user.
-- ������������� �������� =0
--
-- �������� @SinchSQLUsers 
-- ������������, ���� ���������� ���������������� ������, ��������� �� SQL-�����������.
-- � ������, ���� ���������������� ������������ SQL (=0), ��� ������, ��������
-- � ��������� @DomainName � �������� ��������� @ReplaceExist ������������.

sp_configure 'allow updates',1
go
RECONFIGURE WITH OVERRIDE
go

declare @DomainName varchar(30)
declare @ShowOnly tinyint
declare @ReplaceExist tinyint
declare @SinchSQLUsers tinyint

-- �������� @ShowOnly 
-- =0 - ���������������� �������������
-- =1 - ������ �������� ������ �������������, ������� ����� ����������������
select @ShowOnly = 0

-- �������� @ReplaceExist
-- =0 - �� �������� ������ ������� ������
-- =1 - �������� ������ ������� ������
select @ReplaceExist = 0

-- �������� @SinchSQLUsers 
-- =0 - ���������������� ������������� ������
-- =1 - ���������������� ������������� SQL
select @SinchSQLUsers = 1

-- � ��������� ������ ���������� ��� �������� ������
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

