#include-once

; A negative result takes precedence over an unknown result when combining CPUs.
Global Enum $STATE_UNKNOWN = -1, $STATE_DISABLED = 0, $STATE_ENABLED = 1, $STATE_UNSUPPORTED = 2
Global Enum $CPU_NAME, $CPU_FIRMWARE, $CPU_VMME, $CPU_SLAT, $CPU_FIELD_COUNT

Func _ProbeBoolean($vValue)
	If Not IsBool($vValue) Then Return $STATE_UNKNOWN
	If $vValue Then Return $STATE_ENABLED
	Return $STATE_DISABLED
EndFunc

Func _CombineFeature($aRecords, $iField)
	If Not IsArray($aRecords) Or UBound($aRecords, 1) = 0 Then Return $STATE_UNKNOWN
	Local $iResult = $STATE_ENABLED
	For $i = 0 To UBound($aRecords, 1) - 1
		Local $iValue = _ProbeBoolean($aRecords[$i][$iField])
		If $iValue = $STATE_DISABLED Then Return $STATE_DISABLED
		If $iValue = $STATE_UNKNOWN Then $iResult = $STATE_UNKNOWN
	Next
	Return $iResult
EndFunc

; Unsupported wins, then unknown, then disabled; enabled requires every CPU enabled.
Func _VirtualizationResult($aRecords)
	If Not IsArray($aRecords) Or UBound($aRecords, 1) = 0 Then Return $STATE_UNKNOWN
	Local $iResult = $STATE_ENABLED
	For $i = 0 To UBound($aRecords, 1) - 1
		Local $iSupport = _ProbeBoolean($aRecords[$i][$CPU_VMME])
		Local $iFirmware = _ProbeBoolean($aRecords[$i][$CPU_FIRMWARE])
		If $iSupport = $STATE_DISABLED Then Return $STATE_UNSUPPORTED
		If $iSupport = $STATE_UNKNOWN Or $iFirmware = $STATE_UNKNOWN Then
			$iResult = $STATE_UNKNOWN
		ElseIf $iFirmware = $STATE_DISABLED And $iResult = $STATE_ENABLED Then
			$iResult = $STATE_DISABLED
		EndIf
	Next
	Return $iResult
EndFunc

Func _CpuName($aRecords)
	If IsArray($aRecords) Then
		For $i = 0 To UBound($aRecords, 1) - 1
			If IsString($aRecords[$i][$CPU_NAME]) And StringStripWS($aRecords[$i][$CPU_NAME], 3) <> '' Then Return StringStripWS($aRecords[$i][$CPU_NAME], 3)
		Next
	EndIf
	Return 'Unknown CPU'
EndFunc

Func _CpuVendorLabel($sName)
	If StringInStr($sName, 'Intel') Then Return 'VT-x'
	If StringInStr($sName, 'AMD') Then Return 'AMD-v'
	If StringInStr($sName, 'VIA') Then Return 'VIA VT'
	Return 'VT'
EndFunc
