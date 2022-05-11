-- �����: ��.�������� ����� �������� > 20 ����
USE master
GO
SELECT cast(db_name(a.database_id) AS VARCHAR) AS Database_Name
	 , b.physical_name
	 --, a.io_stall
	 , a.size_on_disk_bytes
	 , a.io_stall_read_ms / a.num_of_reads '��.�������� ����� �������� ������'
	 , a.io_stall_write_ms / a.num_of_writes '��.�������� ����� �������� ������'
	 --, *
FROM
	sys.dm_io_virtual_file_stats(NULL, NULL) a
	INNER JOIN sys.master_files b
		ON a.database_id = b.database_id AND a.file_id = b.file_id
where num_of_writes > 0 and num_of_reads > 0
ORDER BY
	Database_Name
  , a.io_stall DESC