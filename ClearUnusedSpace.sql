set nocount on
go

exec sp_spaceused @updateusage = 'TRUE'
go

declare @MinSize int, @err int, @fname sysname
declare @SQLstr1 varchar(4000), 
				@SQLstr2 varchar(4000)

-- минимальный размер неиспользуемого места для обработки таблицы
set @minSize = 100

create table #list_table (
	name sysname,
	rows varchar(25),
	reserved varchar(30),
	data  varchar(30),
	index_size  varchar(30),
	unused  varchar(30)
)

declare @name sysname

declare cr_dbname cursor read_only for 
	select name from sysobjects 
		where type = 'U' and not exists (select 1 from sysindexes where indid = 1 and sysindexes.id = sysobjects.id)

open cr_dbname
fetch next from cr_dbname into @name
while @@fetch_status = 0
begin
	insert #list_table exec ('sp_spaceused ' +  @name)
	fetch next from cr_dbname into @name
end
close cr_dbname
deallocate cr_dbname

									select sum( cast( substring (unused, 1, len (unused) - 3) as int ) ) from #list_table
									
									delete from #list_table where substring (unused, 1, len (unused) - 3) < @minSize
									
									select top 100 * from #list_table order by convert(int,replace(unused,'KB','')) desc 
									
									select sum( cast( substring (unused, 1, len (unused) - 3) as int ) ) from #list_table

declare cr_tables cursor read_only for 
	select name from #list_table

open cr_tables
fetch next from cr_tables into @name
while @@fetch_status = 0
begin
	select top 1 @fname = name from syscolumns where id = object_id( @name )
  set @SQLstr1 = 'CREATE CLUSTERED INDEX [IDX_cluster_temp] ON [dbo].[' + @name + ']([' + @fname + ']) ON [PRIMARY]'
  set @SQLstr2 = 'DROP INDEX [' + @name + '].[IDX_cluster_temp]'
	
	set @err = 0
	begin tran trIdx
	
	print @SQLstr1
	exec (@SQLstr1)
  set @err = @@error

	print @SQLstr2
	exec (@SQLstr2)
  set @err = @err + @@error
	
	if @err = 0
		commit tran trIdx
	else
		rollback tran trIdx 	

	fetch next from cr_tables into @name
end
close cr_tables
deallocate cr_tables

drop table #list_table
go

exec sp_spaceused @updateusage = 'TRUE'
go
