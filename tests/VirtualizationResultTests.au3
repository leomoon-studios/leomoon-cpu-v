#include "..\src\core\CpuProbe.au3"

Global $iFailures = 0
Local $aCpu[1][$CPU_FIELD_COUNT]
$aCpu[0][$CPU_NAME] = ' Intel processor '
$aCpu[0][$CPU_VMME] = True
$aCpu[0][$CPU_FIRMWARE] = True
$aCpu[0][$CPU_SLAT] = True
_Assert('enabled', _VirtualizationResult($aCpu), $STATE_ENABLED)
_Assert('Intel', _CpuVendorLabel(_CpuName($aCpu)), 'VT-x')
_Assert('AMD', _CpuVendorLabel('AMD Ryzen'), 'AMD-v')
_Assert('other CPU', _CpuVendorLabel('Other'), 'VT')
$aCpu[0][$CPU_FIRMWARE] = False
_Assert('disabled', _VirtualizationResult($aCpu), $STATE_DISABLED)
$aCpu[0][$CPU_VMME] = False
_Assert('unsupported', _VirtualizationResult($aCpu), $STATE_UNSUPPORTED)
$aCpu[0][$CPU_VMME] = Null
_Assert('missing support', _VirtualizationResult($aCpu), $STATE_UNKNOWN)
$aCpu[0][$CPU_VMME] = True
$aCpu[0][$CPU_FIRMWARE] = Null
_Assert('missing firmware', _VirtualizationResult($aCpu), $STATE_UNKNOWN)
$aCpu[0][$CPU_SLAT] = Null
_Assert('missing feature', _CombineFeature($aCpu, $CPU_SLAT), $STATE_UNKNOWN)
ReDim $aCpu[2][$CPU_FIELD_COUNT]
$aCpu[1][$CPU_VMME] = True
$aCpu[1][$CPU_FIRMWARE] = False
$aCpu[1][$CPU_SLAT] = False
_Assert('unknown dominates disabled', _VirtualizationResult($aCpu), $STATE_UNKNOWN)
_Assert('negative feature dominates unknown', _CombineFeature($aCpu, $CPU_SLAT), $STATE_DISABLED)
$aCpu[0][$CPU_FIRMWARE] = True
_Assert('disabled across processors', _VirtualizationResult($aCpu), $STATE_DISABLED)
$aCpu[1][$CPU_FIRMWARE] = True
_Assert('enabled across processors', _VirtualizationResult($aCpu), $STATE_ENABLED)
$aCpu[0][$CPU_FIRMWARE] = Null
$aCpu[1][$CPU_VMME] = False
_Assert('unsupported dominates unknown', _VirtualizationResult($aCpu), $STATE_UNSUPPORTED)
Local $aEmpty[0][$CPU_FIELD_COUNT]
_Assert('empty processors', _VirtualizationResult($aEmpty), $STATE_UNKNOWN)
_Assert('missing name', _CpuName($aEmpty), 'Unknown CPU')
Local $aFailed, $sLocale, $iDep
_Assert('failed CPU service', _CpuProbe($aFailed, 0), False)
_Assert('failed CPU is unknown', _VirtualizationResult($aFailed), $STATE_UNKNOWN)
_Assert('failed OS service', _WindowsProbe($sLocale, $iDep, 0), False)
_Assert('failed OS DEP', $iDep, $STATE_UNKNOWN)
_Assert('failed OS locale', $sLocale, '1033')
Local $oInvalidService = ObjCreate('Scripting.Dictionary')
_Assert('failed CPU query', _CpuProbe($aFailed, $oInvalidService), False)
_Assert('failed OS query', _WindowsProbe($sLocale, $iDep, $oInvalidService), False)
If $iFailures Then
	ConsoleWrite($iFailures & ' test(s) failed.' & @CRLF)
	Exit 1
EndIf
ConsoleWrite('Virtualization result tests passed.' & @CRLF)

Func _Assert($sName, $vActual, $vExpected)
	If $vActual <> $vExpected Then
		ConsoleWrite('FAIL ' & $sName & ': got ' & $vActual & ', expected ' & $vExpected & @CRLF)
		$iFailures += 1
	EndIf
EndFunc
