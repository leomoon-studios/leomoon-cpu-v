#include "..\src\core\CpuProbe.au3"
#include "..\src\core\Localization.au3"
#include "..\src\core\AppInfo.au3"

Local $sFixture = @ScriptDir & '\fixtures\probes.ini'
Local $aCases = StringSplit('enabled,disabled,unsupported,missing', ',')
Local $iFailures = 0
For $i = 1 To $aCases[0]
	Local $sCase = $aCases[$i], $aCpu[1][$CPU_FIELD_COUNT]
	$aCpu[0][$CPU_NAME] = IniRead($sFixture, $sCase, 'name', '')
	$aCpu[0][$CPU_FIRMWARE] = _FixtureBoolean(IniRead($sFixture, $sCase, 'firmware', 'missing'))
	$aCpu[0][$CPU_VMME] = _FixtureBoolean(IniRead($sFixture, $sCase, 'vmme', 'missing'))
	$aCpu[0][$CPU_SLAT] = _FixtureBoolean(IniRead($sFixture, $sCase, 'slat', 'missing'))
	If _VirtualizationResult($aCpu) <> Number(IniRead($sFixture, $sCase, 'result', '999')) Then
		ConsoleWrite('FAIL fixture: ' & $sCase & @CRLF)
		$iFailures += 1
	EndIf
Next
Local $aFailed, $oService = ObjCreate('Scripting.Dictionary')
If IniRead($sFixture, 'failed', 'service', '') <> 'invalid' Or _CpuProbe($aFailed, $oService) Or _VirtualizationResult($aFailed) <> Number(IniRead($sFixture, 'failed', 'result', '999')) Then $iFailures += 1
If Not StringRegExp($APP_VERSION, '^\d+\.\d+\.\d+$') Or $APP_TITLE = '' Then $iFailures += 1
If $iFailures Then Exit 1
ConsoleWrite('Probe fixture and app version tests passed.' & @CRLF)

Func _FixtureBoolean($sValue)
	Switch $sValue
		Case '1'
			Return True
		Case '0'
			Return False
		Case Else
			Return Null
	EndSwitch
EndFunc
