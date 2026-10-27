#include-once
#include "WindowsProbe.au3"

; Return one row per processor; a failed or empty query leaves no records.
Func _CpuProbe(ByRef $aRecords, $oService = Default)
	Local $aEmpty[0][$CPU_FIELD_COUNT]
	$aRecords = $aEmpty
	Local $oError = ObjEvent('AutoIt.Error', '_ProbeComError')
	If IsKeyword($oService) Then $oService = ObjGet('winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2')
	If Not IsObj($oService) Then Return False
	Local $oResults = $oService.ExecQuery('SELECT Name, VirtualizationFirmwareEnabled, VMMonitorModeExtensions, SecondLevelAddressTranslationExtensions FROM Win32_Processor', 'WQL')
	If Not IsObj($oResults) Then Return False
	Local $iCount = 0
	For $oItem In $oResults
		ReDim $aRecords[$iCount + 1][$CPU_FIELD_COUNT]
		$aRecords[$iCount][$CPU_NAME] = $oItem.Name
		$aRecords[$iCount][$CPU_FIRMWARE] = $oItem.VirtualizationFirmwareEnabled
		$aRecords[$iCount][$CPU_VMME] = $oItem.VMMonitorModeExtensions
		$aRecords[$iCount][$CPU_SLAT] = $oItem.SecondLevelAddressTranslationExtensions
		$iCount += 1
	Next
	Return $iCount > 0
EndFunc
