B4J=true
Group=Modules
ModulesStructureVersion=1
Type=StaticCode
Version=8.1
@EndOfDesignText@
' Utility Code module
' Version 1.09
Sub Process_Globals
	Private const CONTENT_TYPE_JSON As String = "application/json"
	Private const CONTENT_TYPE_HTML As String = "text/html"
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

Public Sub ReadMapFile (FileDir As String, FileName As String) As Map
	Dim strPath As String = File.Combine(FileDir, FileName)
	Log($"Reading file (${strPath})..."$)
	Return File.ReadMap(FileDir, FileName)
End Sub

Public Sub ReadTextFile (FileName As String) As String
	Return File.ReadString(File.DirAssets, FileName)
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
		LogDebug($"${mdl} "$ & LastException)
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
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Write(Map2Json(CreateMap("s": "ok", "m": "success", "r": Result, "e": Null)))
End Sub

Public Sub ReturnError (Error As String, Code As Int, resp As ServletResponse)
	If Error = "" Then Error = "unknown"
	Dim Result As List
	Result.Initialize
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Status = Code
	resp.Write(Map2Json(CreateMap("s": "error", "m": Null, "r": Result, "e": Error)))
End Sub

Public Sub ReturnSuccess (Data As Map, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	Dim Result As List
	Result.Initialize
	Result.Add(Data)
	Dim Map1 As Map = CreateMap("s": "ok", "m": "success", "r": Result, "e": Null)
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Status = Code
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnSuccess2 (Data As List, Code As Int, resp As ServletResponse)
	If Data.IsInitialized = False Then Data.Initialize
	Dim Map1 As Map = CreateMap("s": "ok", "m": "success", "r": Data, "e": Null)
	resp.ContentType = CONTENT_TYPE_JSON
	resp.Status = Code
	resp.Write(Map2Json(Map1))
End Sub

Public Sub ReturnLocation (Location As String, resp As ServletResponse) ' Code = 302
	resp.SendRedirect(Location)
End Sub