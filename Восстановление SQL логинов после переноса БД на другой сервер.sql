DECLARE @user SYSNAME, @cnt INT
   SET @cnt = 0

   DECLARE cr CURSOR LOCAL FOR
      SELECT [name] FROM sysusers
      WHERE ([issqluser] = 1) AND ([sid] IS NOT NULL) AND ([sid] <> 0x0) AND (SUSER_SNAME([sid]) IS NULL)
      ORDER BY [name] ASC
   OPEN cr
   FETCH NEXT FROM cr INTO @user
   WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT ''
      PRINT 'DB USER ''' + @user + '''..........'

      IF EXISTS(SELECT 0 FROM master.dbo.syslogins WHERE [name] = @user) PRINT ' - SQL Server Login already exists.'
      ELSE
      BEGIN
         EXEC sp_addlogin @loginame = @user, @passwd = 'Pa$$w0rd'
         PRINT ' - SQL Server Login created.'
      END

      EXEC sp_change_users_login 'Auto_Fix', @user
      PRINT ' - Link db-user <--> sql-server-login fixed.'

      SET @cnt = @cnt + 1

      FETCH NEXT FROM cr INTO @user
   END
   CLOSE cr
   DEALLOCATE cr

   PRINT ''
   PRINT CAST(@cnt AS NVARCHAR(50)) + ' DB user(s) fixed. Please examine the result to confirm that the correct links are in fact made.'
GO
