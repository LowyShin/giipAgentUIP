' -------------------------------------------------------------
' Authorized by Lowy at 20200302
' -------------------------------------------------------------

' Initialize
'On Error Resume Next
scrver = "1.00"
' User Variables 

dim objfs:set objfs = createobject("scripting.filesystemobject"):sub include(p):executeglobal objfs.OpenTextfile(p).readall:end sub
dim strScriptPath

strScriptPath = objfs.GetParentFolderName(WScript.ScriptFullName)
strPathParent = mid(strScriptPath, 1, instrRev(strScriptPath, "\"))

Set lwFso = CreateObject("Scripting.FileSystemObject")
if lwFso.FileExists(strPathParent & "\giipAgent.cfg") then
	include(objFs.BuildPath(strPathParent, "giipAgent.cfg"))
else
	msgbox "Can not read giipAgent.cfg, check the file exists. If don't have, you need copy giipAgent.cfg to parent directory." & vbCRLF & " See https://github.com/LowyShin/giipAgentUIP"
end if

strComputer = "." 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
' OS ====================================================
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
	OSName = objItem.Caption
	HostName = objItem.CSName
Next

' -------------------------------------------------------------
' System Variables
lwURLAPI = "https://giipasp.azurewebsites.net/api/cqe/cqequeueget04.asp?sk={{sk}}&lssn={{lssn}}&hn=" & hostname & "&os=" & OSName & "&df=os&sv=" & scrver
lwURLKVS = "https://giipasp.azurewebsites.net/api/kvs/kvsput.asp?sk={{sk}}&type=lssn&key={{lssn}}&factor={{factor}}&value={{kvsval}}"
lwLogFileName = "giipAgent_" & SetDtToStr(now(), "YYYYMMDD") & ".log"
fjGiipCnf = "giipAgent.json"

' -------------------------------------------------------------
' Processing Variables
Set lwWsShell = CreateObject("WScript.Shell")
lwPath= lwWsShell.CurrentDirectory
lwPathParent= mid(lwPath, 1, instrRev(lwPath, "\"))
lwURLAPI = replace(lwURLAPI, "{{sk}}", at)
lwURLAPI = replace(lwURLAPI, "{{lssn}}", lsSn)
lwURLKVS = replace(lwURLKVS, "{{sk}}", at)
lwURLKVS = replace(lwURLKVS, "{{lssn}}", lsSn)

Set lwFso = CreateObject("Scripting.FileSystemObject")
if lwFso.FileExists(strPathParent & "\giipAgent.cfg") then

	jGiipCnf = "{" & vbCRLF & _
		"	""sk"":""" & at & """" & vbCRLF & _
		"	,""lssn"":""" & lssn & """" & vbCRLF & _
		"	,""hn"":""" & hostname & """" & vbCRLF & _
		"	,""os"":""" & OSName & """" & vbCRLF & _
		"	,""iv"":""" & iv & """" & vbCRLF & _
		"}"

	lwFileUpdate lwPathParent, fjGiipCnf, jGiipCnf
	lwDelTmp lwPath
else
end if

Sub lwLogFileWrite(sPath, sFileName, sContent)
      Set lwFso = CreateObject("Scripting.FileSystemObject")
      if lwFso.FileExists(sPath & "\" & sFileName) then
            set lwLogFile = lwFso.opentextfile(sPath & "\" & sFileName, 8, true)
      else
            set lwLogFile =  lwFso.createtextfile(sPath & "\" & sFileName, true)
      end if

      lwLogFile.Write sContent
      lwLogFile.close
End Sub

Sub lwFileUpdate(sPath, sFileName, sContent)
	Set lwFso = CreateObject("Scripting.FileSystemObject")
	if lwFso.FileExists(sPath & "\" & sFileName) then
		with lwFso.GetFile(sPath & "\" & sFileName).OpenAsTextStream
			lwFileBody = .ReadAll
			.close
		end with
		if lwFileBody <> sContent then
			lwFso.DeleteFile(sPath & "\" & sFileName)
			set lwFile =  lwFso.createtextfile(sPath & "\" & sFileName, true)
			lwFile.Write sContent
			lwFile.close
		end if
	else
		set lwFile =  lwFso.createtextfile(sPath & "\" & sFileName, true)
		lwFile.Write sContent
		lwFile.close
	end if
End Sub

Function lwGetHTTP(url, meth, fv, charset, output)
 Dim xmlHttp
 Set xmlHttp = CreateObject("MSXML2.serverXMLHTTP")
 xmlHttp.Open meth, url, False
	if charset = "utf-8" then
		xmlHttp.setRequestHeader "Content-Type", " text/html; charset=utf-8"
	else
		xmlHttp.setRequestHeader "Content-Type", " text/html"
	end if
 'xmlHttp.setRequestHeader "Content-Length", "length"
 if fv = empty then
   xmlHttp.Send
 else
   xmlHttp.Send fv
 end if
 txtData = xmlHttp.responseText
 htmlData = xmlHttp.responsebody
	if output = "html" then
		lwGetHTTP = htmlData
	else
		lwGetHTTP = txtData
	end if
End Function

Sub lwDelTmp(sPath)
	Dim lwFso, lwFolder, lwFile
	Set lwFso = WScript.CreateObject("Scripting.FileSystemObject")
	Set lwFolder = lwFso.GetFolder(sPath)
	Set lwFiles = lwFolder.Files
	For Each File In lwFiles
		ModDate = File.DateLastModified
		lwFileName = File.Name
		if instr(lwFileName, "giipTmp") > 0 then
			lwFso.DeleteFile(sPath & "\" & File.Name)
		end if
	Next

	Set lwFile = Nothing
	Set lwFolder = Nothing
	Set lwFso = Nothing
End Sub

Function SetDtToStr(dt, date_type)

      Dim mydate
      date_type = Ucase(date_type)
      if isdate(dt) then

            hour12 = hour(dt)
            if cint(hour12) > 12 then
                  hour12 = hour12 - 12
            end if
            mydate = replace (date_type, "YYYY", year(dt))
            mydate = replace (mydate, "YY", right(year(dt), 2))
            mydate = replace (mydate, "MM", right("0" & month(dt),2))
            mydate = replace (mydate, "DD", right("0" & day(dt),2))
            mydate = replace (mydate, "HH24", right("0" & hour(dt),2))
            mydate = replace (mydate, "HH", hour12)
            mydate = replace (mydate, "MI", right("0" & minute(dt),2))
            mydate = replace (mydate, "SS", right("0" & second(dt),2))

      else
     
            mydate = "1999/01/01 00:00:00"
     
      end if

      SetDtToStr = mydate

End Function

