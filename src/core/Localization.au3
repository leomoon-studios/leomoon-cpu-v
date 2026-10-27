#include-once
Global $yy_txt, $nn_txt, $yn_txt, $yyb_txt, $wrong_txt, $osNoSupported_txt, $cpuNotSupported_txt
Global $tip01_txt, $tip02_txt, $tip03_txt, $tip04_txt, $tip05_txt, $tip06_txt, $tip07_txt, $tip_txt
Global $cpuArch_txt, $osArch_txt, $supported_txt, $enabled_txt, $oops_txt

Func _LocaleLanguage($sLocale)
	Switch StringLower($sLocale)
		Case '0804', '1004'
			Return 'CS'
		Case '0c04', '0404', '1404'
			Return 'CT'
		Case '0429'
			Return 'FA'
		Case Else
			Return 'EN'
	EndSwitch
EndFunc
Func _LocalizedText($sIniPath, $sLanguage, $sKey)
	Return IniRead($sIniPath, $sLanguage, $sKey, '')
EndFunc

Func _langLoad($resourceIni, $sLang)
	$yy_txt = _LocalizedText($resourceIni, $sLang, "Hardware Virtualization is supported, and is ENABLED.")
	$nn_txt = _LocalizedText($resourceIni, $sLang, "Hardware Virtualization is NOT supported.")
	$yn_txt = _LocalizedText($resourceIni, $sLang, "Hardware Virtualization is supported, but is DISABLED.")
	$yyb_txt = _LocalizedText($resourceIni, $sLang, "Hardware Virtualization is supported, but Trusted Execution is ENABLED.")
	$wrong_txt = _LocalizedText($resourceIni, $sLang, "Something went terribly wrong! Please check www.LeoMoon.com for more info.")
	$osNoSupported_txt = _LocalizedText($resourceIni, $sLang, "Your operating system is not supported. Please check www.LeoMoon.com for more info.")
	$cpuNotSupported_txt = _LocalizedText($resourceIni, $sLang, "LeoMoon CPU-V only supports Intel, AMD or VIA CPUs.")
	$tip01_txt = _LocalizedText($resourceIni, $sLang, "Virtualization Technology Benefits:")
	$tip02_txt = _LocalizedText($resourceIni, $sLang, "Enables VMMs to run 64-bit guest OSs.")
	$tip03_txt = _LocalizedText($resourceIni, $sLang, "Enables Virtual PC with Windows XP Mode in Windows 7.")
	$tip04_txt = _LocalizedText($resourceIni, $sLang, "Microsoft later released an update with KB977206")
	$tip05_txt = _LocalizedText($resourceIni, $sLang, "that allows XP-Mode to work without Virtualization.")
	$tip06_txt = _LocalizedText($resourceIni, $sLang, "Enabling Virtualization will improve performance of")
	$tip07_txt = _LocalizedText($resourceIni, $sLang, "applications running in virtual machines.")
	$tip_txt = $tip01_txt&@LF&@LF&$tip02_txt&@LF&$tip03_txt&@LF&@LF&$tip04_txt&@LF&$tip05_txt&@LF&@LF&$tip06_txt&@LF&$tip07_txt
	$cpuArch_txt = _LocalizedText($resourceIni, $sLang, "CPU Architecture")
	$osArch_txt = _LocalizedText($resourceIni, $sLang, "OS Architecture")
	$supported_txt = _LocalizedText($resourceIni, $sLang, "Supported")
	$enabled_txt = _LocalizedText($resourceIni, $sLang, "Enabled")
	$oops_txt = _LocalizedText($resourceIni, $sLang, "Oops!")
EndFunc
