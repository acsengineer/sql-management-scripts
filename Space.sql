Set NoCount On
EXEC SP_SPACEUSED @UPDATEUSAGE = TRUE
exec sp_dboption
exec sp_configure

If Exists (Select [name],OrigFillFactor from sysindexes Where OrigFillFactor<>0)
begin
	Print '��������, � ���� ���� ������� � FillFactor<>0'
	Select [name],OrigFillFactor from sysindexes Where OrigFillFactor<>0
End

Declare @StrCursorRows Varchar(255)
	,@CountAll Int
	,@CountCur Int
	,@Name Varchar(255) 

Declare m_Cursor SCROLL CURSOR For
	Select Name From SysObjects Where Type='U'
For READ ONLY

-- ��������� ������� � �������

Create Table #Tmp11 (Name Char(30),Rows Char(10), 
	reserved  Char(16), data Char(16),index_size Char(16), unused Char(16))

Open m_Cursor
FETCH Next FROM m_Cursor INTO @Name
	Select @StrCursorRows='�������� ��������� ������� - '+ Convert(Varchar,@@cursor_rows)
	,@CountAll=@@cursor_rows ,@CountCur=1
--	RAISERROR(@StrCursorRows,1,2) With NOWAIT
While (@@fetch_status <> -1)
BEGIN
-------------------------------------------------
	Insert #Tmp11 Exec sp_SpaceUsed @Name

-------------------------------------------------
SC0_NEXT: -- ������� �� ��������� ������
FETCH Next FROM m_Cursor INTO @Name
	Select @CountCur=@CountCur+1
END

Close m_Cursor
DEALLOCATE m_Cursor -- ����������� ������

Exec sp_SpaceUsed
Print '������ ���������'
Select top 20 Name as [������������], Rows as [�-�� �����]
	,Convert(Int,SubString(reserved,1,CHARINDEX('KB',reserved)-1)) As [������] 
From #Tmp11 Where Rows>0
order by 3 Desc

drop table #Tmp11