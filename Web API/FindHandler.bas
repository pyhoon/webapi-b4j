B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Search Handler class
' Version 1.15
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
	Private Literals() As String = Array As String("find", "category|product", ":keyword", ":value")
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
					Case Main.Element.Fourth ' /find/product/code/H001 or /find/product/name/hammer or /find/product/cid/1 or /find/product/category/hardwares
						If Elements(Main.Element.First) = Literals(0) Then
							Select Elements(Main.Element.Second)
								Case "category"
									Select Elements(Main.Element.Third)
										Case "name"
											Utility.ReturnHttpResponse(GetCategoriesByKeyword(Elements(Main.Element.Third), Elements(Main.Element.Fourth)), Response)
											Return
									End Select
								Case "product"
									Select Elements(Main.Element.Third)
										Case "code", "name", "cid", "category"
											Utility.ReturnHttpResponse(GetProductsByKeyword(Elements(Main.Element.Third), Elements(Main.Element.Fourth)), Response)
											Return
									End Select
							End Select
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
	Dim SupportedMethods As List = Array As String("GET")
	If SupportedMethods.IndexOf(Request.Method) = -1 Then
		Return False
	End If
	Return True
End Sub

Private Sub GetCategoriesByKeyword (keyword As String, value As String) As HttpResponseMessage
	#region Documentation
	' #Desc1 = Get one or more categories by keyword (name)
	' #Desc2 = (N/A)
	' #Elems = 4
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Dim List1 As List
	List1.Initialize
	Try
		Select keyword
			Case "name"
				strSQL = Main.queries.Get("SELECT_CATEGORY_BY_NAME")
			Case Else
				Return HRM
		End Select
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String("%" & value & "%"))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Map2.Put(res.GetColumnName(i), res.GetString2(i))
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

Private Sub GetProductsByKeyword (keyword As String, value As String) As HttpResponseMessage
	#region Documentation
	' #Desc2 = Get one or more products by a keyword (code, name, cid, category)
	' #Desc1 = (N/A)
	' #Elems = 4
	#End region
	Dim con As SQL = Main.DB.GetConnection
	Dim strSQL As String
	Dim List1 As List
	List1.Initialize
	Try
		Select keyword
			Case "code"
				strSQL = Main.queries.Get("SELECT_PRODUCT_BY_CODE")
			Case "name"
				strSQL = Main.queries.Get("SELECT_PRODUCT_BY_NAME")
				value = "%" & value & "%"
			Case "cid"
				strSQL = Main.queries.Get("SELECT_PRODUCT_BY_CATEGORY_ID")
			Case "category"
				strSQL = Main.queries.Get("SELECT_PRODUCT_BY_CATEGORY_NAME")
			Case Else
				Return HRM
		End Select
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(value))
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