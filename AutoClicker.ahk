#NoEnv
#UseHook
SetWorkingDir %A_ScriptDir%
SendMode Input
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Screen

;; Constants
fname		:= A_WorkingDir . "\autoclicker"	; base name of config file
fends		:= ".ini"
mleft		 = Left
mright		 = Right
mmiddle		 = Middle
m4			 = X1
m5			 = X2
mwup		 = WheelUp
mwdown		 = WheelDown
mwleft		 = WheelLeft
mwright		 = WheelRight

;; Initializations
;; [0,x,y,b,t]		click {L, R, M, X1, X2}
;; [1,x,y,u,v,b,t]	rand click button
;; [2,x,y,b]		wheel {WU, WD, WL, WR}
;; [3,k]			press key
loc_count	:= 0		; number of stored click locations
loc_stack	:= []		; 2D stack of click locations
hold_time	:= 5		; milliseconds between click down/up
delay_time	:= 100		; milliseconds between clicks
rand_clicks	:= 50		; times to randomly click inside rectangle
keypress_on	:= false	; whether we should repeatedly press a key or not
keypress	 = a		; key to repeatedly press


f1::Pause
f2::Suspend
f3::Reload
f4::Edit


;; clear loc_stack
removeall()
{
	global
	while loc_count > 0
	{
		loc_stack.remove(loc_count)
		loc_count -= 1
	}
	return
}


;; Necessary for toggle to work
#MaxThreadsPerHotkey 2


;; Click unlocked mouse or stop click
`::
toggle := !toggle
Loop
{
	if !toggle
	{
		break
	}
	Click Down
	Sleep hold_time
	Click Up
	Sleep delay_time
}
return


;; Click based on loc_stack if it exists
;; otherwise lock the mouse position
+`::
toggle := !toggle
i := 0
MouseGetPos, x, y
Loop
{
	if !toggle
	{
		break
	}
	
	if keypress_on
	{
		Send {%keypress% Down}
	}
	
	if (loc_count <> 0)
	{
		i := Mod(i, loc_count)
		i += 1
		if loc_stack[i][1] == 0
		{
			;; [0,x,y,b,t] click {L, R, M, X1, X2}
			x := loc_stack[i][2]
			y := loc_stack[i][3]
			b := loc_stack[i][4]
			t := loc_stack[i][5]
			Click Down %b% %x% %y% %t%
			Sleep hold_time
			Click Up %b%
			Sleep delay_time
		}
		else if loc_stack[i][1] == 1
		{
			;; [1,x,y,u,v,b,t] rand click button
			WinActivate, ahk_id loc_stack[i][3]
			b := loc_stack[i][6]
			t := loc_stack[i][7]
			Loop, %rand_clicks%
			{
				if !toggle
				{
					break
				}
				Random, x, loc_stack[i][2], loc_stack[i][4]
				Random, y, loc_stack[i][3], loc_stack[i][5]
				Click Down %b% %x% %y% %t%
				Sleep hold_time
				Click Up %b%
				Sleep delay_time
			}
		}
		else if loc_stack[i][1] == 2
		{
			;; [2,x,y,b] wheel {WU, WD, WL, WR}
			x := loc_stack[i][2]
			y := loc_stack[i][3]
			b := loc_stack[i][4]
			;; kinda works
			Click %b% %x% %y%
			Sleep delay_time
		}
		else if loc_stack[i][1] == 3
		{
			;; [3,k] press key
			k := loc_stack[i][2]
			Send {%k% Down}
		}
	}
	else
	{
		; TODO try doing stuff with send like : Send a{Click D L 123 123}
		Click Down %x% %y%
		Sleep hold_time
		Click Up
		Sleep delay_time
	}
}
if keypress_on
{
	Send {%keypress% Up}
}
return


;; Turn off auto clicker on left click
LButton::
Click Down	; click down still
toggle := false
; Have to click up too
KeyWait, LButton
Click Up
toggle := false
return


#MaxThreadsPerHotkey 1


;; Push locations to loc_stack
;; LALT + ` = move
<!`::
MouseGetPos, x, y
loc_stack.insert([0, x, y, "", 0])
loc_count += 1
return
;; LALT + LButton = left
<!LButton::
MouseGetPos, x, y
loc_stack.insert([0, x, y, mleft, 1])
loc_count += 1
return
;; LALT + RButton = right
<!RButton::
MouseGetPos, x, y
loc_stack.insert([0, x, y, mright, 1])
loc_count += 1
return
;; LALT + MButton = middle
<!MButton::
MouseGetPos, x, y
loc_stack.insert([0, x, y, mmiddle, 1])
loc_count += 1
return
;; LALT + XButton1 = m4
<!XButton1::
MouseGetPos, x, y
loc_stack.insert([0, x, y, m4, 1])
loc_count += 1
return
;; LALT + XButton2 = m5
<!XButton2::
MouseGetPos, x, y
loc_stack.insert([0, x, y, m5, 1])
loc_count += 1
return


;; Pop location from loc_stack
;; LCTRL + `
<^`::
loc_stack.remove(loc_count)
loc_count -= 1
if loc_count < 0
	loc_count := 0
return


;; Push random locations to loc_stack
;; LSHIFT + LALT + ` = move
<+<!`::
MouseGetPos, x, y
KeyWait, ``
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, "", 0])
loc_count += 1
return
;; LSHIFT + LALT + LButton = left
<+<!LButton::
MouseGetPos, x, y
KeyWait, LButton
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, mleft, 1])
loc_count += 1
return
;; LSHIFT + LALT + RButton = right
<+<!RButton::
MouseGetPos, x, y
KeyWait, RButton
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, mright, 1])
loc_count += 1
return
;; LSHIFT + LALT + MButton = middle
<+<!MButton::
MouseGetPos, x, y
KeyWait, MButton
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, mmiddle, 1])
loc_count += 1
return
;; LSHIFT + LALT + XButton1 = m4
<+<!XButton1::
MouseGetPos, x, y
KeyWait, XButton1
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, m4, 1])
loc_count += 1
return
;; LSHIFT + LALT + XButton2 = m5
<+<!XButton2::
MouseGetPos, x, y
KeyWait, XButton2
MouseGetPos, u, v
loc_stack.insert([1, x, y, u, v, m5, 1])
loc_count += 1
return


;; Push scroll location to loc_stack
;; LALT + WheelUp
<!WheelUp::
MouseGetPos, x, y
loc_stack.insert([2, x, y, mwup])
loc_count += 1
return
;; LALT + WheelDown
<!WheelDown::
MouseGetPos, x, y
loc_stack.insert([2, x, y, mwdown])
loc_count += 1
return
;; LALT + WheelLeft
<!WheelLeft::
MouseGetPos, x, y
loc_stack.insert([2, x, y, mwleft])
loc_count += 1
return
;; LALT + WheelRight
<!WheelRight::
MouseGetPos, x, y
loc_stack.insert([2, x, y, mwright])
loc_count += 1
return


;; Push key press to loc_stack
;; LCTRL + LSHIFT + `
<^<+`::
Input, k, IL1
loc_stack.insert([3, k])
loc_count += 1
return


;; Toggle and set repeated key press
;; LCTRL + LSHIFT + LALT + `
<^<+<!`::
Input, k, IL1
if keypress_on
{
	if k == keypress
	{
		keypress_on := false
	}
	Send {%keypress% Up}
	keypress := k
}
else
{
	keypress := k
	keypress_on := true
}
return


;; Decrease delay_time
;; LCTRL + LSHIFT + 1
<^<+1::
delay_time -= 5
if delay_time < 1
{
	delay_time := 1
}
return


;; Increase delay_time
;; LCTRL + LSHIFT + 2
<^<+2::
delay_time += 5
delay_time := delay_time - Mod(delay_time, 5)
return


;; Soft reset
;; LCTRL + LSHIFT + 2
<^<+3::
removeall()
return


;; Read from file
;; LCTRL + LSHIFT + R
<^<+r::
; InputBox, fnum, Read File Number
; if fnum is number
; {
	file := fname . fends ; file := fname . fnum . fends
	removeall()
	Loop, Read, %file%
	{
		if (StrLen(A_LoopReadLine) = 0) or (SubStr(A_LoopReadLine, 1, 1) = ";")
		{
			continue
		}
		
		if (SubStr(A_LoopReadLine, 1, 5) = "delay_time")
		{
			delay_time := SubStr(A_LoopReadLine, 7)
			continue
		}
		
		loc_stack.insert([])
		loc_count += 1
		i := 1
		Loop, parse, A_LoopReadLine, `,, %A_Space%
		{
			loc_stack[loc_count][i] := A_LoopField
			i += 1
		}
	}
	file.Close()
; }
return


;; Write to file
;; LCTRL + LSHIFT + W
<^<+w::
; InputBox, fnum, Write File Number
; if fnum is number
; {
	file := fname . fends ; file := fname . fnum . fends
	file := FileOpen(file, "w")
	if !IsObject(file)
	{
		MsgBox Can't open "%fname%" for writing.
		return
	}
	tmp := "delay_time " . delay_time . "`r`n"
	file.Write(tmp)
	for i, e in loc_stack
	{
		tmp := (e[1] . ", " . e[2] . ", " . e[3] . ", " . e[4] . "`r`n")
		file.Write(tmp)
	}
	file.Close()
; }
return
