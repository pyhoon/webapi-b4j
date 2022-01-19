B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=9.1
@EndOfDesignText@
' Help Handler class
' Version 1.11
Sub Class_Globals
	'Dim Request As ServletRequest
	Dim Response As ServletResponse
	Dim DocScripts As String
	Dim blnGenFile As Boolean = True 'ignore
End Sub

Public Sub Initialize

End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	'Request = req
	Response = resp
	ShowHelpPage
End Sub

Private Sub ShowHelpPage
	Dim strMain As String = Utility.ReadTextFile("main.html")
	Dim strView As String = Utility.ReadTextFile("help.html")
	Dim strContents As String
	Dim strScripts As String
	#if release
	If File.Exists(File.DirApp, "help.html") Then
		strContents = File.ReadString(File.DirApp, "help.html")
		strScripts = File.ReadString(File.DirApp, "help.js")
	End If
	#else
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
	strView = Utility.BuildDocScript(strView, strScripts)
	strMain = Utility.BuildView(strMain, strView)
	strMain = Utility.BuildHtml(strMain, Main.config)
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
'	IgnoredHandlers.Add("DefaultHandler")
	'IgnoredHandlers.Add("ProductHandler")
	
	Dim Handlers As List
	Handlers.Initialize
		
	Dim List1 As List
	List1 = File.ReadList(FileDir, FileName)
	For i = 0 To List1.Size - 1
		'Log(List1.Get(i))
		If List1.Get(i).As(String).Contains("srvr.AddHandler") Then
			Dim Line1 As String = List1.Get(i)
			Dim Section(3) As String = Regex.Split(",", Line1)
			If Section(0).StartsWith("'") Or Section(0).StartsWith("#") Then
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
	
	' Ignore List (not implemented)
	'Dim IgnoreList As List
	'IgnoreList.Initialize2(Array As String("Sub Class_Globals", _
	'"Public Sub Initialize", _
	'"Sub Handle (req As ServletRequest, resp As ServletResponse)"))
		
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

		strHtml = strHtml & GenerateHeaderByHandler (HandlerFile.As(String).Replace("Handler", ""))
		
		Dim List2 As List
		List2 = File.ReadList(FileDir, HandlerFile & ".bas")

		Dim Literals() As String
		
		For i = 0 To List2.Size - 1
			If List2.Get(i).As(String).StartsWith("'") Or List2.Get(i).As(String).StartsWith("#") Then
				' Ignore the line
			Else
				Dim index As Int = List2.Get(i).As(String).ToLowerCase.IndexOf("sub")
				If index > -1 Then
					Dim Line2 As String = List2.Get(i).As(String).SubString(index).Replace("Sub", "").Trim
					For Each SubMap As Map In VerbSubs
						For Each val As String In SubMap.Values
							For Each verb In verbs
								If val.ToUpperCase.EndsWith(verb) And Line2.ToUpperCase.StartsWith(verb) Then
									For Each key As List In SubMap.Keys
										'key.Add(Line2)
										' Check commented code in between and ignore the rest of the code
										If Line2.IndexOf("'") > -1 Then
											Line2 = Line2.Replace(Line2.SubString(Line2.IndexOf("'")), "")
											'Log(Line2)
										End If																														
										If Line2.Contains("(") Then ' take 1st occurence											
											Dim Arguments As String = Line2.SubString2(Line2.IndexOf("("), Line2.LastIndexOf(")")+1)
											'Log(Arguments)
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

										Dim MethodProperties As Map = CreateMap("Verb": verb, "Method": Line2, "Args": Arguments, "Prm": plist, "Body": "&nbsp;", "DESC1": "", "DESC2": "(N/A)", "Elems": 1)
										Methods.Add(MethodProperties)
									Next
								End If
							Next
						Next
					Next
				Else
					Dim Line3 As String = List2.Get(i).As(String)
				
					' Try get the Literals
					If Line3.ToLowerCase.Replace(" ", "").IndexOf("literals()asstring") > -1 Then
						Dim ps As Int = Line3.LastIndexOf("(") ' ps = index of last open parentheses, note: literal should not contain '(' character
						Dim pe As Int = Line3.LastIndexOf(")") ' pe = index of last close parentheses, just in case ) is not end character
						Dim strLiterals As String = Line3.SubString2(ps+1, pe)
						'Log(strLiterals)
						Literals = Regex.Split(",", strLiterals)
						' Clean up unwanted characters
						For e = 0 To Literals.Length - 1
							Literals(e) = Literals(e).Replace($"""$, "").Trim
							'Log(Literals(i))
						Next
					End If
				
					If Line3.IndexOf("'") > -1 Then
						'Log(List2.Get(i).As(String))
						' search for Body
						If Line3.ToLowerCase.IndexOf("#body") > -1 Then
							Dim body() As String
							body = Regex.Split("=", Line3)
							If body.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("Body", body(1).Trim)
							End If
						End If
						' search for Desc1
						If Line3.ToLowerCase.IndexOf("#desc1") > -1 Then
							Dim dc1() As String
							dc1 = Regex.Split("=", Line3)
							If dc1.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("DESC1", dc1(1).Trim)
							End If
						End If
						' search for Desc2
						If Line3.ToLowerCase.IndexOf("#desc2") > -1 Then
							Dim dc2() As String
							dc2 = Regex.Split("=", Line3)
							If dc2.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("DESC2", dc2(1).Trim)
							End If
						End If
						' Get # of elements in URL
						If Line3.ToLowerCase.IndexOf("#elems") > -1 Then
							Dim elems() As String
							elems = Regex.Split("=", Line3)
							If elems.Length = 2 Then
								Dim Map3 As Map = Methods.Get(Methods.Size-1)
								Map3.Put("Elems", elems(1).Trim)
							End If
						End If
					End If
				End If
			End If
		Next
				
		For Each m As Map In Methods
			'Log(m)
			Dim MM(2) As String
			MM = Regex.Split(" As ", m.Get("Method")) ' Ignore return type
			strHtml = strHtml & GenerateDocItem(m.Get("Verb"), MM(0).Trim, m.Get("Prm"), m.Get("Body"), m.Get("DESC1"), m.Get("DESC2"), Literals, m.Get("Elems"))
		Next

		' Retain this part for debugging purpose
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
		'	Log("DESC1: " & m.Get("DESC1"))
		'	Log("DESC2: " & m.Get("DESC2"))
		'Next
	Next
	
	#if debug
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

Public Sub GenerateLink (Literals() As String, Elems As Int, IDRequired As Boolean) As String
	Dim Link As String = Main.ROOT_PATH
	If Elems > 0 And Literals.Length > 0 Then
		If Elems Mod 2 = 0 Then
			Elems = Elems - 1 ' Elems = 2 is same as Elems = 1, Elems = 4 is same as Elems = 3
		End If
		Link = Link & Literals(0)
		If Elems > 2 Then
			Link = Link & "/" & Literals(1) & "/" & Literals(2)
		End If
		If IDRequired Then
			Link = Link & "/" & Literals(Elems)
		End If
	End If
	Return Link
End Sub

Public Sub GenerateResponseScript (Verb As String, btnButtonId As String) As String
	Dim strScript As String = $"
<script type="text/javascript">
$(document).ready(function() {
$("#${btnButtonId}").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "${Verb}",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(), // $(this).parent().serialize(), //$("form").serialize(), 
      success: function(data)
      {
       if (data.s == "ok" || data.s == "success") {
			var content = JSON.stringify(data.r, undefined, 2);
            $("#response"+id).val(content);
            $("#alert"+id).html(data.a+' '+data.m);
			$("#alert"+id).removeClass("alert-danger");
			$("#alert"+id).addClass("alert-success");			
            $("#alert"+id).fadeIn();
          }
          else {
		  	//console.log(data.e);
            $("#alert"+id).html(data.a+' '+data.e);
			$("#alert"+id).removeClass("alert-success");
			$("#alert"+id).addClass("alert-danger");			
            $("#alert"+id).fadeIn();
          }
        },
        error: function (xhr, ajaxOptions, thrownError) {
          $("#alert"+id).html('400 '+thrownError);
		  $("#alert"+id).removeClass("alert-success");
		  $("#alert"+id).addClass("alert-danger");		  
          $("#alert"+id).fadeIn();  
        }
      });
  });
});
</script>"$
	Return strScript
End Sub

Public Sub GenerateVerbSection (Verb As String, strColor As String, strButtonID As String, strLink As String, strDesc As String, strParams As String, strBody As String, strExpected As String, strInputDisabled As String, strDisabledBackground As String) As String
	'Log(Verb & " " & strLink)
	Dim strBgColor As String
	Select Case strColor.ToLowerCase
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

Public Sub GenerateDocItem (Verb As String, MethodName As String, Params As List, Body As String, Desc1 As String, Desc2 As String, Literals() As String, Elems As Int) As String
	Dim strHTML As String
	Dim strParams As String
	Dim strColor As String
	Dim strLink As String
	Dim strExpected As String = "200 Success"
	Dim strInputDisabled As String
	Dim strDisabledBackground As String = "#FFFFFF"
	Select Case Verb
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
	
	If Desc1 <> "(N/A)" Then
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
		strLink = GenerateLink(Literals, Elems, True)		
		'Log(strLink)
		strHTML = GenerateVerbSection(Verb, strColor, "btn" & MethodName & "1", strLink, Desc1, strParams, Body, strExpected, strInputDisabled, strDisabledBackground)
		DocScripts = DocScripts & GenerateResponseScript(Verb, "btn" & MethodName & "1")
	End If
	
	strParams = ""
	'strExpected = "200 Success"
	strInputDisabled = ""
	strDisabledBackground = "#FFFFFF"
	
	If Desc2 <> "(N/A)" Then
		If Params.Size > 1 Then
			For i = 0 To Params.Size - 2
				Dim pm() As String
				pm = Regex.Split(" As ", Params.Get(i))
				strParams = strParams & pm(0).Trim & " [" & pm(1).Trim & "]" & "<br/>"
			Next
		Else If Params.Size > 0 Then
			If Elems > 2 Then
				Dim pm() As String
				pm = Regex.Split(" As ", Params.Get(0))
				strParams = strParams & pm(0).Trim & " [" & pm(1).Trim & "]"
			Else
				strParams = "Not required"
				strInputDisabled = "disabled"
				strDisabledBackground = "#FFFF99"
			End If
		Else
			strParams = "Not required"
			strInputDisabled = "disabled"
			strDisabledBackground = "#FFFF99"
		End If
		strLink = GenerateLink(Literals, Elems, False)
		'Log(strLink)
		strHTML = strHTML & GenerateVerbSection(Verb, strColor, "btn" & MethodName & "2", strLink, Desc2, strParams, Body, strExpected, strInputDisabled, strDisabledBackground)
		DocScripts = DocScripts & GenerateResponseScript(Verb, "btn" & MethodName & "2")
	End If
	Return strHTML
End Sub