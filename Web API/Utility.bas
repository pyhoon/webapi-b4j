B4J=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=8.1
@EndOfDesignText@
' Utility Code module
' Version 1.15
Sub Process_Globals
	Private const CONTENT_TYPE_JSON As String = "application/json"
	Private const CONTENT_TYPE_HTML As String = "text/html"
	Type HttpResponseMessage (ResponseCode As Int, ResponseString As String, ResponseData As List, ResponseMessage As String, ResponseError As String, ResponseType As String, ContentType As String)
End Sub

Public Sub BuildHtml (strHTML As String, Settings As Map) As String
	' Replace $KEY$ tag with new content from Map
 	strHTML = WebUtils.ReplaceMap(strHTML, Settings)
	Return strHTML
End Sub

Public Sub BuildView (strHTML As String, View As String) As String
	' Replace @VIEW@ tag with new content
	strHTML = strHTML.Replace("@VIEW@", View)
	Return strHTML
End Sub

Public Sub BuildDocView (strHTML As String, View As String) As String
	' Replace @DOCVIEW@ tag with new content
	strHTML = strHTML.Replace("@DOCVIEW@", View)
	Return strHTML
End Sub

Public Sub BuildScript (strHTML As String, Script As String) As String
	' Replace @SCRIPT@ tag with new content
	strHTML = strHTML.Replace("@SCRIPT@", Script)
	Return strHTML
End Sub

Public Sub ReadMapFile (FileDir As String, FileName As String) As Map
	Dim strPath As String = File.Combine(FileDir, FileName)
	Log($"Reading file (${strPath})..."$)
	Return File.ReadMap(FileDir, FileName)
End Sub

Public Sub ReadTextFile (FileName As String) As String
	Return File.ReadString(File.DirAssets, FileName)
End Sub

Public Sub WriteTextFile (FileName As String, Contents As String)
	File.WriteString(File.DirApp, FileName, Contents)
End Sub

Public Sub Map2Json (M As Map) As String
	Return M.As(JSON).ToString
End Sub

public Sub RequestData (Request As ServletRequest) As Map
	Dim mdl As String = "RequestData"
	Try
		Dim data As Map
		Dim ins As InputStream = Request.InputStream
		If ins.BytesAvailable <= 0 Then
			Return data
		End If
		Dim tr As TextReader
		tr.Initialize(ins)
		Dim json As JSONParser
		json.Initialize(tr.ReadAll)
		data = json.NextObject
	Catch
		LogError($"${mdl} "$ & LastException)
	End Try
	Return data
End Sub

Public Sub ReturnHTML (str As String, resp As ServletResponse)
	resp.ContentType = CONTENT_TYPE_HTML
	resp.Write(str)
End Sub

Public Sub ReturnConnect (resp As ServletResponse)
	Dim Result As List
	Result.Initialize
	Result.Add(CreateMap("connect": "true"))
	Dim Map1 As Map = CreateMap("s": "ok", "a": 200, "r": Result, "m": "Success", "e": Null)
	resp.Status = 200
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnError (Error As String, Code As Int, resp As ServletResponse)
	If Error = "" Then Error = "Bad Request"
	If Code = 0 Then Code = 400
	Dim Result As List
	Result.Initialize
	Dim Map1 As Map = CreateMap("s": "error", "a": Code, "r": Result, "m": Null, "e": Error)
	resp.Status = Code
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnSuccess (Data As Map, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	If Code = 0 Then Code = 200
	Dim Result As List
	Result.Initialize
	Result.Add(Data)
	Dim Map1 As Map = CreateMap("s": "ok", "a": Code, "r": Result, "m": "Success", "e": Null)
	resp.Status = Code
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnSuccess2 (Data As List, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	If Code = 0 Then Code = 200
	Dim Map1 As Map = CreateMap("s": "ok", "a": Code, "r": Data, "m": "Success", "e": Null)
	resp.Status = Code
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnLocation (Location As String, resp As ServletResponse) ' Code = 302
	resp.SendRedirect(Location)
End Sub

Public Sub ReturnHttpResponse (mess As HttpResponseMessage, resp As ServletResponse)
	If mess.ResponseCode >= 200 And mess.ResponseCode < 300 Then ' SUCCESS
		If mess.ResponseString = "" Then mess.ResponseString = "ok"
		If mess.ResponseMessage = "" Then mess.ResponseMessage = "Success"
		mess.ResponseError = Null
	Else ' ERROR
		If mess.ResponseCode = 0 Then mess.ResponseCode = 400
		If mess.ResponseString = "" Then mess.ResponseString = "error"
		'If mess.ResponseMessage = "" Then mess.ResponseMessage = "Bad Request"
		If mess.ResponseError = "" Then mess.ResponseError = "Bad Request"
		mess.ResponseMessage = Null
	End If
	If mess.ContentType = "" Then mess.ContentType = CONTENT_TYPE_JSON
	If mess.ResponseData.IsInitialized = False Then mess.ResponseData.Initialize	
	' Override Status Code
	If mess.ResponseCode < 200 Or  mess.ResponseCode > 299 Then
		resp.Status = 200
	Else
		resp.Status = mess.ResponseCode
	End If
	resp.ContentType = mess.ContentType
	Dim Map1 As Map = CreateMap("s": mess.ResponseString, "a": mess.ResponseCode, "r": mess.ResponseData, "m": mess.ResponseMessage, "e": mess.ResponseError)
	resp.Write(Map2Json(Map1))
End Sub