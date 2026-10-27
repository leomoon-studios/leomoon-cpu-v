#include-once
#include "VirtualizationResult.au3"

; The caller may inject a WMI service for testing. COM failures become unknown values.
Func _WindowsProbe(ByRef $sLocale, ByRef $iDep, $oService = Default)
	$sLocale = '1033'
	$iDep = $STATE_UNKNOWN
	Local $oError = ObjEvent('AutoIt.Error', '_ProbeComError')
	If IsKeyword($oService) Then $oService = ObjGet('winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2')
	If Not IsObj($oService) Then Return False
	Local $oResults = $oService.ExecQuery('SELECT Locale, DataExecutionPrevention_Available FROM Win32_OperatingSystem', 'WQL')
	If Not IsObj($oResults) Then Return False
	Local $bFound = False
	For $oItem In $oResults
		$bFound = True
		Local $vLocale = $oItem.Locale, $vDep = $oItem.DataExecutionPrevention_Available
		If IsString($vLocale) And $vLocale <> '' Then $sLocale = $vLocale
		$iDep = _ProbeBoolean($vDep)
		ExitLoop
	Next
	Return $bFound
EndFunc

Func _ProbeComError($oError)
	; AutoIt would otherwise terminate on a failed WMI property or query.
EndFunc
