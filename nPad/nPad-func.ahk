
AddToolTip(con,text,Modify = 0){
  Static TThwnd,GuiHwnd
  If (!TThwnd){
    Gui,+LastFound
    GuiHwnd:=WinExist()
    TThwnd:=CreateTooltipControl(GuiHwnd)
  }
  Varsetcapacity(TInfo,44,0)
  Numput(44,TInfo)
  Numput(1|16,TInfo,4)
  Numput(GuiHwnd,TInfo,8)
  Numput(con,TInfo,12)
  Numput(&text,TInfo,36)
  Detecthiddenwindows,on
  If (Modify){
    SendMessage,1036,0,&TInfo,,ahk_id %TThwnd%
  }
  Else {
    Sendmessage,1028,0,&TInfo,,ahk_id %TThwnd%
    SendMessage,1048,0,300,,ahk_id %TThwnd%
  }
 
}

CreateTooltipControl(hwind){
  Ret:=DllCall("CreateWindowEx"
          ,"Uint",0
          ,"Str","TOOLTIPS_CLASS32"
          ,"Uint",0
          ,"Uint",2147483648 | 3
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",hwind
          ,"Uint",0
          ,"Uint",0
          ,"Uint",0)
         
  Return Ret
}

Math_min(a1="", a2="", a3="", a4="", a5="", a6="", a7="", a8="")
{
	b:=a1
	n:=2
	Loop
	{
		c:=a%n%
		if (c="")
			break
		if (c<b)
			b := c
		n++
	}
	return b
}

Math_max(a1="", a2="", a3="", a4="", a5="", a6="", a7="", a8="")
{
	b:=a1
	n:=2
	Loop
	{
		c:=a%n%
		if (c="")
			break
		if (c>b)
			b := c
		n++
	}
	return b
}

dumpAll(main)
{
	global
	tt_all := main . "_all"
	tt_all_value := %tt_all%
	tt_temp_value =
	loop,Parse,tt_all_value,`,,%A_Space%
	{
		tt_temp := A_LoopField
		tt_temp_value := tt_temp_value . tt_temp . "=" . %tt_temp% . "`n"
	}
msgbox, % tt_temp_value
}


setValue(main,field="",data="")
{
	global
	tt_temp := main . "_". field
	tt_all := main . "_all"
	if (%tt_all%)
		%tt_all% := %tt_all% . ","
	%tt_temp% := data
	%tt_all% := %tt_all% . tt_temp
}

getName(main,field="")
{
	global
	tt_temp := main . "_" . field

	return %tt_temp%
}

getValue(main,field="")
{
	global
	tt_temp := main . "_" . field
	tt_all := main . "_all"
	tt_temp_value := %tt_temp%

	return %tt_temp_value%
}

lookupByIndex(index,main,field)
{
	a=%main%%Index%
	return GetValue(a,GetValue(main,field))
}

lookupBy(By_field,By_value,main,field)
{
	b := getValue(main,By_field)
	loop, % %main%0
	{
		a = %main%%A_Index%
		index := A_Index
		if GetValue(a,b) = By_value
			break
		a =
	}
	if (a)
		return (field="index") ? index : GetValue(a,GetValue(main,field))
	else
		return
}