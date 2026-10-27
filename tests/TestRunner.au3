; Each suite runs in a fresh interpreter; no desktop or hardware probe is started.
Local $aSuites[3] = ['VirtualizationResultTests.au3', 'LocalizationTests.au3', 'FixtureTests.au3']
Local $iFailures = 0
For $sSuite In $aSuites
	Local $sCommand = '"' & @AutoItExe & '" /ErrorStdOut "' & @ScriptDir & '\' & $sSuite & '"'
	Local $iExit = RunWait($sCommand, @ScriptDir, @SW_HIDE)
	If @error Or $iExit <> 0 Then
		ConsoleWrite('FAIL ' & $sSuite & ' (exit ' & $iExit & ')' & @CRLF)
		$iFailures += 1
	Else
		ConsoleWrite('PASS ' & $sSuite & @CRLF)
	EndIf
Next
If $iFailures Then
	ConsoleWrite($iFailures & ' suite(s) failed.' & @CRLF)
	Exit 1
EndIf
ConsoleWrite('All regression suites passed.' & @CRLF)
