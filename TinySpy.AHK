; inspired by "WinGet, another Window SPY" (http://www.autohotkey.com/forum/topic37645.html)
; Version History
; 1.01 (090512) : add process name
; 1.02 (090516) : add WM_NCHITTEST (SendMessage, 0x84) indicating the position of the cursor
; http://www.autohotkey.com/forum/topic16364.html
; http://msdn.microsoft.com/en-us/library/ms645618(VS.85).aspx
; CoordMode, Mouse, Screen	=> is needed to detect "explorer" title bar correctly

#SingleInstance,Force
#NoEnv
SetBatchLines, -1
SetTitleMatchMode, 2
CoordMode, Mouse, Screen
applicationName = TinySpy
applicationVer = 1.02

iconPath = ..\icon\1242288799_kghostview.ico
ifExist %iconPath%
Menu, Tray, Icon, %iconPath%

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

	SendMessage, 0x84,, ( y2 << 16 )|x2,, ahk_id %win_id%
	WM_NCHITTEST_Result =%ErrorLevel%

	WinGetTitle, win_title, ahk_id %win_id%
	WinGet, p_name, ProcessName, ahk_id %win_id%
	ControlGetText, ctrl_text, %ctrl_id%, ahk_id %win_id%

wingetclass, class, A
if class in CabinetWClass,ExploreWClass
{
	controlgettext, currentpath, Edit1, ahk_id %win_id%
}
	Lines = [Window] %win_title%`n[Process]  %p_name%`n[Control]  %ctrl_id%`n
	Lines .= "WM_NCHITTEST = " . WM_NCHITTEST_Result . "`n"
	Lines .= "PATH = " . currentpath . "`n"
	Lines .= "========== [Text] ==========`n" . ctrl_text

	GuiControl,, SpyInfo, %Lines%
	Return
