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

include(objFs.BuildPath(strPathParent, "giipAgent.cfg"))

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

jGiipCnf = "{""sk"":""" & at & """,""lssn"":""" & lssn & """,""hn"":""" & hostname & """,""os"":""" & OSName & """}"

lwFileUpdate lwPathParent, fjGiipCnf, jGiipCnf

Sub ExecQue(lwPath, lwText)
	Dim lwFso, sAbsFileName, DT, sDT
	lwTmpFileName = "tmpScript." & lwScrType
	sAbsFileName = lwPath & "\" & lwTmpFileName
	lwTextSetLog = lwTmpFileName
	lwBatTmp = lwPath & "\lwTmpScriptExec.bat"

	Set lwFso = WScript.CreateObject("Scripting.FileSystemObject")

	if lwFso.fileexists(sAbsFileName) then
		lwFso.DeleteFile(sAbsFileName)
	end if
	if lwFso.fileexists(lwBatTmp) then
		lwFso.DeleteFile(lwBatTmp)
	end if
	' save Temp File
	lwLogFileWrite lwPath, lwTmpFileName, lwText
	lwLogFileWrite lwPath, "lwTmpScriptExec.bat", lwTextSetLog

	Select Case lwScrType
	Case "wsf"
		' runcmd = "cmd.exe /c start /min " & lwTmpFileName & " ^& exit"
		runcmd = "wscript //B //Nologo " & lwTmpFileName
		Set lwWSSRst = lwWsShell.Exec(runcmd)
		' Call lwWsShell.run(runcmd)
	Case "ps1"
		' replace powershell permission
		runcmd = "powershell.exe -Command ""Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force"""
		Set lwWSSRst = lwWsShell.Exec(runcmd)
		'Call lwWsShell.run(runcmd)

		runcmd = "powershell.exe """ & lwPath & "\" & lwTmpFileName & """"
		Set lwWSSRst = lwWsShell.Exec(runcmd)
		' Call lwWsShell.run(runcmd)
	Case else
		Set lwWSSRst = lwWsShell.Exec(runcmd)
		' Call lwWsShell.run(lwTmpFileName)
	End Select

	WScript.Sleep 10000

	Set wmi = GetObject("winmgmts://./root/cimv2")

	qry = "SELECT * FROM Win32_Process WHERE Name='wscript.exe' AND NOT " & _
      		"CommandLine LIKE '%" & Replace(WScript.ScriptFullName, "\", "\\") & "%'"

	For Each p In wmi.ExecQuery(qry)
	  p.Terminate
	Next

	if lwFso.fileexists(lwBatTmp) then
		lwFso.DeleteFile(lwBatTmp)
	end if
	if lwFso.fileexists(sAbsFileName) then
	'	lwFso.DeleteFile(sAbsFileName)
	end if

      Set lwFso = Nothing
End Sub

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

