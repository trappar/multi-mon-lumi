#include <EnumDisplayMonitors.au3>
#include <Array.au3>
#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

;#NoTrayIcon


Global $CurMonitor = -1
Global $Monitors = _GetMonitors()
Global $Primary = FindPrimaryMonitor()
Global $MonitorCount = $Monitors[0][0]
Global $Overlays[$MonitorCount+1]
Global $MonitorLockFlag = 0
$Overlays[0] = $MonitorCount

;Win+Alt+L to lock the Current Screen as the active one
HotKeySet("#!l", "ToggleMonitorLock")

$Primary = $Overlays[$Primary]
$Timer = TimerInit()
While 1
    $CurMonitor = MouseGetMonitor(0)

    For $i = 1 To $MonitorCount
        If $i = $CurMonitor Then
            DeleteOverlay($i)
        Else
            CreateOverlay($i)
        EndIf
    Next

    While MouseInCurrentMonitor() OR $MonitorLockFlag
		Sleep(50)
		$hActive = WinGetHandle("")
		$TopInMonitors = WinActiveGetMonitors($hActive)
		If Not @error Then
			For $i = 1 to $TopInMonitors[0]
				If $i <> $CurMonitor Then
					WinSetOnTop($Overlays[$i], "", 1)
				EndIf
			Next
		EndIf
    WEnd
WEnd

Func ToggleMonitorLock()
	If ($MonitorLockFlag) Then
		$MonitorLockFlag = 0
	Else
		$MonitorLockFlag = 1
	EndIf
EndFunc

Func OverlayExists($Monitor)
	If IsHWnd($Overlays[$Monitor]) Then Return 1
	Return 0
EndFunc

Func DeleteOverlay($Monitor)
	If OverlayExists($Monitor) Then
		GUIDelete($Overlays[$Monitor])
		$Overlays[$Monitor] = 0
	EndIf
EndFunc

Func CreateOverlay($Monitor)
	If OverlayExists($Monitor) Then Return

	$x = $Monitors[$Monitor][1]
    $y = $Monitors[$Monitor][2]
    $w = $Monitors[$Monitor][3]-$x
    $h = $Monitors[$Monitor][4]-$y

	$hOverlay = GUICreate("", $w, $h, $x, $y, BitOR($WS_POPUP, $WS_MAXIMIZEBOX), BitOR($WS_EX_TOPMOST, $WS_EX_TRANSPARENT, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x00)
    WinSetTrans($hOverlay, "", 200)
    GUISetState(@SW_SHOWNOACTIVATE)
	WinSetOnTop($hOverlay, "", 1)
	$Overlays[$Monitor] = $hOverlay
EndFunc

Func IsWinOnTop($hWnd)
    If BitAND(_WinAPI_GetWindowLong($hWnd, $GWL_EXSTYLE), $WS_EX_TOPMOST) Then Return 1
    Return 0
EndFunc

Func WinActiveGetMonitors($hWnd)
	$aPos = WinGetPos($hWnd)
	If @error Then
		SetError(1)
		Return
	EndIf

	Local $InMonitor[$MonitorCount+1] = [$MonitorCount], $Pos[2]
	$grid = 3

	For $i = 0 to $grid
		For $j = 0 to $grid
			$Pos[0] = $aPos[0] + ($aPos[2] * ($i / $grid))
			$Pos[1] = $aPos[1] + ($aPos[3] * ($j / $grid))
			For $k = 1 to $MonitorCount
				If IsInBounds($Pos, $Monitors[$k][1], $Monitors[$k][2], $Monitors[$k][3], $Monitors[$k][4], 0) Then
					$InMonitor[$k] = 1
				EndIf
			Next
		Next
	Next

	Return $InMonitor
EndFunc

Func MouseGetMonitor($Bounds)
    Local $Monitor, $Pos

    $Pos = MouseGetPos()
    $Monitor = $CurMonitor

    For $i = 1 To $Monitors[0][0]
        If $i = $CurMonitor Then
            ContinueLoop
        EndIf

        If IsInBounds($Pos, $Monitors[$i][1], $Monitors[$i][2], $Monitors[$i][3], $Monitors[$i][4], $Bounds) Then
            $Monitor = $i
            ExitLoop
        EndIf
    Next

    Return $Monitor
EndFunc

Func IsInBounds($pos, $left, $top, $right, $bottom, $bounds)
    If ($pos[0] > $left + $bounds _
            And $pos[1] > $top + $bounds _
            And $pos[0] < $right - $bounds _
            And $pos[1] < $bottom - $bounds ) Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func MouseInCurrentMonitor()
    If MouseGetMonitor(10) = $CurMonitor Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func FindPrimaryMonitor()
    $pos = WinGetPos("[CLASS:Shell_TrayWnd]")
    $x = $pos[0]+($pos[2]/2)
    $y = $pos[1]+($pos[3]/2)
    Return _GetMonitorFromPoint($x, $y)
EndFunc