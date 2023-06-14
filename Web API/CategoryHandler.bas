B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Category Handler class
' Version 1.16
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
	Private EndPoint As String = "categories" 'ignore
End Sub

Public Sub Initialize
	HRM.Initialize
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	
	Elements = Regex.Split("/", req.RequestURI)
	If Utility.CheckMaxElements(Elements, Main.Element.Max_Elements) = False Then
		Utility.ReturnError("Bad Request", 400, Response)
		Return
	End If
	
	If Utility.CheckAllowedVerb(Array As String("POST", "GET", "PUT", "DELETE"), Request.Method) = False Then
		HRM.ResponseCode = 405
		HRM.ResponseError = "Method Not Allowed"
		Utility.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	ProcessRequest
End Sub

Private Sub ProcessRequest
	Try
		Dim FirstIndex As Int = Main.Element.First
		Dim SecondIndex As Int = Main.Element.Second
		Dim LastIndex As Int = Elements.Length - 1
		
		Select Request.Method.ToUpperCase
			Case "GET"
				Select LastIndex
					Case FirstIndex ' /categories
						Utility.ReturnHttpResponse(GetCategories, Response)
						Return
					Case SecondIndex ' /categories/:cid
						Dim SecondElement As String = Elements(SecondIndex)
						Select SecondElement
							Case "show"
								ShowPage
							Case "list"
								CategoriesList
							Case Else
								Utility.ReturnHttpResponse(GetCategory(SecondElement), Response)
						End Select
						Return
				End Select
			Case "POST"
				Select LastIndex
					Case FirstIndex ' /categories
						Utility.ReturnHttpResponse(PostCategory, Response)
						Return
				End Select
			Case "PUT"
				Select LastIndex
					Case SecondIndex ' /categories/:cid
						Dim SecondElement As String = Elements(SecondIndex)
						Utility.ReturnHttpResponse(PutCategory(SecondElement), Response)
						Return
				End Select
			Case "DELETE"
				Select LastIndex
					Case SecondIndex ' /categories/:cid
						Dim SecondElement As String = Elements(SecondIndex)
						Utility.ReturnHttpResponse(DeleteCategory(SecondElement), Response)
						Return
				End Select
		End Select
		
		Utility.ReturnError("Bad Request", 400, Response)
	Catch
		LogError(LastException)
		Utility.ReturnError("Bad Request", 400, Response)
	End Try
End Sub

' Return Web Page
Private Sub ShowPage
	Dim strMain As String = Utility.ReadTextFile("main.html")
	Dim strView As String = Utility.ReadTextFile("category.html")
	strMain = Utility.BuildView(strMain, strView)
	strMain = Utility.BuildHtml(strMain, Main.config)
	Dim strScripts As String = $"<script src="${Main.ROOT_URL}/assets/js/webapicategory.js"></script>"$
	strMain = Utility.BuildScript(strMain, strScripts)
	Utility.ReturnHTML(strMain, Response)
End Sub

' List all categories id and name
' This sub is not listed in Help
Private Sub CategoriesList
	Try
		Dim List1 As List
		List1.Initialize
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = $"SELECT id AS aa, `category_name` AS bb FROM `tbl_category`"$
		Dim res As ResultSet = con.ExecQuery(strSQL)
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "aa"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case Else
						Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End Select
			Next
			List1.Add(Map2)
		Loop
		res.Close
		
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

Private Sub GetCategories As HttpResponseMessage
	#region Documentation
	' #Desc = List all categories
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_ALL_CATEGORIES")
		Dim res As ResultSet = con.ExecQuery(strSQL)
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case Else
						Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End Select
			Next
			List1.Add(Map2)
		Loop
		res.Close
		
		If List1.Size > 0 Then
			HRM.ResponseCode = 200
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

Private Sub GetCategory (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc = Get a category by id
	' #Path = [":cid"]
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case Else
						Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End Select
			Next
			List1.Add(Map2)
		Loop
		res.Close
		
		If List1.Size > 0 Then
			HRM.ResponseCode = 200
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
	' #Desc = Add a new category
	' #Body = {<br>&nbsp; "name": "category_name"<br>}
	#End region
	Try
		Dim data As Map = Utility.RequestData(Request)
		If Not(data.IsInitialized) Then
			HRM.ResponseCode = 400
			Return HRM
		End If
		If data.ContainsKey("name") = False Or data.Get("name").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Category Cannot Empty"
			Return HRM
		End If
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_ID_BY_CATEGORY_NAME")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("name")))
		If res.NextRow Then
			HRM.ResponseCode = 409
			HRM.ResponseError = "Category Already Exist"
			res.Close
			Main.DB.CloseDB(con)
			Return HRM
		End If
		res.Close
			
		Dim strSQL As String = Main.queries.Get("INSERT_NEW_CATEGORY")
		con.BeginTransaction
		con.ExecNonQuery2(strSQL, Array As String(data.Get("name")))
		con.TransactionSuccessful
		
		Dim List1 As List
		List1.Initialize
		
		Dim strSQL As String = Main.queries.Get("GET_LAST_INSERT_ID")
		Dim NewId As Int = con.ExecQuerySingleResult(strSQL)

		Dim strSQL As String = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(NewId))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case Else
						Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End Select
			Next
			List1.Add(Map2)
		Loop
		res.Close
		
		HRM.ResponseCode = 201
		HRM.ResponseMessage = "Created"
		HRM.ResponseData = List1
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
	' #Desc = Update an existing category by id
	' #Path = [":cid"]
	' #Body = {<br>&nbsp; "name": "category_name"<br>}
	#End region
	Try
		Dim data As Map = Utility.RequestData(Request)
		If Not(data.IsInitialized) Then
			HRM.ResponseCode = 400
			Return HRM
		End If
		If data.ContainsKey("name") = False Or data.Get("name").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Category Cannot Empty"
			Return HRM
		End If
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		If res.NextRow Then
			Dim strSQL As String = Main.queries.Get("UPDATE_CATEGORY_BY_ID")
			con.ExecNonQuery2(strSQL, Array As Object(data.Get("name"), cid))
			HRM.ResponseCode = 200
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Category Not Found"
		End If
		res.Close
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
	' #Desc = Delete a category by id
	' #Path = [":cid"]
	#End region
	Try
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cid))
		If res.NextRow Then
			Dim strSQL As String = Main.queries.Get("DELETE_CATEGORY_BY_ID")
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