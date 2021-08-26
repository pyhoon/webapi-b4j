B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Product Handler class
Sub Class_Globals
	Dim Request As ServletRequest
	Dim Response As ServletResponse
	Dim pool As ConnectionPool
	Dim Elements() As String
End Sub

Public Sub Initialize
	
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	
	Elements = Regex.Split("/", req.RequestURI)
	If CheckMaxElements = False Then
		Utility.ReturnError("Bad Request", 400, Response)
		Return
	End If
	If CheckAllowedVerb = False Then
		Utility.ReturnError("Method Not Allowed", 405, Response)
		Return
	End If
	ProcessRequest
End Sub

Private Sub ProcessRequest
	pool = Main.OpenConnection(pool)
	Select Case Request.Method.ToUpperCase
		Case "GET"
			Select Case Elements.Length - 1
				Case Main.Element.Root ' /

				Case Main.Element.Parent ' /category
					If Elements(Main.ELEMENT.Parent) = "category" Then
						GetCategories("")
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Main.Element.Parent_Id ' /category/{cat_id}
					If Elements(Main.ELEMENT.Parent) = "category" Then
						GetCategories(Elements(Main.Element.Parent_Id))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Main.Element.Child ' /category/{cat_id}/product
					If Elements(Main.ELEMENT.Parent) = "category" And Elements(Main.ELEMENT.CHILD) = "product" Then
						GetProductsByCategories(Elements(Main.ELEMENT.PARENT_ID), "")
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If
				Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
					If Elements(Main.ELEMENT.Parent) = "category" And Elements(Main.ELEMENT.CHILD) = "product" Then
						GetProductsByCategories(Elements(Main.ELEMENT.PARENT_ID), Elements(Main.ELEMENT.CHILD_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If
				Case Else
					Utility.ReturnError("Bad Request", 400, Response)
			End Select
		Case "POST"
			Select Case Elements.Length - 1
				Case Main.Element.Parent ' /category
					If Elements(Main.ELEMENT.Parent) = "category" Then
						PostCategory
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Main.Element.Child ' /category/{cat_id}/product
					If Elements(Main.ELEMENT.Parent) = "category" And Elements(Main.ELEMENT.CHILD) = "product" Then
						PostProductByCategory(Elements(Main.ELEMENT.PARENT_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Else
					Utility.ReturnError("Bad Request", 400, Response)
			End Select
		Case "PUT"
			Select Case Elements.Length - 1
				Case Main.Element.Parent_Id ' /category/{cat_id}
					If Elements(Main.ELEMENT.Parent) = "category" Then
						PutCategoryById(Elements(Main.ELEMENT.PARENT_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
					If Elements(Main.ELEMENT.Parent) = "category" And Elements(Main.ELEMENT.CHILD) = "product" Then
						PutProductByCategoryAndId(Elements(Main.ELEMENT.PARENT_ID), Elements(Main.ELEMENT.CHILD_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If
				Case Else
					Utility.ReturnError("Bad Request", 400, Response)
			End Select
		Case "DELETE"
			Select Case Elements.Length - 1
				Case Main.Element.Parent_Id ' /category/{cat_id}
					If Elements(Main.ELEMENT.Parent) = "category" Then
						DeleteCategoryById(Elements(Main.ELEMENT.PARENT_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If					
				Case Main.Element.Child_Id ' /category/{cat_id}/product/{product_id}
					If Elements(Main.ELEMENT.Parent) = "category" And Elements(Main.ELEMENT.CHILD) = "product" Then
						DeleteProductsByCategoryAndId(Elements(Main.ELEMENT.PARENT_ID), Elements(Main.ELEMENT.CHILD_ID))
					Else
						Utility.ReturnError("Bad Request", 400, Response)
					End If
				Case Else
					Utility.ReturnError("Bad Request", 400, Response)
			End Select
	End Select
	If pool.IsInitialized Then pool.ClosePool
End Sub

Private Sub CheckMaxElements As Boolean
	If Elements.Length > Main.ELEMENT.MAX_ELEMENTS Or Elements.Length = 0 Then
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

Sub GetCategories (cat_id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		If cat_id = "" Then
			strSQL = Main.queries.Get("GET_ALL_CATEGORIES")
			Dim res As ResultSet = con.ExecQuery(strSQL)
		Else
			strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id))
		End If
						
		Dim List1 As List
		List1.Initialize
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Map2.Put(res.GetColumnName(i), res.GetString2(i))
			Next
			List1.Add(Map2)
		Loop
		Utility.ReturnSuccess2(List1, Response)
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub GetProductsByCategories (cat_id As String, id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		If id = "" Then
			strSQL = Main.queries.Get("GET_ALL_PRODUCTS_BY_CATEGORY")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id))
		Else
			strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id, id))
		End If
						
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
		Utility.ReturnSuccess2(List1, Response)
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub PostCategory
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		Dim data As Map = Utility.RequestData(Request)
		If data.IsInitialized Then
			strSQL = Main.queries.Get("GET_ID_BY_CATEGORY_NAME")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("name")))
			If res.NextRow Then
				Utility.ReturnError("Category Already Exist", 409, Response)
			Else
				strSQL = Main.queries.Get("ADD_NEW_CATEGORY")
				con.ExecNonQuery2(strSQL, Array As String(data.Get("name")))
				Utility.ReturnSuccess(CreateMap("result": "success"), Response)
			End If
		Else
			Utility.ReturnError("Bad Request", 400, Response)
		End If
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub PostProductByCategory (cat_id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("ADD_NEW_PRODUCT_BY_CATEGORY")
				con.ExecNonQuery2(strSQL, Array As String(cat_id, data.Get("code"), data.Get("name"), data.Get("price")))
				Utility.ReturnSuccess(CreateMap("result": "success"), Response)
				Return
			End If
		Else
			Utility.ReturnError("Category Not Found", 404, Response)
		End If		
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub PutCategoryById (cat_id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("EDIT_CATEGORY_BY_ID")
				con.ExecNonQuery2(strSQL, Array As Object(data.Get("name"), cat_id))
				Utility.ReturnSuccess(CreateMap("result": "success"), Response)
			Else
				Utility.ReturnError("Bad Request", 400, Response)
			End If
		Else
			Utility.ReturnError("Category Not Found", 404, Response)
		End If
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub PutProductByCategoryAndId (cat_id As String, id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(cat_id, id))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("EDIT_PRODUCT_BY_CATEGORY_AND_ID")
				con.ExecNonQuery2(strSQL, Array As Object(cat_id, data.Get("code"), data.Get("name"), data.Get("price"), cat_id, id))
				Utility.ReturnSuccess(CreateMap("result": "success"), Response)
			Else
				Utility.ReturnError("Bad Request", 400, Response)
			End If
		Else
			Utility.ReturnError("Product Not Found", 404, Response)
		End If
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub DeleteCategoryById (cat_id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_CATEGORY_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cat_id))
		If res.NextRow Then
			strSQL = Main.queries.Get("REMOVE_CATEGORY_BY_ID")
			con.ExecNonQuery2(strSQL, Array As Int(cat_id))
			Utility.ReturnSuccess(CreateMap("result": "success"), Response)
		Else
			Utility.ReturnError("Category Not Found", 404, Response)
		End If
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub

Sub DeleteProductsByCategoryAndId (cat_id As String, id As String)
	Dim con As SQL = pool.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("GET_PRODUCT_BY_CATEGORY_AND_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(cat_id, id))
		If res.NextRow Then
			strSQL = Main.queries.Get("REMOVE_PRODUCT_BY_CATEGORY_AND_ID")
			con.ExecNonQuery2(strSQL, Array As Int(cat_id, id))
			Utility.ReturnSuccess(CreateMap("result": "success"), Response)
		Else
			Utility.ReturnError("Product Not Found", 404, Response)
		End If
	Catch
		LogDebug(LastException)
		Utility.ReturnError("Error Execute Query", 422, Response)
	End Try
	If con <> Null And con.IsInitialized Then con.Close
End Sub