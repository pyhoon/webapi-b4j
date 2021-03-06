B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Product Handler class
' Version 1.12
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private Elements() As String
	Private Literals() As String = Array As String("category", ":cid", "product", ":pid")
	Private HRM As HttpResponseMessage
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

Private Sub ProcessRequest
	Try
		Select Case Request.Method.ToUpperCase
			Case "GET"
				Select Case Elements.Length - 1
					Case Main.Element.Root ' /

					Case Main.Element.Parent ' /category
						If Elements(Main.Element.Parent) = Literals(0) Then
							Utility.ReturnHttpResponse(GetCategories(0), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Parent_Id ' /category/{cat_id}
						If Elements(Main.Element.Parent) = Literals(0) Then
							Utility.ReturnHttpResponse(GetCategories(Elements(Main.Element.Parent_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Child ' /category/{cat_id}/product
						If Elements(Main.Element.Parent) = Literals(0) And Elements(Main.Element.Child) = Literals(2) Then
							Utility.ReturnHttpResponse(GetProductsByCategories(Elements(Main.Element.Parent_Id), 0), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
						If Elements(Main.Element.Parent) = Literals(0) And Elements(Main.Element.Child) = Literals(2) Then
							Utility.ReturnHttpResponse(GetProductsByCategories(Elements(Main.Element.Parent_Id), Elements(Main.Element.Child_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Else
						Utility.ReturnError("Bad Request", 400, Response)
				End Select
			Case "POST"
				Select Case Elements.Length - 1
					Case Main.Element.Parent ' /category
						If Elements(Main.Element.Parent) = Literals(0) Then
							Utility.ReturnHttpResponse(PostCategory, Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Child ' /category/{cat_id}/product
						If Elements(Main.Element.Parent) = Literals(0) And Elements(Main.Element.Child) = Literals(2) Then
							Utility.ReturnHttpResponse(PostProductByCategory(Elements(Main.Element.Parent_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Else
						Utility.ReturnError("Bad Request", 400, Response)
				End Select
			Case "PUT"
				Select Case Elements.Length - 1
					Case Main.Element.Parent_Id ' /category/{cat_id}
						If Elements(Main.Element.Parent) = Literals(0) Then
							Utility.ReturnHttpResponse(PutCategoryById(Elements(Main.Element.Parent_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
						If Elements(Main.Element.Parent) = Literals(0) And Elements(Main.Element.Child) = Literals(2) Then
							Utility.ReturnHttpResponse(PutProductByCategoryAndId(Elements(Main.Element.Parent_Id), Elements(Main.Element.Child_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Else
						Utility.ReturnError("Bad Request", 400, Response)
				End Select
			Case "DELETE"
				Select Case Elements.Length - 1
					Case Main.Element.Parent_Id ' /category/{cat_id}
						If Elements(Main.Element.Parent) = Literals(0) Then
							Utility.ReturnHttpResponse(DeleteCategoryById(Elements(Main.Element.PARENT_ID)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
						If Elements(Main.Element.Parent) = Literals(0) And Elements(Main.Element.Child) = Literals(2) Then
							Utility.ReturnHttpResponse(DeleteProductsByCategoryAndId(Elements(Main.Element.Parent_Id), Elements(Main.Element.Child_Id)), Response)
						Else
							Utility.ReturnError("Bad Request", 400, Response)
						End If
					Case Else
						Utility.ReturnError("Bad Request", 400, Response)
				End Select
		End Select
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

Public Sub GetCategories (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Get a category by id
	' #Desc2 = List all categories
	' #Elems = 2
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		If Elements.Length-1 = Main.Element.Parent_Id Then
			strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		Else
			strSQL = Main.queries.Get("GET_ALL_CATEGORIES")
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
			HRM.ResponseData = List1
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

Sub PostCategory As HttpResponseMessage
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
			strSQL = Main.queries.Get("GET_ID_BY_CATEGORY_NAME")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("name")))
			If res.NextRow Then
				HRM.ResponseCode = 409
				HRM.ResponseError = "Category Already Exist"
				Utility.ReturnHttpResponse(HRM, Response)
			Else
				strSQL = Main.queries.Get("ADD_NEW_CATEGORY")
				con.BeginTransaction
				con.ExecNonQuery2(strSQL, Array As String(data.Get("name")))
				strSQL = Main.queries.Get("GET_LAST_INSERT_ID")
				Dim NewId As Int = con.ExecQuerySingleResult(strSQL)
				strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(NewId))
				con.TransactionSuccessful
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

Sub PutCategoryById (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Update existing category by id
	' #Desc2 = (N/A)
	' #Elems = 2
	' #Body = {<br>&nbsp; "name": "category_name"<br>}
	#End region		
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("EDIT_CATEGORY_BY_ID")
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

Sub DeleteCategoryById (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Delete category by id
	' #Desc2 = (N/A)
	' #Elems = 2
	#End region	
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cid))
		If res.NextRow Then
			strSQL = Main.queries.Get("REMOVE_CATEGORY_BY_ID")
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

Public Sub GetProductsByCategories (cid As Int, pid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Get a product by category and id
	' #Desc2 = List all products by category id
	' #Elems = 4
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Dim List1 As List
	List1.Initialize
	Try
		If pid = 0 Then
			strSQL = Main.queries.Get("GET_ALL_PRODUCTS_BY_CATEGORY")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		Else
			strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid, pid))
		End If
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				If res.GetColumnName(i) = "product_price" Then
					Map2.Put(res.GetColumnName(i), res.GetDouble2(i))
				Else If res.GetColumnName(i) = "category_id" Or res.GetColumnName(i) = "id" Then
					Map2.Put(res.GetColumnName(i), res.GetInt2(i))
				Else
					Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End If
			Next
			List1.Add(Map2)
		Loop
		If List1.Size > 0 Then
			HRM.ResponseCode = 200
			HRM.ResponseData = List1
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product Not Found"
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Sub PostProductByCategory (cid As Int) As HttpResponseMessage
	#region Documentation
	' #Body = {<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": "product_price"<br>}
	' #Desc1 = (N/A)
	' #Desc2 = Add a new product by category id
	' #Elems = 4
	#End region	
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("ADD_NEW_PRODUCT_BY_CATEGORY")
				con.BeginTransaction
				con.ExecNonQuery2(strSQL, Array As String(cid, data.Get("code"), data.Get("name"), data.Get("price")))
				strSQL = Main.queries.Get("GET_LAST_INSERT_ID")
				Dim NewId As Int = con.ExecQuerySingleResult(strSQL)
				strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid, NewId))
				con.TransactionSuccessful
				Dim List1 As List
				List1.Initialize
				Do While res.NextRow
					Dim Map2 As Map
					Map2.Initialize
					For i = 0 To res.ColumnCount - 1
						If res.GetColumnName(i) = "product_price" Then
							Map2.Put(res.GetColumnName(i), res.GetDouble2(i))
						Else If res.GetColumnName(i) = "category_id" Or res.GetColumnName(i) = "id" Then
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

Sub PutProductByCategoryAndId (cid As Int, pid As Int) As HttpResponseMessage
	' #Desc1 = Update existing product by category and id
	' #Elems = 4
	' #Body = {<br>&nbsp; "cat_id": "new_cat_id",<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": "product_price"<br>}
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cid, pid))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("EDIT_PRODUCT_BY_CATEGORY_AND_ID")
				con.ExecNonQuery2(strSQL, Array As Object(data.Get("cat_id"), data.Get("code"), data.Get("name"), data.Get("price"), cid, pid))
				HRM.ResponseCode = 200
			Else
				HRM.ResponseCode = 400
			End If
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product Not Found"
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Sub DeleteProductsByCategoryAndId (cid As Int, pid As Int) As HttpResponseMessage
	' #Desc1 = Delete product by category and id
	' #Elems = 4
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cid, pid))
		If res.NextRow Then
			strSQL = Main.queries.Get("REMOVE_PRODUCT_BY_CATEGORY_AND_ID")
			con.ExecNonQuery2(strSQL, Array As Int(cid, pid))
			HRM.ResponseCode = 200
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product Not Found"
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub