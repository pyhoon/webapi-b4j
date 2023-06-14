B4J=true
Group=Modules
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' DataConnector class
' Version 1.16
Sub Class_Globals
	Public SQL As SQL
	Public Conn As Conn
	Private Pool As ConnectionPool
	Type Conn (DbName As String, DbType As String, DriverClass As String, JdbcUrl As String, User As String, Password As String, MaxPoolSize As Int)
End Sub

Public Sub Initialize
	Conn.Initialize
	Conn.DbName = Main.config.Get("DbName")
	Conn.DbType = Main.config.Get("DbType")
	Conn.DriverClass = Main.config.Get("DriverClass")
	Conn.JdbcUrl = Main.config.Get("JdbcUrl")
	If Conn.DbType.EqualsIgnoreCase("mysql") Then
		Conn.User = Main.config.Get("User")
		Conn.Password = Main.config.Get("Password")
		If Main.config.Get("MaxPoolSize") <> Null Then Conn.MaxPoolSize = Main.config.Get("MaxPoolSize")
	End If
	CheckDatabase
	If Conn.DbType.EqualsIgnoreCase("mysql") Then
		Conn.JdbcUrl = Main.config.Get("JdbcUrl")	' Revert jdbcUrl to normal
		OpenConnection
	End If
End Sub

Private Sub OpenConnection
	If Conn.DbType.EqualsIgnoreCase("sqlite") Then
		SQL.InitializeSQLite(File.DirApp, Conn.DbName, False)
	End If
	If Conn.DbType.EqualsIgnoreCase("mysql") Then
		Pool.Initialize(Conn.DriverClass, Conn.JdbcUrl, Conn.User, Conn.Password)
		If Conn.MaxPoolSize > 0 Then
			Dim jo As JavaObject = Pool
			jo.RunMethod("setMaxPoolSize", Array(Conn.MaxPoolSize))
		End If
	End If
End Sub

Public Sub GetConnection As SQL
	If Conn.DbType.EqualsIgnoreCase("mysql") Then
		Return Pool.GetConnection
	End If
	If Conn.DbType.EqualsIgnoreCase("sqlite") Then
		OpenConnection
		Return SQL
	End If
	Return Null
End Sub

Public Sub CloseDB (con As SQL)
	If con <> Null And con.IsInitialized Then con.Close
	'If Conn.DbType.EqualsIgnoreCase("mysql") Then
	'	If Pool.IsInitialized Then Pool.ClosePool
	'End If
End Sub

Private Sub ConAddSQLQuery (Comm As SQL, Key As String)
	Dim strSQL As String = Main.queries.Get(Key)
	If strSQL <> "" Then Comm.AddNonQueryToBatch(strSQL, Null)
End Sub

Private Sub ConAddSQLQuery2 (Comm As SQL, Key As String, Val1 As String, Val2 As String)
	Dim strSQL As String = Main.queries.Get(Key).As(String).Replace(Val1, Val2)
	If strSQL <> "" Then Comm.AddNonQueryToBatch(strSQL, Null)
End Sub

Private Sub CheckDatabase
	Try
		Dim con As SQL
		Dim DBFound As Boolean
		Log($"Checking database..."$)
		If Conn.DbType.EqualsIgnoreCase("sqlite") Then
			If File.Exists(File.DirApp, Conn.DBName) Then
				DBFound = True
			End If
		End If
		If Conn.DbType.EqualsIgnoreCase("mysql") Then
			Conn.JdbcUrl = Conn.JdbcUrl.Replace(Conn.DBName, "information_schema")
			OpenConnection
			con = GetConnection
			If con.IsInitialized Then
				Dim strSQL As String = Main.queries.Get("CHECK_DATABASE")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(Conn.DBName))
				Do While res.NextRow
					DBFound = True
				Loop
				res.Close
			End If
		End If
		If DBFound Then
			Log("Database found!")
		Else   ' Create database if not exist			
			Log("Database not found!")
			Log("Creating database...")
			If Conn.DbType.EqualsIgnoreCase("sqlite") Then
				con.InitializeSQLite(File.DirApp, Conn.DBName, True)
				con.ExecNonQuery("PRAGMA journal_mode = wal")
			End If
			If Conn.DbType.EqualsIgnoreCase("mysql") Then
				ConAddSQLQuery2(con, "CREATE_DATABASE", "{DBNAME}", Conn.DBName)
				ConAddSQLQuery2(con, "USE_DATABASE", "{DBNAME}", Conn.DBName)
			End If
		
			ConAddSQLQuery(con, "CREATE_TABLE_TBL_CATEGORY")
			ConAddSQLQuery(con, "INSERT_DUMMY_TBL_CATEGORY")
			ConAddSQLQuery(con, "CREATE_TABLE_TBL_PRODUCTS")
			ConAddSQLQuery(con, "INSERT_DUMMY_TBL_PRODUCTS")
			Dim CreateDB As Object = con.ExecNonQueryBatch("SQL")
			Wait For (CreateDB) SQL_NonQueryComplete (Success As Boolean)
			If Success Then
				Log("Database is created successfully!")
			Else
				Log("Database creation failed!")
			End If
		End If
		CloseDB(con)
	Catch
		LogError(LastException)
		CloseDB(con)
		Log("Error creating database!")
		Log("Application is terminated.")
		ExitApplication
	End Try
End Sub