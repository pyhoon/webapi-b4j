B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Category Handler class
' Version 1.14
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
	Private Literals() As String = Array As String("category", ":cid")
End Sub

Public Sub Initialize
	
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	
	HRM.Initialize
	Elements = Regex.Split("/", req.RequestURI)
	If CheckMaxElements = False Then
		Utility.ReturnError("Bad Request", 400, Response)
		Return
	End If
	If CheckAllowedVerb = False Then
		HRM.ResponseCode = 405
		HRM.ResponseError = "Method Not Allowed"
		Utility.ReturnHttpResponse(HRM, Response)
		Return
	End If
	ProcessRequest
End Sub

Private Sub ShowPage
	Dim strMain As String = Utility.ReadTextFile("main.html")
	Dim strView As String = Utility.ReadTextFile("category.html")
	strMain = Utility.BuildView(strMain, strView)
	strMain = Utility.BuildHtml(strMain, Main.config)
	Dim strScripts As String = $"<script src="${Main.ROOT_URL}/assets/js/webapicategory.js"></script>"$
	strMain = Utility.BuildScript(strMain, strScripts)
	Utility.ReturnHTML(strMain, Response)
End Sub

Private Sub ListAll
	Dim con As SQL = Main.DB.GetConnection
	Try
		Dim strSQL As String = $"SELECT id AS aa, `category_name` AS bb FROM `tbl_category`"$
		Dim res As ResultSet = con.ExecQuery(strSQL)
		
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
		Utility.ReturnSuccess2(List1, 200, Response)
	Catch
		LogError(LastException)
		HRM.Initialize
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
		Utility.ReturnHttpResponse(HRM, Response)
	End Try
	Main.DB.CloseDB(con)
End Sub

Private Sub ProcessRequest
	Try
		Select Request.Method.ToUpperCase
			Case "GET"
				Select Elements.Length - 1
					Case Main.Element.First ' /category
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(GetCategories(0), Response)
							Return
						End If
					Case Main.Element.Second ' /category/:cid
						If Elements(Main.Element.First) = Literals(0) Then
							Select Elements(Main.Element.Second)
								Case "show"
									ShowPage
								Case "list"
									ListAll
								Case Else
									Utility.ReturnHttpResponse(GetCategories(Elements(Main.Element.Second)), Response)
							End Select
							Return
						End If
				End Select
			Case "POST"
				Select Elements.Length - 1
					Case Main.Element.First ' /category
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(PostCategory, Response)
							Return
						End If
				End Select
			Case "PUT"
				Select Elements.Length - 1
					Case Main.Element.Second ' /category/:cid
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(PutCategory(Elements(Main.Element.Second)), Response)
							Return
						End If
				End Select
			Case "DELETE"
				Select Elements.Length - 1
					Case Main.Element.Second ' /category/:cid
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(DeleteCategory(Elements(Main.Element.Second)), Response)
							Return
						End If
				End Select
		End Select
		Utility.ReturnError("Bad Request", 400, Response)
	Catch
		LogError(LastException)
		Utility.ReturnError("Bad Request", 400, Response)
	End Try
End Sub

Private Sub CheckMaxElements As Boolean
	If Elements.Length > Main.Element.Max_Elements Or Elements.Length = 0 Then
		Return False
	End If
	Return True
End Sub

Private Sub CheckAllowedVerb As Boolean
	'Methods: POST, GET, PUT, PATCH, DELETE
	Dim SupportedMethods As List = Array As String("POST", "GET", "PUT", "DELETE")
	If SupportedMethods.IndexOf(Request.Method) = -1 Then
		Return False
	End If
	Return True
End Sub

Private Sub GetCategories (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Get a category by id
	' #Desc2 = List all categories
	' #Elems = 2
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		If Elements.Length-1 = Main.Element.Second Then
			strSQL = Main.queries.Get("SELECT_CATEGORY_BY_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		Else
			strSQL = Main.queries.Get("SELECT_ALL_CATEGORIES")
			Dim res As ResultSet = con.ExecQuery(strSQL)
		End If
		Dim List1 As List
		List1.Initialize
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				If res.GetColumnName(i) = "id" Then
					Map2.Put(res.GetColumnName(i), res.GetInt2(i))
				Else
					Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End If
			Next
			List1.Add(Map2)
		Loop
		If List1.Size > 0 Then
			HRM.ResponseCode = 200
			'HRM.ResponseData = List1
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Category Not Found"
		End If
		HRM.ResponseData = List1
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Private Sub PostCategory As HttpResponseMessage
	#region Documentation
	' #Desc1 = (N/A)
	' #Desc2 = Add a new category
	' #Elems = 2
	' #Body = {<br>&nbsp; "name": "category_name"<br>}
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		Dim data As Map = Utility.RequestData(Request)
		If data.IsInitialized Then
			If data.Get("name").As(String).Trim.Length = 0 Then
				HRM.ResponseCode = 400
				HRM.ResponseError = "Category Cannot Empty"
				Return HRM
			End If
			strSQL = Main.queries.Get("SELECT_ID_BY_CATEGORY_NAME")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("name")))
			If res.NextRow Then
				HRM.ResponseCode = 409
				HRM.ResponseError = "Category Already Exist"
				'Utility.ReturnHttpResponse(HRM, Response)
			Else
				strSQL = Main.queries.Get("INSERT_NEW_CATEGORY")
				con.BeginTransaction
				con.ExecNonQuery2(strSQL, Array As String(data.Get("name")))
				con.TransactionSuccessful
				strSQL = Main.queries.Get("GET_LAST_INSERT_ID")
				Dim NewId As Int = con.ExecQuerySingleResult(strSQL)
				strSQL = Main.queries.Get("SELECT_CATEGORY_BY_ID")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(NewId))
				'con.TransactionSuccessful
				Dim List1 As List
				List1.Initialize
				Do While res.NextRow
					Dim Map2 As Map
					Map2.Initialize
					For i = 0 To res.ColumnCount - 1
						If res.GetColumnName(i) = "id" Then
							Map2.Put(res.GetColumnName(i), res.GetInt2(i))
						Else
							Map2.Put(res.GetColumnName(i), res.GetString2(i))
						End If						
					Next
					List1.Add(Map2)
				Loop				
				HRM.ResponseCode = 201
				HRM.ResponseMessage = "Created"
				HRM.ResponseData = List1
			End If
		Else
			HRM.ResponseCode = 400
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Private Sub PutCategory (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Update an existing category by id
	' #Desc2 = (N/A)
	' #Elems = 2
	' #Body = {<br>&nbsp; "name": "category_name"<br>}
	#End region		
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				If data.Get("name").As(String).Trim.Length = 0 Then
					HRM.ResponseCode = 400
					HRM.ResponseError = "Category Cannot Empty"
					Return HRM
				End If
				strSQL = Main.queries.Get("UPDATE_CATEGORY_BY_ID")
				con.ExecNonQuery2(strSQL, Array As Object(data.Get("name"), cid))
				HRM.ResponseCode = 200
			Else
				HRM.ResponseCode = 400
			End If
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Category Not Found"
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Private Sub DeleteCategory (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Delete a category by id
	' #Desc2 = (N/A)
	' #Elems = 2
	#End region	
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cid))
		If res.NextRow Then
			strSQL = Main.queries.Get("DELETE_CATEGORY_BY_ID")
			con.ExecNonQuery2(strSQL, Array As Int(cid))
			HRM.ResponseCode = 200
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Category Not Found"
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub