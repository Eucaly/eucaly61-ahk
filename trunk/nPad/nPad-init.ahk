btnOrder = 1,4,9,2,8,3,5,6,7,11
btnList = Label, VarName, SubName, Option, Hint
btn1 = !!,	bCfg,	gCfg,	,	Debug ...
;btn1 = O,	bCfg,	gCfg,	,	Option ...
btn2 = [...],	bRecPad,	gRecPad,	Disabled,	Pad Setting ...
btn3 = ><,	bGatP,	gGatP,	,	Gather This Window
btn4 = @,	bGatM,	gGatM,	,	Gather All Windows
btn5 = >,	bMov,	gMov,	w,	Move to next Monitor
btn6 = [>],	bMovMax,	gMovMax,	,	Maximize to next Monitor
btn7 = [<>],	bMaxCross,	gMaxCross,	,	Maximize across Desktop
btn8 = -|-,	bGoPad,	gGoPad,	,	Pad Move ...
btn9 = [2x2],	bSetPad,	gSetPad,	Disabled,	Set Pad (1x1 ~ 3x3)
btn10 = ...,	bMore, gMore, Disabled,	More ...
btn11 = x,	bClose, gClose, ,	Close this Menu

padOrder = 7,8,9,4,5,6,1,2,3
padList = Label, Hint
pad1 = 1, Left-Down
pad2 = 2, Down
pad3 = 3, Right-Doen
pad4 = 4, Left
pad5 = 5, Center
pad6 = 6, Right
pad7 = 7, Left-Up
pad8 = 8, Down
pad9 = 9, Right-Up
padAction1 = WindowPadMove, -1, +1,  0.5, 0.5
padAction2 = WindowPadMove,  0, +1,  1.0, 0.5
padAction3 = WindowPadMove, +1, +1,  0.5, 0.5
padAction4 = WindowPadMove, -1,  0,  0.5, 1.0
padAction5 = WindowPadMove,  0,  0,  0.5, 1.0
padAction6 = WindowPadMove, +1,  0,  0.5, 1.0
padAction7 = WindowPadMove, -1, -1,  0.5, 0.5
padAction8 = WindowPadMove,  0, -1,  1.0, 0.5
padAction9 = WindowPadMove, +1, -1,  0.5, 0.5

Loop,Parse,btnList,`,,%A_Space%`t
{
	SetValue("btn",A_LoopField,A_Index)
}
;dumpAll("btn")

Loop
{
	if (!btn%A_Index%)
		break
	btn0 := A_Index
	StringSplit,btn%A_Index%_,btn%A_Index%,`,,%A_Space%`t
}

Loop,Parse,padList,`,,%A_Space%`t
{
	SetValue("pad",A_LoopField,A_Index)
}

Loop
{
	if (!pad%A_Index%)
		break
	pad0 := A_Index
	StringSplit,pad%A_Index%_,pad%A_Index%,`,,%A_Space%`t
}

