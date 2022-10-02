B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Default Handler class
' Version 1.15
Sub Class_Globals
	Private Literals() As String = Array As String("topic", "hello-world") 'ignore
	Private Elements() As String
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Response = resp
	
	Elements = Regex.Split("/", req.RequestURI)
	If Elements.Length-1 = Main.Element.Second Then
		GetTestSub(Elements(Main.Element.Second))
	Else
		GetTestSub("")
	End If
End Sub

Public Sub GetTestSub (slug As String)
	' #Desc1 = Return hello-world topic
	' #Desc2 = Return default topic
	If slug = "" Then
		Utility.ReturnSuccess(CreateMap("topic": "B4X (default)"), 200, Response)
	Else
		Utility.ReturnSuccess(CreateMap("topic": slug), 200, Response)
	End If
End Sub