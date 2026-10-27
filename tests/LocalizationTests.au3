#include "..\src\core\Localization.au3"

Local $aLocales = IniReadSection(@ScriptDir & '\fixtures\locales.ini', 'locales')
If @error Or Not IsArray($aLocales) Then Exit 1
Local $sIni = @ScriptDir & '\..\src\resources\CPU-V.ini'
Local $iFailures = 0
For $i = 1 To $aLocales[0][0]
	Local $sLanguage = _LocaleLanguage($aLocales[$i][0])
	If $sLanguage <> $aLocales[$i][1] Or _LocalizedText($sIni, $sLanguage, 'CPU Architecture') = '' Then
		ConsoleWrite('FAIL locale ' & $aLocales[$i][0] & @CRLF)
		$iFailures += 1
	EndIf
Next
If _LocaleLanguage('0C04') <> 'CT' Or _LocaleLanguage('unknown') <> 'EN' Then $iFailures += 1
If $iFailures Then Exit 1
ConsoleWrite('Localization tests passed.' & @CRLF)
