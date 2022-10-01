B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Product Handler class
' Version 1.14
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
	Private Literals() As String = Array As String("product", ":pid")
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
		Select Request.Method.ToUpperCase
			Case "GET"
				Select Elements.Length - 1
					Case Main.Element.First ' /product
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(GetProducts(0), Response)
							Return
						End If
					Case Main.Element.Second ' /product/{product_id}
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(GetProducts(Elements(Main.Element.Second)), Response)
							Return
						End If
					Case Else
						Utility.ReturnError("Bad Request", 400, Response)
				End Select
			Case "POST"
				Select Elements.Length - 1
					Case Main.Element.First ' /product
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(PostProduct, Response)
							Return
						End If
				End Select
			Case "PUT"
				Select Elements.Length - 1
					Case Main.Element.Second ' /product/{product_id}
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(PutProduct(Elements(Main.Element.Second)), Response)
							Return
						End If
				End Select
			Case "DELETE"
				Select Elements.Length - 1
					Case Main.Element.Second ' /product/{product_id}
						If Elements(Main.Element.First) = Literals(0) Then
							Utility.ReturnHttpResponse(DeleteProduct(Elements(Main.Element.Second)), Response)
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

Private Sub GetProducts (pid As Int) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Get a product by id
	' #Desc2 = List all products
	' #Elems = 2
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Dim List1 As List
	List1.Initialize
	Try
		If pid = 0 Then
			strSQL = Main.queries.Get("SELECT_ALL_PRODUCTS")
			Dim res As ResultSet = con.ExecQuery(strSQL)
		Else
			strSQL = Main.queries.Get("SELECT_PRODUCT_BY_ID")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(pid))
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

Private Sub PostProduct As HttpResponseMessage
	#region Documentation
	' #Body = {<br>&nbsp; "cat_id": "category_id",<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": "product_price"<br>}
	' #Desc1 = (N/A)
	' #Desc2 = Add a new product
	' #Elems = 1
	#End region	
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		Dim data As Map = Utility.RequestData(Request)
		If data.IsInitialized Then
			strSQL = Main.queries.Get("SELECT_ID_BY_PRODUCT_CODE")
			Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(data.Get("code")))
			If res.NextRow Then
				HRM.ResponseCode = 409
				HRM.ResponseError = "Product Code Already Exist"
			Else
				con.BeginTransaction
				strSQL = Main.queries.Get("INSERT_NEW_PRODUCT")				
				con.ExecNonQuery2(strSQL, Array As String(data.Get("cat_id"), data.Get("code"), data.Get("name"), data.Get("price")))
				strSQL = Main.queries.Get("GET_LAST_INSERT_ID")
				Dim NewId As Int = con.ExecQuerySingleResult(strSQL)
				strSQL = Main.queries.Get("SELECT_PRODUCT_BY_ID")
				Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(NewId))
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
		End If
	Catch
		LogError(LastException)
		HRM.ResponseCode = 422
		HRM.ResponseError = "Error Execute Query"
	End Try
	Main.DB.CloseDB(con)
	Return HRM
End Sub

Private Sub PutProduct (pid As Int) As HttpResponseMessage
	' #Desc1 = Update an existing product by id
	' #Elems = 2
	' #Body = {<br>&nbsp; "cat_id": "category_id",<br>&nbsp; "code": "product_code",<br>&nbsp; "name": "product_name",<br>&nbsp; "price": "product_price"<br>}
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(pid))
		If res.NextRow Then
			Dim data As Map = Utility.RequestData(Request)
			If data.IsInitialized Then
				strSQL = Main.queries.Get("UPDATE_PRODUCT_BY_ID")
				con.ExecNonQuery2(strSQL, Array As Object(data.Get("cat_id"), data.Get("code"), data.Get("name"), data.Get("price"), pid))
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

Private Sub DeleteProduct (pid As Int) As HttpResponseMessage
	' #Desc1 = Delete a product by id
	' #Elems = 2
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Try
		strSQL = Main.queries.Get("SELECT_PRODUCT_BY_ID")
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As Int(pid))
		If res.NextRow Then
			strSQL = Main.queries.Get("DELETE_PRODUCT_BY_ID")
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