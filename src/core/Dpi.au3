#include-once

; Preserve AutoIt's DPI-unaware layout while Windows renders GDI text and
; controls at display resolution. Windows before 10 1809 lacks this mode.
Func _EnableGdiScaling()
	Local $aResult = DllCall('user32.dll', 'bool', 'SetProcessDpiAwarenessContext', 'ptr', -5)
	If Not @error And IsArray($aResult) And $aResult[0] Then Return True
	$aResult = DllCall('user32.dll', 'handle', 'SetThreadDpiAwarenessContext', 'ptr', -5)
	If @error Or Not IsArray($aResult) Or Not $aResult[0] Then Return False
	Return True
EndFunc
