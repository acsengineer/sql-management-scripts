
ALTER   PROCEDURE dbo.dsninfo
    @dsn varchar(128),
    @infotype varchar(128) = NULL,
    @login varchar(128) = NULL,
    @password varchar(128) = NULL,
    @dso_type int = 1  /* 1 is ODBC, 3 OLEDB. */
    AS

-- <AVP> 06.11.2001

    SET NOCOUNT ON

Select convert(sysname,'Database Name') as 'Information Type',
	db_name() as Value
return

    DECLARE @distributor sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @retcode int
    DECLARE @dsotype_odbc int
    DECLARE @dsotype_oledb int

    select @dsotype_odbc = 1
    select @dsotype_oledb = 3

	EXEC master..xp_dsninfo @dsn, @infotype, @login, @password


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

