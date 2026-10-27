#include "..\src\core\Localization.au3"

Local $aLocales[4][2] = [['0409', 'EN'], ['0804', 'CS'], ['0404', 'CT'], ['0429', 'FA']]
Local $sIni = @ScriptDir & '\..\src\resources\CPU-V.ini'
Local $iFailures = 0
For $i = 0 To UBound($aLocales) - 1
	Local $sLanguage = _LocaleLanguage($aLocales[$i][0])
	If $sLanguage <> $aLocales[$i][1] Or _LocalizedText($sIni, $sLanguage, 'CPU Architecture') = '' Then
		ConsoleWrite('FAIL locale ' & $aLocales[$i][0] & @CRLF)
		$iFailures += 1
	EndIf
Next
If _LocaleLanguage('0C04') <> 'CT' Or _LocaleLanguage('unknown') <> 'EN' Then $iFailures += 1
If $iFailures Then Exit 1
ConsoleWrite('Localization tests passed.' & @CRLF)
