B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Help Handler class
' Version 1.16
Sub Class_Globals
	Dim Response As ServletResponse
	Dim DocScripts As String
	#If Debug
	Dim blnGenFile As Boolean = True
	#End If
End Sub

Public Sub Initialize

End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Response = resp
	ShowHelpPage
End Sub

Private Sub ShowHelpPage
	Dim strMain As String = Utility.ReadTextFile("main.html")
	Dim strView As String = Utility.ReadTextFile("help.html")
	Dim strContents As String
	Dim strScripts As String
	#If Release
	If File.Exists(File.DirApp, "help.html") Then
		strContents = File.ReadString(File.DirApp, "help.html")
		strScripts = File.ReadString(File.DirApp, "help.js")
	End If
	#Else
	' Assume only 1 b4j project file
	Dim ProjectFile As String
	Dim ProjectDirFiles As List = File.ListFiles(File.DirApp.Replace("\Objects", ""))
	If ProjectDirFiles.IsInitialized Then
		For Each f As String In ProjectDirFiles
			'Log(f)
			If f.EndsWith(".b4j") Then 
				ProjectFile = f
				Exit
			End If
		Next
	End If
	If ProjectFile = "" Then
		LogError("Unable to find B4J project file!")
		Utility.ReturnHTML($"<h1 style="color: red; text-align: center; margin-top: 30px">Unable to find B4J project file!</h1>"$, Response)
		Return
	End If
	If File.Exists(File.DirApp.Replace("\Objects", ""), ProjectFile) Then
		strContents = ReadProjectFile(File.DirApp.Replace("\Objects", ""), ProjectFile)
		strScripts = DocScripts
	End If
	#End If
	strView = Utility.BuildDocView(strView, strContents)
	strMain = Utility.BuildView(strMain, strView)
	strMain = Utility.BuildHtml(strMain, Main.config)
	If strScripts.Length > 0 Then
		strScripts = $"<script>
    $(document).ready(function () {
    ${strScripts}
    })
  </script>"$
  	Else
  		strScripts = ""
	End If
	strMain = Utility.BuildScript(strMain, strScripts)
	Utility.ReturnHTML(strMain, Response)
End Sub
	
Public Sub ReadProjectFile (FileDir As String, FileName As String) As String
	Dim strHtml As String
	Dim strPath As String = File.Combine(FileDir, FileName)
	Log(" ")
	Log("Generating Help page...")
	Log($"Reading project file (${strPath})..."$)
	
	Dim verbs(4) As String = Array As String("GET", "POST", "PUT", "DELETE")
	
	Dim IgnoredHandlers As List
	IgnoredHandlers.Initialize
	IgnoredHandlers.Add("HomeHandler")
	IgnoredHandlers.Add("HelpHandler")
	
	Dim Handlers As List
	Handlers.Initialize
		
	Dim List1 As List
	List1 = File.ReadList(FileDir, FileName)
	For i = 0 To List1.Size - 1
		If List1.Get(i).As(String).Contains("srvr.AddHandler") Then
			Dim Line1 As String = List1.Get(i)
			Dim Section(3) As String = Regex.Split(",", Line1)
			' 2022-05-11: bug (fixed) blank space before ' not trimmed
			If Section(0).Trim.StartsWith("'") Then
				'Log("Commented line: " & Section(1))
			Else
				If IgnoredHandlers.IndexOf(Section(1).Trim.Replace($"""$, "")) = -1 Then
					' Avoid duplicate items
					If Handlers.IndexOf(Section(1)) = -1 Then
						Handlers.Add(Section(1).Trim.Replace($"""$, ""))
					End If
				End If
			End If
		End If
	Next
			
	For Each HandlerFile In Handlers
		Dim Methods As List
		Methods.Initialize
				
		Dim SubStartsWithGet As List
		SubStartsWithGet.Initialize
	
		Dim SubStartsWithPost As List
		SubStartsWithPost.Initialize
	
		Dim SubStartsWithPut As List
		SubStartsWithPut.Initialize
	
		Dim SubStartsWithDelete As List
		SubStartsWithDelete.Initialize
	
		Dim VerbSubs As List
		VerbSubs.Initialize
		VerbSubs.Add(CreateMap(SubStartsWithGet: "SubStartsWithGet"))
		VerbSubs.Add(CreateMap(SubStartsWithPost: "SubStartsWithPost"))
		VerbSubs.Add(CreateMap(SubStartsWithPut: "SubStartsWithPut"))
		VerbSubs.Add(CreateMap(SubStartsWithDelete: "SubStartsWithDelete"))

		Dim EndPoint As String = HandlerFile.As(String).Replace("Handler", "")
		strHtml = strHtml & GenerateHeaderByHandler(EndPoint)
		
		Dim List2 As List
		List2 = File.ReadList(FileDir, HandlerFile & ".bas")
		
		For i = 0 To List2.Size - 1
			If List2.Get(i).As(String).StartsWith("'") Or List2.Get(i).As(String).StartsWith("#") Then
				' Ignore the line
			Else If List2.Get(i).As(String).Replace(TAB, "").ToLowerCase.Replace(" ", "").IndexOf("endpointasstring=") > -1 Then
				Dim strEndPoint() As String
				strEndPoint = Regex.Split("=", List2.Get(i).As(String))
				If strEndPoint.Length = 2 Then
					If Not(strEndPoint(0).Replace(TAB, "").Replace(" ", "").StartsWith("'")) Then
						EndPoint = strEndPoint(1)
						' Remove commented code
						If EndPoint.IndexOf("'") > -1 Then
							EndPoint = EndPoint.Replace(EndPoint.SubString(EndPoint.IndexOf("'")), "")
						End If
						' Clean up unwanted characters
						EndPoint = EndPoint.Replace($"""$, "").Trim
					End If
				End If
			Else
				Dim index As Int = List2.Get(i).As(String).ToLowerCase.IndexOf("sub")
				If index > -1 Then
					Dim Line2 As String = List2.Get(i).As(String).SubString(index).Replace("Sub", "").Trim
					For Each SubMap As Map In VerbSubs
						For Each val As String In SubMap.Values
							For Each verb In verbs
								If val.ToUpperCase.EndsWith(verb) And Line2.ToUpperCase.StartsWith(verb) Then
									For Each key As List In SubMap.Keys
										' Check commented code in between and ignore the rest of the code
										If Line2.IndexOf("'") > -1 Then
											Line2 = Line2.Replace(Line2.SubString(Line2.IndexOf("'")), "")
										End If
										If Line2.Contains("(") Then ' take 1st occurence
											Dim Arguments As String = Line2.SubString2(Line2.IndexOf("("), Line2.LastIndexOf(")")+1)
											Line2 = Line2.Replace(Arguments, "")
											Arguments = Arguments.Replace("(", "").Replace(")", "")
											Dim prm() As String
											prm = Regex.Split(",", Arguments)
											Dim plist As List
											plist.Initialize2(prm)
										Else
											Dim Arguments As String
											Dim plist As List
											plist.Initialize
										End If
										key.Add(Line2)
										
										Dim List4 As List
										List4.Initialize
										
										Dim MethodProperties As Map = CreateMap("Verb": verb, "Method": Line2, "Args": Arguments, "EndPoint": EndPoint.ToLowerCase, "Prm": plist, "Path": List4, "Body": "&nbsp;", "Desc": "&nbsp;")
										Methods.Add(MethodProperties)
									Next
								End If
							Next
						Next
					Next
				Else
					Dim Line3 As String = List2.Get(i).As(String)
			
					If Line3.IndexOf("'") > -1 Then
						' search for Desc
						If Line3.ToLowerCase.IndexOf("#desc") > -1 Then
							Dim desc() As String
							desc = Regex.Split("=", Line3)
							If desc.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("Desc", desc(1).Trim)
							End If
						End If
						
						' search for Path
						If Line3.ToLowerCase.IndexOf("#path") > -1 Then
							Dim path() As String
							path = Regex.Split("=", Line3)
							If path.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Dim List3 As List = path(1).Trim.As(JSON).ToList
								Map3.Put("Path", List3)
							End If
						End If
						
						' search for Body
						If Line3.ToLowerCase.IndexOf("#body") > -1 Then
							Dim body() As String
							body = Regex.Split("=", Line3)
							If body.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("Body", body(1).Trim)
							End If
						End If
					End If
				End If
			End If
		Next
				
		For Each m As Map In Methods
			Dim MM(2) As String
			MM = Regex.Split(" As ", m.Get("Method")) ' Ignore return type
			strHtml = strHtml & GenerateDocItem(m.Get("Verb"), MM(0).Trim, m.Get("EndPoint"), m.Get("Prm"), m.Get("Path"), m.Get("Desc"), m.Get("Body"))
		Next

		'' Retain this part for debugging purpose
		'For Each m As Map In Methods
		'	Log(" ")
		'	Log("[" & m.Get("Verb") & "]")
		'	Log(m.Get("Method"))
		'	Dim MM(2) As String
		'	MM = Regex.Split(" As ", m.Get("Method")) ' Ignore return type
		'	Log("(Trimmed) " & MM(0).Trim)
		'	Dim Lst As List
		'	Lst.Initialize
		'	Lst = m.Get("Prm")
		'	For i = 0 To Lst.Size - 1
		'		'Log("(" & i & ") " & Lst.Get(i))
		'		Dim pm() As String
		'		pm = Regex.Split(" as ", Lst.Get(i).As(String).ToLowerCase)
		'		Log(pm(0).Trim & " [" & pm(1).Trim & "]")
		'	Next
		'	Log("Desc: " & m.Get("Desc"))
		'	Log("EndPoint: " & m.Get("EndPoint"))
		'Next
	Next
	
	#If Debug
	' Save these files for Release/Production
	If blnGenFile Then
		If File.Exists(File.DirApp, "help.html") Then File.Delete(File.DirApp, "help.html")
		If File.Exists(File.DirApp, "help.js") Then File.Delete(File.DirApp, "help.js")
		Utility.WriteTextFile("help.html", strHtml)
		Utility.WriteTextFile("help.js", DocScripts)
	End If
	#End If
	Log($"Help page has been generated."$)
	Return strHtml
End Sub

Private Sub GenerateLink (EndPoint As String, Path As List) As String
	Dim Link As String = Main.ROOT_PATH & EndPoint
	For Each Element As String In Path
		Link = Link & IIf(Link.EndsWith("/"), "", "/") & Element
	Next
	Return Link
End Sub

Public Sub GenerateResponseScript (Verb As String, btnButtonId As String) As String
	Dim strScript As String = $"  $("#${btnButtonId}").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "${Verb}",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
"$
	Return strScript
End Sub

Public Sub GenerateVerbSection (Verb As String, strColor As String, strButtonID As String, strLink As String, strDesc As String, strParams As String, strBody As String, strExpected As String, strInputDisabled As String, strDisabledBackground As String) As String
	Dim strBgColor As String
	Select strColor.ToLowerCase
		Case "success"
			strBgColor = "#d4edda"
		Case "warning"
			strBgColor = "#fff3cd"
		Case "primary"
			strBgColor = "#cce5ff"
		Case "danger"
			strBgColor = "#f8d7da"
	End Select
	Dim strHtml As String = $"
		<button class="collapsible" style="background-color: ${strBgColor}"><span class="badge badge-${strColor} p-1">${Verb}</span> ${strLink}</button>
        <div class="details">
			<div class="row">
	            <div class="col-md-3 p-3">
	                <p>${strDesc}</p>
					<p><strong>Parameters</strong><br/>
	                Path: <label class="form-control" style="background-color: #FFFF99; font-size: small">${strParams}</label></p>
	                ${IIf(Verb.EqualsIgnoreCase("POST") Or Verb.EqualsIgnoreCase("PUT"), $"Body: <label class="form-control" style="background-color: #FFFF99; font-size: small">${strBody}</label></p>"$, $""$)}
					<p><strong>Response</strong><br/>
	                ${strExpected}</p>
	            </div>
	            <div class="col-md-3 p-3">
					<form id="form1" method="${Verb}">
	                <p>&nbsp;</p>
	                <p></p>
					<p><strong>Parameters</strong><br/>
	                Path: <input ${strInputDisabled} id="path${strButtonID}" class="form-control data-path" style="background-color: ${IIf(strInputDisabled.EqualsIgnoreCase("disabled"), strDisabledBackground, "#FFFFFF")}; font-size: small" value="${strLink}"></p>	                
					${IIf(Verb.EqualsIgnoreCase("POST") Or Verb.EqualsIgnoreCase("PUT"), $"Body: <textarea id="body${strButtonID}" rows="3" class="form-control data-body" style="background-color: #FFFFFF; font-size: small"></textarea></p>"$, $""$)}					
	                <button id="${strButtonID}" class="button btn-${strColor} col-md-3 p-2" style="cursor: pointer">Submit</button>
	            	</form><br/>
					<div id="alert${strButtonID}" class="alert alert-danger" role="alert" style="display: none">					  
					</div>					
				</div>
				<div class="col-md-3 p-3">
					<p>&nbsp;</p>
					<p><strong>Response</strong><br/>
					<textarea rows="8" id="response${strButtonID}" class="form-control" style="background-color: #202020; color: white; font-size: small"></textarea></p>
				</div>
			</div>
        </div>"$
	Return strHtml
End Sub

Public Sub GenerateHeaderByHandler (Header As String) As String
	Dim strHtml As String = $"
		<div class="row mt-3">
            <div class="col-md-12">
                <h6 class="text-uppercase text-primary"><strong>${Header}</strong></h6>
            </div>
		</div>"$
	Return strHtml
End Sub

Public Sub GenerateDocItem (Verb As String, MethodName As String, EndPoint As String, Params As List, Path As List, Desc As String, Body As String) As String
	Dim strHTML As String
	Dim strParams As String
	Dim strColor As String
	Dim strLink As String
	Dim strExpected As String = "200 Success"
	Dim strInputDisabled As String
	Dim strDisabledBackground As String = "#FFFFFF"
	Select Verb
		Case "GET"
			strColor = "success"
			strExpected = strExpected & "<br/>404 Not Found"
		Case "POST"
			strColor = "warning"
			strExpected = "201 Created"
		Case "PUT"
			strColor = "primary"
			strExpected = strExpected & "<br/>404 Not Found"
		Case "DELETE"
			strColor = "danger"
			strExpected = strExpected & "<br/>404 Not Found"
	End Select
	' Add other expected response
	strExpected = strExpected & "<br/>400 Bad Request"
	strExpected = strExpected & "<br/>422 Error Execute Query"
	
	' Ignore Method name
	'Log(MethodName)
	
	If Params.Size > 0 And Params.Get(0).As(String).Length > 0 Then
		For i = 0 To Params.Size - 1
			Dim pm() As String
			pm = Regex.Split(" As ", Params.Get(i))
			strParams = strParams & pm(0).Trim & " [" & pm(1).Trim & "]" & "<br/>"
		Next
	Else
		strParams = "Not required"
		strInputDisabled = "disabled"
	End If

	strLink = GenerateLink(EndPoint, Path)
	strHTML = GenerateVerbSection(Verb, strColor, "btn" & MethodName, strLink, Desc, strParams, Body, strExpected, strInputDisabled, strDisabledBackground)
	DocScripts = DocScripts & GenerateResponseScript(Verb, "btn" & MethodName)
	Return strHTML
End Sub