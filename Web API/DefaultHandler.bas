B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Default Handler class
' Version 1.10
Sub Class_Globals
	Dim Literals() As String = Array As String("topic", ":slug") 'ignore
	Dim Elements() As String
	Dim Response As ServletResponse
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Response = resp
	
	Elements = Regex.Split("/", req.RequestURI)
	If Elements.Length-1 = Main.Element.Parent_Id Then
		GetTestSub(Elements(Main.Element.Parent_Id))
	Else
		GetTestSub("")
	End If
End Sub

Public Sub GetTestSub (slug As String)
	' #Desc2=Return default topic
	If slug = "" Then
		Utility.ReturnSuccess(CreateMap("topic": "B4X (default)"), 200, Response)
	Else
		Utility.ReturnSuccess(CreateMap("topic": slug), 200, Response)
	End If
End Sub