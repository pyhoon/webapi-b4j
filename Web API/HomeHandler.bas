B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=8.1
@EndOfDesignText@
' Home Handler class
Sub Class_Globals
	Dim Request As ServletRequest
	Dim Response As ServletResponse
	Dim pool As ConnectionPool
End Sub

Public Sub Initialize

End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	
	' Search e.g. ' http://127.0.0.1:19800/?search=ha
	If Request.GetParameter("search") <> "" Then ' GET
		Search(Request.GetParameter("search"))
	Else if Request.Method.ToUpperCase = "POST" Then
		Dim keywords As String = req.GetParameter("keywords").Trim
		Search(keywords)
	Else
		ShowHomePage
	End If
End Sub

Private Sub ShowHomePage
	Dim strMain As String = Utility.ReadTextFile("main.html")
	Dim strView As String = Utility.ReadTextFile("index.html")
	strMain = Utility.BuildView(strMain, strView)
	strMain = Utility.BuildHtml(strMain, Main.config)
	Utility.ReturnHTML(strMain, Response)
End Sub

Sub Search (SearchForText As String)
	pool = Main.OpenConnection(pool)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		Dim keys() As String = Regex.Split2(" ", 2, SearchForText)

		If keys.Length < 2 Then
			Dim s1 As String = SearchForText.Trim
			'Log(s1)
			strSQL = Main.queries.Get("SEARCH_PRODUCT_BY_CATEGORY_CODE_AND_NAME_ONEWORD_ORDERED")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String("%" & s1 & "%", "%" & s1 & "%", "%" & s1 & "%"))
		Else
			Dim s1 As String = keys(0).Trim
			Dim s2 As String = SearchForText.Replace(keys(0), "").Trim
			'Log(s1 & "," & s2)
			strSQL = Main.queries.Get("SEARCH_PRODUCT_BY_CATEGORY_CODE_AND_NAME_TWOWORDS_ORDERED")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String("%" & s1 & "%", "%" & s1 & "%", "%" & s1 & "%", _
			"%" & s2 & "%", "%" & s2 & "%", "%" & s2 & "%"))
		End If

		Dim List1 As List
		List1.Initialize
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				If res.GetColumnName(i) = "aa" Then
					Map2.Put(res.GetColumnName(i), res.GetInt2(i))
				Else
					Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End If
			Next
			List1.Add(Map2)
		Loop
		Utility.ReturnSuccess2(List1, Response)
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
	If pool.IsInitialized Then pool.ClosePool
End Sub