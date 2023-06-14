B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Search Handler class
' Version 1.16
Sub Class_Globals
	Private Request As ServletRequest
	Private Response As ServletResponse
	Private HRM As HttpResponseMessage
	Private Elements() As String
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
	
	If Utility.CheckAllowedVerb(Array As String("GET"), Request.Method) = False Then
		HRM.ResponseCode = 405
		HRM.ResponseError = "Method Not Allowed"
		Utility.ReturnHttpResponse(HRM, Response)
		Return
	End If
	
	ProcessRequest
End Sub

Private Sub ProcessRequest
	Try
		'Dim FirstIndex As Int = Main.Element.First
		Dim SecondIndex As Int = Main.Element.Second
		Dim ThirdIndex As Int = Main.Element.Third
		Dim FourthIndex As Int = Main.Element.Fourth
		Dim LastIndex As Int = Elements.Length - 1
		Dim SecondElement As String = Elements(SecondIndex)
		Dim ThirdElement As String = Elements(ThirdIndex)
		Dim FourthElement As String = Elements(FourthIndex)
		Select Request.Method.ToUpperCase
			Case "GET"
				Select LastIndex
					Case FourthIndex
						Select SecondElement
							Case "product"
								Select ThirdElement
									Case "name", "category", "code", "cid"
										' http://127.0.0.1:19800/v1/find/product/name/hammer
										' http://127.0.0.1:19800/v1/find/product/category/hardwares
										' http://127.0.0.1:19800/v1/find/product/code/H001
										' http://127.0.0.1:19800/v1/find/product/cid/1										
										Utility.ReturnHttpResponse(GetProductsByKeyword(ThirdElement, FourthElement), Response)
										Return
								End Select
							Case "category" 
								Select ThirdElement
									Case "name" ' http://127.0.0.1:19800/v1/find/category/name/hardwares
										Utility.ReturnHttpResponse(GetCategoriesByKeyword(ThirdElement, FourthElement), Response)
										Return
								End Select
						End Select
				End Select
		End Select
		Utility.ReturnError("Bad Request", 400, Response)
	Catch
		LogError(LastException)
		Utility.ReturnError("Bad Request", 400, Response)
	End Try
End Sub

Private Sub GetCategoriesByKeyword (keyword As String, value As String) As HttpResponseMessage
	#region Documentation
	' #Desc = Find categories by keyword (name)
	' #Path = ["category", ":keyword", ":value"]
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Select keyword
			Case "name"
				Dim strSQL As String = Main.queries.Get("SELECT_CATEGORY_BY_NAME")
			Case Else
				Return HRM
		End Select
		
		Dim con As SQL = Main.DB.GetConnection
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String("%" & value & "%"))
		Do While res.NextRow
			Dim Map2 As Map
			Map2.Initialize
			For i = 0 To res.ColumnCount - 1
				Map2.Put(res.GetColumnName(i), res.GetString2(i))
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

Private Sub GetProductsByKeyword (keyword As String, value As String) As HttpResponseMessage
	#region Documentation
	' #Desc = Find products by keyword (name, category, code, cid)
	' #Path = ["product", ":keyword", ":value"]
	#End region
	Try
		Dim List1 As List
		List1.Initialize
		
		Select keyword
			Case "name"
				Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_NAME")
				value = "%" & value & "%"
			Case "category"
				Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_CATEGORY_NAME")
			Case "code"
				Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_CODE")
			Case "cid"
				Dim strSQL As String = Main.queries.Get("SELECT_PRODUCT_BY_CATEGORY_ID")
			Case Else
				Return HRM
		End Select
		
		Dim con As SQL = Main.DB.GetConnection
		Dim res As ResultSet = con.ExecQuery2(strSQL, Array As String(value))
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