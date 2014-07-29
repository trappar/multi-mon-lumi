#cs ----------------------------------------------------------------------------

 Author:         Trappar

 Script Function:
	Functions for dealing with command line arguments

#ce ----------------------------------------------------------------------------
#include-once

Func _Cmd_GetAutoitRunStr($program, $params, $action)
	$structure = RegRead("HKEY_CLASSES_ROOT\AutoIt3Script\Shell\" & $action & "\Command", "")
	$runStr = _Cmd_Structure($structure, '"' & $program & '" ' & $params)

	Return $runStr
EndFunc   ;==>GetAutoitCmdStr

Func _Cmd_CleanPath(ByRef $path)
	$path = StringRegExpReplace($path, '(\A[\s''"])|([\s''"]\z)', '')
EndFunc   ;==>CleanCmdPath

Func _Cmd_Structure($structure, $cmdLine)
	$params = _Cmd_SplitParams($cmdLine)
	$lastUsedValue = 0
	For $i = 1 To $params[0]
		$structure = StringReplace($structure, '%' & $i, $params[$i])
		If @extended > 0 Then
			$lastUsedValue = $i
		EndIf
	Next

	;Long path replacement (%l)
	$structure = StringReplace($structure, '%l', $params[1])

	;Wildcard replacement (%*)
	$wildcard = ""
	For $i = $lastUsedValue + 1 To $params[0]
		$wildcard &= $params[$i] & " "
	Next
	$wildcard = StringStripWS($wildcard, 3)
	$structure = StringReplace($structure, '%*', $wildcard)

	$structure = StringRegExpReplace($structure, '([''"]){2}', '\1')

	Return StringStripWS($structure, 3)
EndFunc   ;==>StructureCmd

Func _Cmd_SplitParams($cmdLine)
	Dim $output[1]
	While 1
		$matches = StringRegExp($cmdLine, '\A\s*((?:"[^"]*")|(?:''[^'']*'')|(?:[^ ]*))(?:\s*)(.*?)(?:\s*)\z', 3)
		_ArrayAdd($output, $matches[0])
		If StringLen($matches[1]) = 0 Then
			ExitLoop
		EndIf
		$cmdLine = $matches[1]
	WEnd
	$output[0] = UBound($output) - 1

	Return $output
EndFunc   ;==>_Script_SplitCmdParams