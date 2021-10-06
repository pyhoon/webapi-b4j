B4J=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=9.1
@EndOfDesignText@
' DataUtils Code module
' Version 1.10
Sub Process_Globals
	Dim pool As ConnectionPool
End Sub

Public Sub CreateDatabaseIfNotExist
	Try
		Dim DBFound As Boolean
		Dim strSQL As String
		Dim DBName As String = Main.Conn.DbName.As(String)
		' SQLite
		If Main.Conn.DbType.EqualsIgnoreCase("sqlite") Then
			Log("Checking database...")
			If File.Exists(File.DirApp, DBName) Then
				Log("Database found!")		
			Else
				Log("Database not found!")
				Log("Creating database...")
				Dim DB As SQL
				DB.InitializeSQLite(File.DirApp, DBName, True)
				DB.ExecNonQuery("PRAGMA journal_mode = wal")
				
				strSQL = Main.queries.Get("CREATE_TABLE_TBL_CATEGORY")
				If strSQL <> "" Then DB.AddNonQueryToBatch(strSQL, Null)
				strSQL = Main.queries.Get("INSERT_DUMMY_TBL_CATEGORY")
				If strSQL <> "" Then DB.AddNonQueryToBatch(strSQL, Null)
				strSQL = Main.queries.Get("CREATE_TABLE_TBL_PRODUCTS")
				If strSQL <> "" Then DB.AddNonQueryToBatch(strSQL, Null)
				strSQL = Main.queries.Get("INSERT_DUMMY_TBL_PRODUCTS")
				If strSQL <> "" Then DB.AddNonQueryToBatch(strSQL, Null)
				
				Dim SenderFilter As Object = DB.ExecNonQueryBatch("SQL")
				Wait For (SenderFilter) SQL_NonQueryComplete (Success As Boolean)
				If Success Then
					Log("Database is created successfully!")
				Else
					Log("Database creation failed!")
				End If
			End If
		End If
		' MySQL
		If Main.Conn.DbType.EqualsIgnoreCase("mysql") Then
			Main.Conn.JdbcUrl = Main.Conn.JdbcUrl.Replace(DBName, "information_schema")
			Dim con As SQL = OpenDB
			If con.IsInitialized Then
				Log($"Checking database..."$)
				strSQL = Main.queries.Get("CHECK_DATABASE")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(DBName))
				Do While res.NextRow
					DBFound = True
				Loop
				res.Close
				If DBFound Then
					Log("Database found!")
				Else
					Log("Database not found!")
					Log("Creating database...")
					
					strSQL = Main.queries.Get("CREATE_DATABASE").As(String).Replace("{DBNAME}", DBName) ' Can't use prepared statement
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					strSQL = Main.queries.Get("USE_DATABASE").As(String).Replace("{DBNAME}", DBName)
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					'strSQL = Main.queries.Get("DROP_TABLE_IF_EXIST_TBL_CATEGORY")
					'If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					strSQL = Main.queries.Get("CREATE_TABLE_TBL_CATEGORY")
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					strSQL = Main.queries.Get("INSERT_DUMMY_TBL_CATEGORY")
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					'strSQL = Main.queries.Get("DROP_TABLE_IF_EXIST_TBL_PRODUCTS")
					'If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					strSQL = Main.queries.Get("CREATE_TABLE_TBL_PRODUCTS")
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
					strSQL = Main.queries.Get("INSERT_DUMMY_TBL_PRODUCTS")
					If strSQL <> "" Then con.AddNonQueryToBatch(strSQL, Null)
				
					Dim SenderFilter As Object = con.ExecNonQueryBatch("SQL")
					Wait For (SenderFilter) SQL_NonQueryComplete (Success As Boolean)
					If Success Then
						Log("Database is created successfully!")
					Else
						Log("Database creation failed!")
					End If
				End If
			End If
		End If
	Catch
		LogError(LastException)
		CloseDB(con)
		Log("Error creating database!")
		Log("Application is terminated.")
		ExitApplication
	End Try
	CloseDB(con)
	' Revert jdbcUrl to normal
	Main.Conn.JdbcUrl = Main.config.Get("JdbcUrl")
End Sub

Sub OpenDB As SQL
	If Main.Conn.DbType.EqualsIgnoreCase("mysql") Then
		pool = Main.OpenConnection(pool)
		Return pool.GetConnection		
	End If
	Return Null
End Sub

Sub CloseDB (con As SQL)
	If con <> Null And con.IsInitialized Then con.Close
	If Main.Conn.DbType.EqualsIgnoreCase("mysql") Then
		If pool.IsInitialized Then pool.ClosePool
	End If
End Sub