#cs ----------------------------------------------------------------------------

 Author:         Trappar

 Script Function:
	Functions for running/compiling AutoIt scripts, and dealing with command line arguments

#ce ----------------------------------------------------------------------------

#include-once
#include <Array.au3>
#include <_Cmd.au3>

;===============================================================================
; Function Name:    _Script_Run()
; Description:      Runs an AutoIt3 script (or also any other program)
; Syntax.........:  _Script_Run($scriptPath, $outPath, $compileParams)
; Parameter(s):     $scriptPath    = Path to script to compile
; Parameter(s):     $params        = (OPTIONAL) Additional parameters to pass to the script
; Parameter(s):     $waitAfter     = (OPTIONAL) True|False wait for process to close before returning
; Parameter(s):     $workingdir    = (OPTIONAL) See Run() documentation for more information
; Parameter(s):     $show_flag     = (OPTIONAL) See Run() documentation for more information
; Parameter(s):     $opt_flag      = (OPTIONAL) See Run() documentation for more information
; Return Value(s):  See Run()/RunWait()
; Author:           JWay
;===============================================================================
Func _Script_Run($scriptPath, $params = "", $waitAfter = False, $workingdir = "", $show_flag = @SW_SHOW, $opt_flag = 0x0)
	If $workingdir = "" Then $workingdir = @ScriptDir

	_Cmd_CleanPath($scriptPath)

	If StringRegExp($scriptPath, '(?i)\.au3\z') Then
		$runStr = _Cmd_GetAutoitRunStr($scriptPath, $params, 'Run')
	Else
		$runStr = '"' & $scriptPath & '" ' & $params
	EndIf

	If $waitAfter Then
		Return RunWait($runStr, $workingdir, $show_flag, $opt_flag)
	Else
		Return Run($runStr, $workingdir, $show_flag, $opt_flag)
	EndIf
EndFunc   ;==>RunScript

;===============================================================================
; Function Name:    _Script_Compile()
; Description:      Compiles an AutoIt3 script
; Syntax.........:  _Script_Compile($scriptPath, $outPath, $compileParams)
; Parameter(s):     $scriptPath    = Path to script to compile
; Parameter(s):     $outPath       = Location to write compiled executable
; Parameter(s):     $compileParams = Additional parameters to pass to the compiler
; Return Value(s):  True  - Compilation produced a file
;                   False - Compilation must have failed
;                           (there is no file located at $outPath)
; Author:           JWay
;===============================================================================
Func _Script_Compile($scriptPath, $outPath, $compileParams = "")
	$runStr = _Cmd_GetAutoitRunStr($scriptPath, '', 'Compile') & ' /out "' & $outPath & '" ' & $compileParams

	RunWait($runStr, @ScriptDir)
	If FileExists($outPath) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CompileScript