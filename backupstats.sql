SELECT 
  b.database_name 'AdventureWorks2008R2', 
  CONVERT (BIGINT, b.backup_size / 1048576 ) 'Несжатый размер (MB)', 
  CONVERT (BIGINT, b.compressed_backup_size / 1048576 ) 'Сжатый размер (MB)', 
  CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, b.backup_size) / 
  CONVERT (FLOAT, b.compressed_backup_size))) 'Коэффициент сжатия', 
  DATEDIFF (SECOND, b.backup_start_date, b.backup_finish_date) 'Время резервного копирования (сек)' 
FROM 
  msdb.dbo.backupset b 
WHERE 
  DATEDIFF (SECOND, b.backup_start_date, b.backup_finish_date) > 0 
  AND b.backup_size > 0 
ORDER BY 
  b.backup_finish_date DESC