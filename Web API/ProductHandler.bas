B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Product Handler class
' Version 1.16
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
	Private EndPoint As String = "products" 'ignore
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
					Case FirstIndex ' /products
						Utility.ReturnHttpResponse(GetProducts, Response)
						Return
					Case SecondIndex ' /products/:pid
						Dim SecondElement As String = Elements(SecondIndex)
						Utility.ReturnHttpResponse(GetProduct(SecondElement), Response)
						Return
				End Select
			Case "POST"
				Select LastIndex
					Case FirstIndex ' /products
						Utility.ReturnHttpResponse(PostProduct, Response)
						Return
				End Select
			Case "PUT"
				Select LastIndex
					Case SecondIndex ' /products/:pid
						Dim SecondElement As String = Elements(SecondIndex)
						Utility.ReturnHttpResponse(PutProduct(SecondElement), Response)
						Return
				End Select
			Case "DELETE"
				Select LastIndex
					Case SecondIndex ' /products/:pid
						Dim SecondElement As String = Elements(SecondIndex)
						Utility.ReturnHttpResponse(DeleteProduct(SecondElement), Response)
						Return
				End Select
		End Select
		Utility.ReturnError("Bad Request", 400, Response)
	Catch
		LogError(LastException)
		Utility.ReturnError("Bad Request", 400, Response)
	End Try
End Sub

Private Sub GetProducts As HttpResponseMessage
	#region Documentation
	' #Desc = List all products
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_ALL_PRODUCTS")
		Dim res As ResultSet = con.ExecQuery(strSQL)
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id", "category_id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case "product_price"
						Map2.Put(res.GetColumnName(i), res.GetDouble2(i))
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
			HRM.ResponseError = "Product Not Found"
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

Private Sub GetProduct (pid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc = Get a product by id
	' #Path = [":pid"]
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(pid))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id", "category_id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case "product_price"
						Map2.Put(res.GetColumnName(i), res.GetDouble2(i))
					Case Else
						Map2.Put(res.GetColumnName(i), res.GetString2(i))
				End Select
			Next
			List1.Add(Map2)
		Loop
		If List1.Size > 0 Then
			HRM.ResponseCode = 200			
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product Not Found"
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

Private Sub PostProduct As HttpResponseMessage
	#region Documentation
	' #Desc = Add a new product
	' #Body = {<br>&nbsp; "cat_id": category_id,<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": product_price<br>}
	#End region
	Try
		Dim data As Map = Utility.RequestData(Request)
		If Not(data.IsInitialized) Then
			HRM.ResponseCode = 400
			Return HRM
		End If
		If data.ContainsKey("cat_id") = False Or data.Get("cat_id").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Category ID Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("code") = False Or data.Get("code").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Code Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("name") = False Or data.Get("name").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Name Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("price") = False Or data.Get("price").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Price Cannot Empty"
			Return HRM
		End If
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_ID_BY_PRODUCT_CODE")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("code")))
		
		If res.NextRow Then
			HRM.ResponseCode = 409
			HRM.ResponseError = "Product Code Already Exist"
			res.Close
			Main.DB.CloseDB(con)
			Return HRM
		End If
		res.Close
		
		Dim strSQL As String = Main.queries.Get("INSERT_NEW_PRODUCT")
		con.BeginTransaction
		con.ExecNonQuery2(strSQL, Array As String(data.Get("cat_id"), data.Get("code"), data.Get("name"), data.Get("price")))
		con.TransactionSuccessful
			
		Dim List1 As List
		List1.Initialize
			
		Dim strSQL As String = Main.queries.Get("GET_LAST_INSERT_ID")
		Dim NewId As Int = con.ExecQuerySingleResult(strSQL)
			
		Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(NewId))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Select res.GetColumnName(i)
					Case "id", "category_id"
						Map2.Put(res.GetColumnName(i), res.GetInt2(i))
					Case "product_price"
						Map2.Put(res.GetColumnName(i), res.GetDouble2(i))
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

Private Sub PutProduct (pid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc = Update an existing product by id
	' #Path = [":pid"]
	' #Body = {<br>&nbsp; "cat_id": category_id,<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": product_price<br>}
	#End region
	Try
		Dim data As Map = Utility.RequestData(Request)
		If Not(data.IsInitialized) Then
			HRM.ResponseCode = 400
			Return HRM
		End If
		If data.ContainsKey("cat_id") = False Or data.Get("cat_id").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Category ID Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("code") = False Or data.Get("code").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Code Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("name") = False Or data.Get("name").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Name Cannot Empty"
			Return HRM
		End If
		If data.ContainsKey("price") = False Or data.Get("price").As(String).Trim.Length = 0 Then
			HRM.ResponseCode = 400
			HRM.ResponseError = "Product Price Cannot Empty"
			Return HRM
		End If
		
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(pid))
		If res.NextRow Then
			Dim strSQL As String = Main.queries.Get("UPDATE_PRODUCT_BY_ID")
			con.ExecNonQuery2(strSQL, Array As Object(data.Get("cat_id"), data.Get("code"), data.Get("name"), data.Get("price"), pid))
			HRM.ResponseCode = 200
		Else
			HRM.ResponseCode = 404
			HRM.ResponseError = "Product Not Found"
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

Private Sub DeleteProduct (pid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc = Delete a product by id
	' #Path = [":pid"]
	#End region
	Try
		Dim con As SQL = Main.DB.GetConnection
		Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(pid))
		If res.NextRow Then
			Dim strSQL As String = Main.queries.Get("DELETE_PRODUCT_BY_ID")
			con.ExecNonQuery2(strSQL, Array As Int(pid))
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