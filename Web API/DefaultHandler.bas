B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Default Handler class
' Version 1.16
Sub Class_Globals
	Private Elements() As String
	Private Response As ServletResponse
	Private EndPoint As String = "topics" 'ignore
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Response = resp
	
	Elements = Regex.Split("/", req.RequestURI)
	Dim FirstIndex As Int = Main.Element.First
	Dim SecondIndex As Int = Main.Element.Second
	Dim LastIndex As Int = Elements.Length - 1
	
	Select LastIndex
		Case FirstIndex
			GetDefaultTopic
		Case SecondIndex
			Dim SecondElement As String = Elements(SecondIndex)
			GetTopicFromSlug(SecondElement)
	End Select
End Sub

Public Sub GetDefaultTopic
	' #Desc = Return default topic
	Utility.ReturnSuccess(CreateMap("topic": "default"), 200, Response)
End Sub

Public Sub GetTopicFromSlug (slug As String)
	' #Desc = Return slug as topic
	' #Path = ["hello-world"]
	Utility.ReturnSuccess(CreateMap("topic": slug), 200, Response)
End Sub