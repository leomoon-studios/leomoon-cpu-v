#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=resources\icon.ico
#AutoIt3Wrapper_Res_File_Add=resources\stripe.jpg, rt_rcdata, stripe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;#pragma compile(UPX, False)
;#pragma compile(x64, False)
#pragma compile(Compression, 9)
#pragma compile(Out, ..\build\LeoMoon CPU-V.exe)
#pragma compile(Comments, This program is freeware.)
#pragma compile(ProductName, LeoMoon CPU-V)
#pragma compile(FileDescription, LeoMoon CPU-V)
#pragma compile(FileVersion, 2.0.3.0)
#pragma compile(LegalCopyright, LeoMoon Studios)
#pragma compile(CompanyName, LeoMoon Studios)
#pragma compile(LegalTrademarks, LeoMoon Studios)
#pragma compile(ProductVersion, 2.0.3.0)

#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GDIPlus.au3>
#include <misc.au3>
#include <Memory.au3> ;CPU name
#include <resources\ResourcesEx.au3>

$override = 0

Global $pRemoteCode = _MemVirtualAlloc(0, 512, $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
Global $tCodeBuffer = DllStructCreate("byte[512]", $pRemoteCode)
Global $tBuffer = DllStructCreate("char[12]")
Global $pBuffer = DllStructGetPtr($tBuffer)
DllStructSetData($tCodeBuffer, 1, _
		"0x" & _
		"" & _; 10. SET eax AND CALL
		"B8" & SwapEndian(0) & _								 ; mov eax, 0
		"0FA2" & _											   ; cpuid
		"" & _ ; 20. ARRANGE DATA
		"891D" & SwapEndian($pBuffer) & _						; mov dword[$pBuffer], ebx
		"8915" & SwapEndian($pBuffer + 4) & _					; mov dword[$pBuffer + 4], edx
		"890D" & SwapEndian($pBuffer + 8) & _					; mov dword[$pBuffer + 8], ecx
		"" & _ ; 30. RETURN
		"C3" _
		)
$iRet = _RunAtAddress($pRemoteCode)
$tBuffer = DllStructCreate("char[48]")
$pBuffer = DllStructGetPtr($tBuffer)
DllStructSetData($tCodeBuffer, 1, _
		"0x" & _
		"" & _ ; 10. SET eax AND CALL
		"B8" & SwapEndian(0x80000002) & _						; mov eax, 0x80000002
		"0FA2" & _											   ; cpuid
		"" & _ ; 20. ARRANGE DATA
		"A3" & SwapEndian($pBuffer) & _						  ; mov dword[$pBuffer], eax
		"891D" & SwapEndian($pBuffer + 4) & _					; mov dword[$pBuffer + 4], ebx
		"890D" & SwapEndian($pBuffer + 8) & _					; mov dword[$pBuffer + 8], ecx
		"8915" & SwapEndian($pBuffer + 12) & _				   ; mov dword[$pBuffer + 12], edx
		"" & _ ; 30. SET eax AND CALL
		"B8" & SwapEndian(0x80000003) & _						; mov eax, 0x80000003
		"0FA2" & _											   ; cpuid
		"" & _ ; 40. ARRANGE DATA
		"A3" & SwapEndian($pBuffer + 16) & _					 ; mov dword[$pBuffer + 16], eax
		"891D" & SwapEndian($pBuffer + 20) & _				   ; mov dword[$pBuffer + 20], ebx
		"890D" & SwapEndian($pBuffer + 24) & _				   ; mov dword[$pBuffer + 24], ecx
		"8915" & SwapEndian($pBuffer + 28) & _				   ; mov dword[$pBuffer + 28], edx
		"" & _ ; 50. SET eax AND CALL
		"B8" & SwapEndian(0x80000004) & _						; mov eax, 0x80000004
		"0FA2" & _											   ; cpuid
		"" & _ ; 60. ARRANGE DATA
		"A3" & SwapEndian($pBuffer + 32) & _					 ; mov dword[$pBuffer + 32], eax
		"891D" & SwapEndian($pBuffer + 36) & _				   ; mov dword[$pBuffer + 36], ebx
		"890D" & SwapEndian($pBuffer + 40) & _				   ; mov dword[$pBuffer + 40], ecx
		"8915" & SwapEndian($pBuffer + 44) & _				   ; mov dword[$pBuffer + 44], edx
		"" & _ ; 70. RETURN
		"C3" _
		)
$iRet = _RunAtAddress($pRemoteCode)
Func _RunAtAddress($pCode)
	Local $aCall = DllCall("user32.dll", "dword_ptr", "CallWindowProcW", "ptr", $pCode, "ptr", 0, "dword", 0, "wparam", 0, "lparam", 0)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_RunAtAddress
Func SwapEndian($iValue, $iSize = 0)
	If $iSize Then
		Local $sPadd = "00000000"
		Return Hex(BinaryMid($iValue, 1, $iSize)) & StringLeft($sPadd, 2 * ($iSize - BinaryLen($iValue)))
	EndIf
	Return Hex(Binary($iValue))
EndFunc   ;==>SwapEndian

Global $virt, $slat, $vmme
Global $copyrightLbl, $mainFrm, $infoFrm, $appName = 'LeoMoon CPU-V', $appVer = '2.0.3'
Global $infoCoverLbl, $hImage, $hImage2, $hImage3, $hGraphic, $cpuGrp, $osGrp, $supportedGrp
Global $enabledGrp, $tip_txt, $cpuGrp, $depLbl, $slatLbl, $vmmeLbl

Global $yy_txt, $nn_txt, $yn_txt, $yyb_txt, $wrong_txt, $osNoSupported_txt, $cpuNotSupported_txt
Global $tip01_txt, $tip02_txt, $tip03_txt, $tip04_txt, $tip05_txt, $tip06_txt, $tip07_txt
Global $cpuArch_txt, $osArch_txt, $supported_txt, $enabled_txt, $oops_txt
Global $cpuName = 'x', $exitCode = '0'

$cpuName = StringStripWS(DllStructGetData($tBuffer, 1),4)

;copy resources
If FileExists(@TempDir&'\CPU-V.ini') Then FileSetAttrib(@TempDir&'\CPU-V.ini', '-R-A-S-H')
If FileExists(@TempDir&'\CPU-V.dll') Then FileSetAttrib(@TempDir&'\CPU-V.dll', '-R-A-S-H')
FileInstall('resources\CPU-V.ini',@TempDir&'\CPU-V.ini',1)
FileInstall('resources\CPU-V.dll',@TempDir&'\CPU-V.dll',1)

;get locale and dep
Local $objWMI, $strWMI_Query = "", $objWMI_QueryResult, $objWMI_Item, $dep, $locale
$objWMI = ObjGet('winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2')
If IsObj($objWMI) Then
    $strWMI_Query = 'SELECT Locale, DataExecutionPrevention_Available FROM Win32_OperatingSystem'
    $objWMI_QueryResult = $objWMI.ExecQuery($strWMI_Query, 'WQL')
    For $objWMI_Item In $objWMI_QueryResult
		$locale = $objWMI_Item.Locale
        $dep = $objWMI_Item.DataExecutionPrevention_Available
    Next
    $objWMI = 0
    $objWMI_QueryResult = 0
    $objWMI_Item = 0
EndIf

If $locale == '' Then $locale = '1033'
If $dep == '' Then $dep = False

;setting lang based on Locale
If $locale = "0804" Or $locale = "1004" Then
	$sLang = 'CS'
ElseIf $locale = "0c04" Or $locale = "0404" Or $locale = "1404" Then
	$sLang = 'CT'
ElseIf $locale = "0429" Then
	$sLang = 'FA'
Else
	$sLang = 'EN'
EndIf
If $override == 1 Then
	$sLang = 'FA' ;CS, CT, EN, FA
EndIf
_langLoad()

;Detect Archs
If @CPUArch == 'X64' Then
	$cpuArch = '64bit'
	$supportedLbl_msg = '1'
Else
	$cpuArch = '32bit'
	$supportedLbl_msg = '2'
EndIf
$osArch = @OSArch

;load original detection if win_7 or win_vista
If @OSVersion == 'WIN_7' Or @OSVersion == 'WIN_VISTA' Then
	;prepare havtool
	If FileExists(@TempDir&'\detecthav.sys') Then FileSetAttrib(@TempDir&'\detecthav.sys', '-R-A-S-H')
	If FileExists(@TempDir&'\havtool.exe') Then FileSetAttrib(@TempDir&'\havtool.exe', '-R-A-S-H')
	If @OSArch == 'X64' Then
		FileInstall('resources\64\detecthav.sys',@TempDir&'\detecthav.sys',1)
		FileInstall('resources\64\havtool.exe',@TempDir&'\havtool.exe',1)
		$exitCode = RunWait(@TempDir&'\havtool.exe /q')
		FileDelete(@TempDir&'\detecthav.sys')
		FileDelete(@TempDir&'\havtool.exe')
	ElseIf @OSArch == 'X86' Then
		FileInstall('resources\32\detecthav.sys',@TempDir&'\detecthav.sys',1)
		FileInstall('resources\32\havtool.exe',@TempDir&'\havtool.exe',1)
		$exitCode = RunWait(@TempDir&'\havtool.exe /q')
		FileDelete(@TempDir&'\detecthav.sys')
		FileDelete(@TempDir&'\havtool.exe')
	EndIf
	;change ui message
	If $exitCode == '0' Then
		$info = $yy_txt
		$supportedLbl_msg = '1'
		$enabledLbl_msg = '1'
	ElseIf $exitCode == '1' Then
		$info = $nn_txt
		$supportedLbl_msg = '2'
		$enabledLbl_msg = '2'
	ElseIf $exitCode == '2' Then
		$info = $yn_txt
		$supportedLbl_msg = '1'
		$enabledLbl_msg = '2'
	ElseIf $exitCode == '3' Then
		$info = $yyb_txt
		$supportedLbl_msg = '1'
		$enabledLbl_msg = '1'
	ElseIf $exitCode == '-1' Then
		MsgBox(0+48+4096, $oops_txt, $wrong_txt)
		Exit
	ElseIf $exitCode == '-2' Then
		MsgBox(0+48+4096, $oops_txt, $osNoSupported_txt)
		Exit
	ElseIf $exitCode == '-3' Then
		MsgBox(0+48+4096, $oops_txt, $cpuNotSupported_txt)
		Exit
	Else
		$info = $nn_txt
		$supportedLbl_msg = '2'
		$enabledLbl_msg = '2'
	EndIf
Else
	;get cpu name, virt, vmme, slat
	Local $objWMI, $strWMI_Query = "", $objWMI_QueryResult, $objWMI_Item, $cpuName, $virt, $vmme, $slat
	$objWMI = ObjGet('winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2')
	If IsObj($objWMI) Then
		$strWMI_Query = 'SELECT Name, VirtualizationFirmwareEnabled, VMMonitorModeExtensions, SecondLevelAddressTranslationExtensions FROM Win32_Processor'
		$objWMI_QueryResult = $objWMI.ExecQuery($strWMI_Query, 'WQL')
		For $objWMI_Item In $objWMI_QueryResult
			$cpuName = $objWMI_Item.Name
			$virt = $objWMI_Item.VirtualizationFirmwareEnabled
			$vmme = $objWMI_Item.VMMonitorModeExtensions
			$slat = $objWMI_Item.SecondLevelAddressTranslationExtensions
		Next
		$objWMI = 0
		$objWMI_QueryResult = 0
		$objWMI_Item = 0
	EndIf

	;change ui message
	If @CPUArch == 'X64' And $virt == 'True' Then
		$info = $yy_txt
		$supportedLbl_msg = '1'
		$enabledLbl_msg = '1'
	ElseIf @CPUArch == 'X64' And $virt == 'False' Then
		$info = $yn_txt
		$supportedLbl_msg = '1'
		$enabledLbl_msg = '2'
	ElseIf @CPUArch == 'X86' And $virt == 'False' Then
		$info = $nn_txt
		$supportedLbl_msg = '2'
		$enabledLbl_msg = '2'
	Else
		$info = $nn_txt
		$supportedLbl_msg = '2'
		$enabledLbl_msg = '2'
	EndIf
EndIf

;####################################################################
;###### OVERRIDE ####################################################
;####################################################################
If $override = 1 Then
	$info = $yy_txt
	$supportedLbl_msg = '1'
	$enabledLbl_msg = '1'
	$dep = 'True'
	$slat = 'True'
	$vmme = 'True'
EndIf

If $dep == 'True' Then
	$depSym = ChrW(Dec('2714'))
	$depClr = 0x004600
Else
	$depSym = ChrW(Dec('2716'))
	$depClr = 0xff0000
EndIf

If $slat == 'True' Then
	$slatSym = ChrW(Dec('2714'))
	$slatClr = 0x004600
Else
	$slatSym = ChrW(Dec('2716'))
	$slatClr = 0xff0000
EndIf

If $vmme == 'True' Then
	$vmmeSym = ChrW(Dec('2714'))
	$vmmeClr = 0x004600
Else
	$vmmeSym = ChrW(Dec('2716'))
	$vmmeClr = 0xff0000
EndIf

If StringInStr($cpuName, 'Intel') Then
	$vt = 'VT-x'
ElseIf StringInStr($cpuName, 'AMD') Then
	$vt = 'AMD-v'
ElseIf StringInStr($cpuName, 'VIA') Then
	$vt = 'VIA VT'
Else
	$vt = 'VT'
EndIf

Opt("GUIOnEventMode", 1) ;For multi GUI functions

If FileExists(@TempDir&'\lmcpuv.jpg') Then FileSetAttrib(@TempDir&'\lmcpuv.jpg', '-R-A-S-H')
FileInstall('resources\stripe.jpg',@TempDir&'\lmcpuv.jpg',1)

_mainGui()

Func _mainGui()
	#Region ### START Koda GUI section ### Form=C:\vtid-006.kxf
	$mainFrm = GUICreate($appName, 360, 358+17+17+17, -1, -1, BitOR($WS_SYSMENU, $WS_CAPTION, $WS_POPUP, $WS_POPUPWINDOW, $WS_BORDER, $WS_CLIPSIBLINGS))
	$bannerPic = GUICtrlCreatePic('', 0, 0, 362, 80)
	_Resource_SetToCtrlID($bannerPic, "stripe")
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onBtn")
	;$cpuNameLbl = GUICtrlCreateLabel(StringStripWS(DllStructGetData($tBuffer, 1),4), 102, 25, 270, 18)
	$appLbl	= GUICtrlCreateLabel($appname, 93, 24-6, 182, 25)
	GUICtrlSetBkColor(Default, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont(-1, 13, 800, 0, "Tahoma")
	GUICtrlSetColor(-1, 0xffffff)
	$verLbl = GUICtrlCreateLabel('v'&$appVer, 240, 30-7, 182, 25)
	GUICtrlSetBkColor(Default, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(Default, 0xffffff)
	GUICtrlSetFont(-1, 9, 400, 0, "Tahoma")
	$verLbl = GUICtrlCreateLabel($cpuName, 93, 48-6, 300, 17)
	GUICtrlSetBkColor(Default, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(Default, 0xffffff)
	GUICtrlSetFont(-1, 9, 400, 0, "Tahoma")
	$infoGrp = XSkinGroup("", 8, 85, 345, 25, 0x3e3d3d)
	$infoCoverLbl = GuiCtrlCreateIcon(@TempDir&'\CPU-V.dll', 3, 13, 95, 10, 10)
	;$infoCoverLbl = GUICtrlCreateLabel("", 13, 95, 10, 10)
	GUICtrlSetState(-1, $GUI_ONTOP+$GUI_FOCUS)
	GUICtrlSetOnEvent(-1, "_onBtn")
	;GUICtrlSetCursor(-1, 0)
	$infoLbl = GUICtrlCreateLabel($info, 26, 93, 345, 15)
	GUICtrlSetBkColor(Default, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont(-1, 8, 400, 0, "Tahoma")
	$cpuGrp = XSkinGroup("CPU Architecture", 8, 116, 169, 105, 0x3e3d3d)
	GUICtrlSetFont(-1, 9, 800, 0, "Tahoma")
	$cpuLbl = GUICtrlCreateLabel($cpuArch, 16, 140, 150, 61, $SS_CENTER)
	GUICtrlSetFont(-1, 35, 600, 0, "Tahoma")
	GUICtrlSetColor(-1, 0x555555)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	$osGrp = XSkinGroup("OS Architecture", 184, 116, 169, 105, 0x3e3d3d)
	GUICtrlSetFont(-1, 9, 800, 0, "Tahoma")
	$osLbl = GUICtrlCreateLabel($osArch, 192, 140, 150, 61, $SS_CENTER)
	GUICtrlSetFont(-1, 35, 600, 0, "Tahoma")
	GUICtrlSetColor(-1, 0x555555)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	$supportedGrp = XSkinGroup($vt&" Supported", 8, 226, 169, 105, 0x3e3d3d)
	GUICtrlSetFont(-1, 9, 800, 0, "Tahoma")
	GuiCtrlCreateIcon(@TempDir&'\CPU-V.dll', $supportedLbl_msg, 52+5, 250, 70, 70)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	$enabledGrp = XSkinGroup($vt&" Enabled", 184, 226, 169, 105, 0x3e3d3d)
	GUICtrlSetFont(-1, 9, 800, 0, "Tahoma")
	GuiCtrlCreateIcon(@TempDir&'\CPU-V.dll', $enabledLbl_msg, 230+3, 250, 70, 70)
	;GUICtrlCreateGroup("", -99, -99, 1, 1)
	$depLbl = GUICtrlCreateLabel($depSym&' Data Execution Prevention (DEP)', 8, 336, 345, 18, $SS_LEFT)
	GUICtrlSetFont(-1, 9, 400, 0, 'Tahoma')
	GUICtrlSetColor(-1, $depClr)
	$slatLbl = GUICtrlCreateLabel($slatSym&' Second Level Address Translation (SLAT)', 8, 336+17, 345, 17, $SS_LEFT)
	GUICtrlSetFont(-1, 9, 400, 0, 'Tahoma')
	GUICtrlSetColor(-1, $slatClr)
	$vmmeLbl = GUICtrlCreateLabel($vmmeSym&' VM Monitor Mode Extensions', 8, 336+17+17, 345, 18, $SS_LEFT)
	GUICtrlSetFont(-1, 9, 400, 0, 'Tahoma')
	GUICtrlSetColor(-1, $vmmeClr)
	$copyrightLbl = GUICtrlCreateLabel(ChrW(Dec('00A9'))&" LeoMoon Studios", 8, 336+17+17+17, 345, 17, $SS_RIGHT)
	GUICtrlSetFont(-1, 8.5, 400, 0, 'Tahoma')
	GUICtrlSetOnEvent(-1, "_onBtn")
	GUICtrlSetCursor(-1, 0)
	GUISetState(@SW_SHOW)
	If @OSVersion == 'WIN_7' Then ;hide unsupported fields if windows 7
		GUICtrlSetState($slatLbl, $GUI_DISABLE)
		GUICtrlSetState($vmmeLbl, $GUI_DISABLE)
	EndIf
	_langSet()

	#EndRegion ### END Koda GUI section ###

	While 1
		Sleep(200)
	WEnd
EndFunc

Func _onBtn()
	Switch @GUI_CTRLID
		Case $GUI_EVENT_CLOSE
			Exit
		Case $copyrightLbl
			ShellExecute('http://leomoon.com')
	EndSwitch
EndFunc

Func _langLoad()
	$yy_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Hardware Virtualization is supported, and is ENABLED.", "")
	$nn_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Hardware Virtualization is NOT supported.", "")
	$yn_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Hardware Virtualization is supported, but is DISABLED.", "")
	$yyb_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Hardware Virtualization is supported, but Trusted Execution is ENABLED.", "")
	$wrong_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Something went terribly wrong! Please check www.LeoMoon.com for more info.", "")
	$osNoSupported_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Your operating system is not supported. Please check www.LeoMoon.com for more info.", "")
	$cpuNotSupported_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "LeoMoon CPU-V only supports Intel, AMD or VIA CPUs.", "")
	$tip01_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Virtualization Technology Benefits:", "")
	$tip02_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Enables VMMs to run 64-bit guest OSs.", "")
	$tip03_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Enables Virtual PC with Windows XP Mode in Windows 7.", "")
	$tip04_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Microsoft later released an update with KB977206", "")
	$tip05_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "that allows XP-Mode to work without Virtualization.", "")
	$tip06_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Enabling Virtualization will improve performance of", "")
	$tip07_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "applications running in virtual machines.", "")
	$tip_txt = $tip01_txt&@LF&@LF&$tip02_txt&@LF&$tip03_txt&@LF&@LF&$tip04_txt&@LF&$tip05_txt&@LF&@LF&$tip06_txt&@LF&$tip07_txt
	$cpuArch_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "CPU Architecture", "")
	$osArch_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "OS Architecture", "")
	$supported_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Supported", "")
	$enabled_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Enabled", "")
	$oops_txt = IniRead(@TempDir&'\CPU-V.ini', $sLang, "Oops!", "")
EndFunc

Func _langSet()
	GUICtrlSetData($cpuGrp,$cpuArch_txt)
	GUICtrlSetData($osGrp,$osArch_txt)
	GUICtrlSetData($supportedGrp,$vt&' '&$supported_txt)
	GUICtrlSetData($enabledGrp,$vt&' '&$enabled_txt)
	GUICtrlSetTip($infoCoverLbl,$tip_txt)
	;_TipDisplayLen()
EndFunc

Func XSkinGroup($text, $Pleft, $Ptop, $Pwidth, $Pheight, $color)
	Local $XS_n, $PControl
	If StringInStr(@OSTYPE, "WIN32_NT") Then
		$XS_n = DllCall("uxtheme.dll", "int", "GetThemeAppProperties")
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", 0)
	EndIf
	$PControl = GUICtrlCreateGroup($text, $Pleft, $Ptop, $Pwidth, $Pheight)
	GUICtrlSetColor($PControl, $color)
	If StringInStr(@OSTYPE, "WIN32_NT") And IsArray($XS_n) Then
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", $XS_n[0])
	EndIf
	Return $PControl
EndFunc

Func _TipDisplayLen($time=30000)
    Local $tiphandles, $i
    $tiphandles=WinList('[CLASS:tooltips_class32]')
    for $i=1 to $tiphandles[0][0]
        If WinGetProcess($tiphandles[$i][1]) = @AutoItPID Then _SendMessage($tiphandles[$i][1],0x0403,2,$time)
    Next
EndFunc