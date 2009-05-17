; nPad - Toolbar interface to Lexikos' WindowPad 
; this is still a cooking version, welcome for comments ...

; http://www.autohotkey.com/forum/topic21703.html
; WindowPad - multi-monitor window-moving tool

; http://www.autohotkey.com/forum/topic44249.html
; transparent GUI over notepad
; http://www.autohotkey.com/forum/topic30300.html
; Add ToolTips to controls.

; ---- Known Issue ----
; GatherWindows : is it possible to Gather certain process, e.g. EmEditor and it's child window ...
; tollbar Z-order for window that partially covered by some window	
;	=> noActive or NA if possible overlap with some other window
; sometimes will not dock to un-activate window under

; ---- On Going ----
; problem to Dock on Always-on-top window ... (get flicker ...)	
;	=> looks OK so far
; detect the better location on title bar to dock by WM_NCHITTEST http://www.autohotkey.com/forum/topic22178.html
; 	Exclude list, more efficiently exclude tool menu and so on...
; 	need find how to exclude QtTabBar right-click context menu
;	=> looks OK seems those window will not have title bar property with WM_NCHITTEST
; how to exclude Desktop (ahk_class Progman) ?
;	=> looks OK so far, especially with WM_NCHITTEST
; (OK) disable docking, click tray icon to wake again

; ---- To Do ----
; conditionally disable some buttons based on window status
	; do not resize un-resizeable window
	; do not move un-moveable window
; if need implement "SetParent" or so ... http://www.autohotkey.com/forum/topic23240.html
; INI setting
; adjest pad boundry, e.g. 40/60 or 30/70 ..., but what's the proper user interface for this?
; Record Window position history for undo (maybe up to 10 or 20 records)
; more customized button

#SingleInstance, Force
#NoEnv
SetBatchLines, -1
SetTitleMatchMode, 2
CoordMode, Mouse, Screen

#include,nPad-init.ahk
#include,nPad-func.ahk

Goto, Main
gWindowPad:
#include,windowPad.ahk
return

main:

GoSub, gWindowPad

GuiToolBar=1
GuiPadMenu=20
GuiDebug=50

;Gui, 1:Default
Gui, %GuiToolBar%:Default
Gui, Font, Bold cFFFFFF
GUI, -SysMenu -Border +ToolWindow -Caption
GUI, margin, -1, -1
; GUI, Color, EEAA99, 0000FF

Menu, Tray, NoStandard
Menu, Tray, Add, Dock On, TrayClick
Menu, Tray, Add,
Menu, Tray, Standard
Menu, Tray, Default, Dock On
Menu, Tray, Click, 1

w_min=
nextX=0
nextY=0

Loop, Parse, btnOrder, `,, %A_Space%`t
{
	btnIdx := A_LoopField
	Label := lookupByIndex(btnIdx,"btn","Label")
	VarName := lookupByIndex(btnIdx,"btn","VarName")
	SubName := lookupByIndex(btnIdx,"btn","SubName")
	Option := lookupByIndex(btnIdx,"btn","Option")
	Hint := lookupByIndex(btnIdx,"btn","Hint")
	GuiOption = 

	GuiOption .= " hwnd" . VarName		; for Tooptip

	ifInstring,Option,Disabled
		GuiOption .= " Disabled"

	GuiOption .= " x" . nextX . " y" . nextY

	if VarName
		GuiOption .= " v" . VarName
	if SubName
		GuiOption .= " g" . SubName

	GUI, add, button, %GuiOption%, %Label%
	AddTooltip(%VarName%,Hint)

	GuiControlGet, thisBtn, Pos, %VarName%
	if (!w_min)
		w_min := thisBtnH

	if (thisBtnW < w_min)
	{
		GuiControl, Move, %VarName%, w%w_min%
		GuiControlGet, thisBtn, Pos, %VarName%
	}
	nextX := thisBtnX + thisBtnW - 1
}

GuiControlGet, lastBtn, Pos, %VarName%
ToolBarW := lastBtnX + lastBtnW
ToolBarH := lastBtnY + lastBtnH

GUI, Show, w%ToolBarW% h%ToolBarH% NoActive
Gui, +LastFound
ToolBar_ID := WinExist()

;winset, transcolor, EEAA99

HideToolBar()

btnBusy=

; ---- for debug only ----
	Gui, %GuiDebug%:Default
	Gui, Font, S11 CDefault
	Gui, Add, CheckBox, w200 h20 vifSpyOn gClickSpyOnOff Checked
	Gui, Add, CheckBox, xP+250 yP h20 vifAutoPath, Get Path (Alt-V T A)
	Gui, Add, Edit, xP-250 yp+30 w400 h300 vSpyInfo, no Data yet ...
	Gui, Show, , %applicationName% %applicationVer%

	Gui, +LastFound
	Debug_ID := WinExist()
	Gui, %GuiToolBar%:Default
	GoSub ClickSpyOnOff
	isDebug=1
;	isDebug=0
	SetTimer, GetSpyInfo, 250
; ---- debug session end ----

DockToID = 
goSub gCfg	
; start timer, this is for debug only, normal timer is remaked as the line below
;SetTimer, KeepDockToolBar, 200

return

gClose:
	SetTimer, KeepDockToolBar, Off
	HideToolBar()
	return
Close:
	ExitApp

TrayClick:
	isDebug=1
gCfg:
; ---- for debug only ----
	if (!isDebug) {
		isDebug=1
		GuiControl,,bCfg,!!
		AddTooltip(bCfg,"Debug On (Refresh 5 sec)")
		SetTimer, KeepDockToolBar, 5000
	} else {
		isDebug=0
		GuiControl,,bCfg,O
		AddTooltip(bCfg,"Debug Off")
		SetTimer, KeepDockToolBar, 200
	}
; ---- debug session end ----
	return

gMaxCross:
	btnBusy=1
;HideToolBar()
	this_id := DockTo_ID

	SysGet, m, MonitorCount
	; Iterate through all monitors.
	Loop, %m%
	{   ; Check if the window is on this monitor.
		SysGet, Mon, Monitor, %A_Index%

		if (A_index=1) {
			xx1 := MonLeft
			xx2 := MonRight
			yy1 := MonTop
			yy2 := MonBottom
			continue
		}
		xx1 := Math_min(xx1,MonLeft)
		xx2 := Math_max(xx2,MonRight)
		yy1 := Math_max(yy1,MonTop)
		yy2 := Math_min(yy2,MonBottom)
	}

	this_w := xx2-xx1
	this_h := yy2-yy1
	WinMove, ahk_id %this_id%,,xx1,yy1,this_w,this_h
;	WinActivate, ahk_id %this_id%
	btnBusy=
	return
gMov:
	btnBusy=1
;HideToolBar()
	this_id := DockTo_ID
	WindowScreenMove("Next,ahk_id " . this_id)
;	WinActivate, ahk_id %this_id%
	btnBusy=
	return
gMovMax:
	btnBusy=1
;HideToolBar()
	this_id := DockTo_ID
	WindowScreenMove("Next,ahk_id " . this_id)
	WinMaximize, ahk_id %this_id%
;	WinActivate, ahk_id %this_id%
	btnBusy=
	return
gGatP:
	btnBusy=1
	this_id := DockTo_ID
	WinActivate, ahk_id %this_id%
	WinWaitActive, ahk_id %this_id%
	GatherWindows("A")
	WinActivate, ahk_id %this_id%
	btnBusy=
	return
gGatM:
	btnBusy=1
	GatherWindows("M")
	btnBusy=
	return
gGoPad:
	GuiControlGet, mainBtn, Pos, %A_GuiControl%
	this_id := DockTo_ID
	ShowPadMenu(ToolBarX+mainBtnX,ToolBarY+mainBtnY+mainBtnH)
	return
gSetPad:
gRecPad:
gMore:
	this_id := DockTo_ID
	WinActivate, ahk_id %this_id%
	Return

gSelectPad:
	btnBusy=1
	p1 := RegExMatch(A_GuiControl, "PadBtn\K(?P<label>\d+)", this_)

	if (this_label) {
;	action := padAction%this_Label%
;		this_param := substr(padAction%this_Label%,strLen("WindowPadMove, "))
		p2 := RegExMatch(padAction%this_Label%, "(WindowPadMove,)\K(?P<param>.*)",this_)
		WindowPadMove(this_param ",ahk_id " . this_id)
	}
	btnBusy=
	return

HideToolBar()
{
	local isVisible

	GuiControlGet, isVisible, Visible, %VarName%
	if (isVisible) {
		GUI, -AlwaysOnTop
		GUI, Show, x10000 y0 NA
		Gui, Cancel
	}
}

KeepDockToolBar:

	if btnBusy
		return

	if PadMenu_ID
		ifWinNotActive, ahk_id %PadMenu_ID%
		{
			Gui,%GuiPadMenu%:Default
			Gui,Cancel
			Gui,%GuiToolBar%:Default
			PadMenu_ID=
		}

	CoordMode, Mouse, Screen

	MouseGetPos, MouseX ,MouseY , win_id, ctrl_id

	winGetclass, class2, ahk_id %win_id%

	if (!Win_ID)
	{
		HideToolBar()
		return
	}

	if (win_id=ToolBar_ID) OR (win_id=PadMenu_ID) {
		GUI, +AlwaysOnTop
		return
	} 

	WinGetPos, ToolBarX, ToolBarY, ToolBarW, ToolBarH, ahk_id %ToolBar_ID%

	SurveyDockPos("DockWin_",x2,y1,"ahk_id " . win_ID)

	if !x2 
	{
		HideToolBar()
		return
	}

	oldwin_id := DockTo_ID
	DockTo_ID := win_id

	x1 := x2 - ToolBarW
	y2 := y1 + ToolBarH

	if (DockWin_ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
	{
		GUI, +AlwaysOnTop

		if (x1<>ToolBarX) OR (y1<>ToolBarY) {
			ToolBarX := x1
			ToolBarY := y1
			GUI, Show, x%ToolBarX% y%ToolBarY% NA
		}
		return
	}

	ifWinActive, ahk_id %DockTo_ID%
	{
		GUI, +AlwaysOnTop

		if (x1<>ToolBarX) OR (y1<>ToolBarY) {
			ToolBarX := x1
			ToolBarY := y1
			GUI, Show, x%ToolBarX% y%ToolBarY% NA
		}
		return
	} 

	SafeOnTop = 1

	dd:=1
;	win2 := DllCall( "WindowFromPoint", Int,x1-dd  , Int,y1-dd )
	win1 := DllCall( "WindowFromPoint", Int,x2+dd  , Int,y1-dd )
;	win3 := DllCall( "WindowFromPoint", Int,x2+dd  , Int,y2+dd )
;	win4 := DllCall( "WindowFromPoint", Int,x1-dd  , Int,y2+dd )

	Loop,1
	{
		if (win%A_Index% <> DockTo_ID)
			SafeOnTop =
	}

	if !SafeOnTop
	{
		DockTo_ID := oldwin_id
		HideToolBar()
		return
	}

	GUI, -AlwaysOnTop
	if (x1<>ToolBarX) OR (y1<>ToolBarY) {
		ToolBarX := x1
		ToolBarY := y1
		GUI, Show, x%ToolBarX% y%ToolBarY% NA
		return
	}


return

ShowPadMenu(xx,yy)
{
	local x1, y1, btnIdx, Label, Hint, VarName

	Gui, %GuiPadMenu%:Default
	Gui, Destroy
	Gui, Font, Bold
	GUI, -SysMenu -Border +ToolWindow -Caption
	GUI, margin, -1, -1

	x1=0
	y1=0
	Loop, Parse, padOrder, `,, %A_Space%`t
	{
		btnIdx := A_LoopField
		Label := lookupByIndex(btnIdx,"pad","Label")
		Hint := lookupByIndex(btnIdx,"pad","Hint")
		VarName := "PadBtn" . Label

		GuiOption := " x" . x1 . " y" . y1 . " w29 h29 ggSelectPad"
		GuiOption .= " v" . varName
		GuiOption .= " hwnd" . VarName

		GUI, add, button, %GuiOption%, %Label%
		AddTooltip(%VarName%,Hint)

		if mod(A_index,3)=0
		{
			x1 = 0
			y1 += 30
		} else
			x1 += 30
	}
	Gui, Show, x%xx% y%yy%

	Gui, +LastFound
	PadMenu_ID := WinExist()
	Gui, %GuiToolBar%:Default
	return
}

SurveyDockPos(Result, ByRef x, ByRef y, win_id)
{
	local eX, eY, eW, eH, x2, y2, dx, x0, x1, ExStyle

	WinGetPos, eX, eY, eW, eH, %win_id%
	WinGet, ExStyle, ExStyle, %win_ID%

	dx := 5
	x2 := eX + eW - dx
	y2 := eY + 15
	%Result%ifResize=
	%Result%ifMinimize=
	%Result%ifClose=
	%Result%haveTitle=
	%Result%ExStyle := ExStyle
	x0 =
	x1 =

	Loop
	{
		SendMessage, 0x84,, ( y2 << 16 )|x2,, %win_id%
		WM_NCHITTEST_Result =%ErrorLevel%

		if WM_NCHITTEST_Result = 2
			%Result%haveTitle:=1
		else {
			x0 = 
			if WM_NCHITTEST_Result = 8
				%Result%ifMinimize:=1
			else if WM_NCHITTEST_Result = 9
				%Result%ifResize:=1
			else if WM_NCHITTEST_Result = 20
				%Result%ifClose:=1
		}
		if (%Result%haveTitle)
		{
			if !x0
				x0 := x2
			if (x0) {
				x1 := x2
				if (x0-x1)>100
					break
			}
		}
		x2 -= dx
		if x2 <= %eX% 
			break
	}
	if (x1) {
		x := x0-5
		y := eY+5
	} else {
		x=
		y=
	}
	return
}


; ---- for debug only ----
GetSpyInfo:

	GetSpyInfo()
	return

GetSpyInfo()
{
	local lines, MouseX, MouseY, win_ID, win_title, p_name, class, ctrl_id

Lines =

Lines .= "=> " Win_ID+0 . "`n"

win_id := DockTo_ID

WinGetTitle, win_title, ahk_id %win_id%
WinGet, p_name, ProcessName, ahk_id %win_id%
;ControlGetText, ctrl_text, %ctrl_id%, ahk_id %win_id%
winGetclass, class, ahk_id %win_id%

Lines .= "[Window] " . win_title "`n[Process]  " . p_name . "`n[Control]  " ctrl_id . "`n"
Lines .= "[Class]  " . class  . " / " class2  "`n"
Lines .= "WM_NCHITTEST = " . WM_NCHITTEST_Result . "`n"
; Lines .= "PATH = '" . currentpath . "'`n"
; Lines .= "========== [Text] ==========`n" . ctrl_text

Gui, %GuiDebug%:Default
GuiControl,, SpyInfo, %Lines%
Gui, %GuiToolBar%:Default

	Return
}

ClickSpyOnOff:
Gui, %GuiDebug%:Default
	Gui, Submit, NoHide
	if ifSpyOn
	{
		Gui, +AlwaysOnTop
		GuiControl, Text, ifSpyOn, Spy ON (Always on Top)
	}
	else
	{
		Gui, -AlwaysOnTop
		GuiControl, Text, ifSpyOn, Spy off
	}
	GuiControl, Focus, SpyInfo
Gui, %GuiToolBar%:Default
	return

; ---- debug session end ----
