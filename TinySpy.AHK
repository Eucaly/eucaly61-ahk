; inspired by "WinGet, another Window SPY" (http://www.autohotkey.com/forum/topic37645.html)
; 090512 : add process name

#SingleInstance,Force
#NoEnv
SetBatchLines, -1
SetTitleMatchMode, 2
applicationName = TinySpy
applicationVer = 1.01

Menu, Tray, Icon, ..\icon\1242288799_kghostview.ico

Gui, Font, S11 CDefault
Gui, Add, CheckBox, w350 h20 vifSpyOn gClickSpyOnOff Checked
Gui, Add, Edit, w400 h300 vSpyInfo, no Data yet ...
Gui, Show, , %applicationName% %applicationVer%

; Need +LastFound to make WinExist() to return window id of GUI itself
Gui, +LastFound
GUI_ID := WinExist()

; set Spy update period
SetTimer, GetSpyInfo, 250

; config Spy ON/off (and also config AlwaysOnTop or not) according to "ifSpyOn" checkbox,
ClickSpyOnOff:
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
	return

GuiClose:
	ExitApp

GetSpyInfo:
	Gui, Submit, NoHide
	if !ifSpyOn
		return
	MouseGetPos,x2 ,y2 , win_id, ctrl_id

; Not Spy on GUI itself
	if ( win_id = GUI_ID )
		Return

	WinGetTitle, win_title, ahk_id %win_id%
	WinGet, p_name, ProcessName, ahk_id %win_id%
	ControlGetText, ctrl_text, %ctrl_id%, ahk_id %win_id%
	GuiControl,, SpyInfo, [Window]  %win_title%`n[Process] %p_name%`n[Control]  %ctrl_id%`n========== [Text] ==========`n%ctrl_text%
	Return
