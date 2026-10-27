#include <ScreenCapture.au3>
#include <File.au3>
#include "..\src\core\AppInfo.au3"
; Run manually on a Windows desktop, after building the application.
; Optional arguments: executable path, and "mock-cs" for the Step 4 mock fixture.
Local $sExe = @ScriptDir & '\..\build\LeoMoon CPU-V.exe'
If $CmdLine[0] >= 1 Then $sExe = $CmdLine[1]
Local $aBefore = _FileListToArray(@TempDir, 'cpu-v-*', 2)
Local $iPid = Run('"' & $sExe & '"', @ScriptDir)
If Not $iPid Then
	ConsoleWrite('FAIL: application did not start' & @CRLF)
	Exit 1
EndIf
Local $hWindow = 0
For $i = 1 To 100
	Local $aWindows = WinList('LeoMoon CPU-V')
	For $j = 1 To $aWindows[0][0]
		If WinGetProcess($aWindows[$j][1]) = $iPid Then $hWindow = $aWindows[$j][1]
	Next
	If $hWindow Then ExitLoop
	If Not ProcessExists($iPid) Then ExitLoop
	Sleep(100)
Next
If Not $hWindow Then
	ConsoleWrite('FAIL: application window did not appear' & @CRLF)
	If ProcessExists($iPid) Then ProcessClose($iPid)
	Exit 1
EndIf
Sleep(1000)
ConsoleWrite('Window text:' & @CRLF & WinGetText($hWindow) & @CRLF)
Local $sText = WinGetText($hWindow)
If Not StringInStr($sText, $APP_TITLE) Or Not StringInStr($sText, 'v' & $APP_VERSION) Then
	ConsoleWrite('FAIL: application title or version label is missing' & @CRLF)
	WinClose($hWindow)
	Exit 1
EndIf
If $CmdLine[0] >= 2 And $CmdLine[2] = 'mock-cs' Then
	Local $sExpected = IniRead(@ScriptDir & '\..\src\resources\CPU-V.ini', 'CS', 'Hardware Virtualization is supported, but is DISABLED.', '')
	If $sExpected = '' Or Not StringInStr($sText, $sExpected) Or Not StringInStr($sText, 'Mock AMD CPU') Then
		ConsoleWrite('FAIL: mock CPU or localized disabled status missing' & @CRLF)
		WinClose($hWindow)
		Exit 1
	EndIf
	ConsoleWrite('Mock disabled result and CS locale displayed.' & @CRLF)
EndIf
Local $aDuring = _FileListToArray(@TempDir, 'cpu-v-*', 2), $sResourceDir = ''
If IsArray($aDuring) Then
	For $i = 1 To $aDuring[0]
		Local $bOld = False
		If IsArray($aBefore) Then
			For $j = 1 To $aBefore[0]
				If $aBefore[$j] = $aDuring[$i] Then $bOld = True
			Next
		EndIf
		If Not $bOld Then $sResourceDir = @TempDir & '\' & $aDuring[$i]
	Next
EndIf
If $sResourceDir = '' Or Not FileExists($sResourceDir & '\CPU-V.ini') Or Not FileExists($sResourceDir & '\CPU-V.dll') Then
	ConsoleWrite('FAIL: private resources were not found' & @CRLF)
	WinClose($hWindow)
	Exit 1
EndIf
ConsoleWrite('Private INI and DLL exist while running.' & @CRLF)
_ScreenCapture_CaptureWnd(@ScriptDir & '\..\build\desktop-check.png', $hWindow)
WinClose($hWindow)
ProcessWaitClose($iPid, 10)
If ProcessExists($iPid) Then
	ConsoleWrite('FAIL: window did not close' & @CRLF)
	Exit 1
EndIf
If FileExists($sResourceDir) Then
	ConsoleWrite('FAIL: private resource directory remains after exit' & @CRLF)
	Exit 1
EndIf
ConsoleWrite('Window closed and private resources were removed.' & @CRLF)
