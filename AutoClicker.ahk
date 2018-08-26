#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Screen

; Initializations
alocs := []		; 2D stack of click locations [x, y, w, {normal, rect, ...}]
clocs := 0		; number of stored click locations

; Constants
dtime := 5		; milliseconds between click down/up
stime := 100	; milliseconds between clicks
rtime := 50		; times to click in rectangle
clicc := true	; click or just move the mouse around
hold  := true	; hold down letter keys
fname := A_WorkingDir . "\autoclicker"	; base name of config file
fends := ".ini"

f1::Pause
f2::Suspend
f3::Reload
f4::Edit

; Click randomly in rectangle made by u and v locations in click stack
; otherwise return if u and v don't exist
rect(repeat, u, v)
{
	global
	if not ((clocs >= 2) and (clocs >= u) and (clocs >= v) and (alocs[u][3] = alocs[v][3]))
		return
	mouseW := alocs[u][3]
	WinActivate, ahk_id mouseW
	Loop, %repeat%
	{
		if !toggle
			break
		Random, mouseX, alocs[u][1], alocs[v][1]
		Random, mouseY, alocs[u][2], alocs[v][2]
		MouseMove, mouseX, mouseY
		if clicc
		{
			Click Down
			Sleep dtime
			Click Up
		}
		Sleep stime
	}
	return
}

removeall()
{
	global
	while clocs > 0
	{
		alocs.remove(clocs)
		clocs -= 1
	}
	return
}

; Necessary for toggle to work
#MaxThreadsPerHotkey 2

; Click unlocked mouse or stop click
`::
toggle := !toggle
Loop
{
	if !toggle
		break
	Click Down
	Sleep dtime
	Click Up
	Sleep stime
}
return

; Click based on the click array if it exists
; otherwise lock the mouse position
+`::
toggle := !toggle
i := 0
MouseGetPos, mouseX, mouseY, mouseW
if hold
	Send {a down}{d down}
Loop
{
	if !toggle
		break
	if clocs <> 0
	{
		i := Mod(i, clocs)
		i += 1
		if alocs[i][4] = 0
		{
			mouseX := alocs[i][1]
			mouseY := alocs[i][2]
			mouseW := alocs[i][3]
			WinActivate, ahk_id mouseW
			MouseMove, mouseX, mouseY
			Click Down
			Sleep dtime
			Click Up
			Sleep stime
		}
		if alocs[i][4] = 1
		{
			rect(rtime, i, i + 1)
			i += 1
		}
		if alocs[i][4] = 2
		{
			mouseX := alocs[i][1]
			mouseY := alocs[i][2]
			mouseW := alocs[i][3]
			WinActivate, ahk_id mouseW
			MouseMove, mouseX, mouseY
			Click Down Right
			Sleep dtime
			Click Up Right
			Sleep stime
		}
		if alocs[i][4] = 3
		{
			mouseX := alocs[i][1]
			mouseY := alocs[i][2]
			mouseW := alocs[i][3]
			WinActivate, ahk_id mouseW
			MouseMove, mouseX, mouseY
			Loop 4
			{
				Click WheelDown
				Sleep % stime * 5
			}
		}
		if alocs[i][4] = 4
		{
			mouseX := alocs[i][1]
			mouseY := alocs[i][2]
			mouseW := alocs[i][3]
			WinActivate, ahk_id mouseW
			MouseMove, mouseX, mouseY
			Loop 4
			{
				Click WheelUp
				Sleep % stime * 5
			}
			Sleep stime
		}
	}
}
Send {a up}{d up}
return

; Turn off auto clicker on left click
LButton::
Click Down	; click down still
toggle := false
; Have to click up too
KeyWait, LButton
Click Up
toggle := false
return

#MaxThreadsPerHotkey 1

; Push location to click stack
; ALT + `
!`::
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, 0])
clocs += 1
return

; Pop location from click stack
; CTRL + `
^`::
alocs.remove(clocs)
clocs -= 1
if clocs < 0
	clocs := 0
return

; Push locations to click stack for rectangle press and let go locations
; SHIFT + ALT + `
+!`::
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, 1])
clocs += 1
KeyWait, ``
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, -1])
clocs += 1
return

; Push location to click stack for right click
; CTRL + SHIFT + ALT + `
^+!`::
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, 2])
clocs += 1
return

; Push location to click stack to scroll down
; CTRL + ALT + `
^!`::
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, 3])
clocs += 1
return

; Push location to click stack to scroll up
; CTRL + SHIFT + `
^+`::
MouseGetPos, mouseX, mouseY, mouseW
alocs.insert([mouseX, mouseY, mouseW, 4])
clocs += 1
return

; Decrease stime
; SHIFT + 1
+1::
stime -= 5
if stime < 1
	stime := 1
return

; Increase stime
; SHIFT + 2
<+2::
stime += 5
stime := stime - Mod(stime, 5)
return

; Read from file
; SHIFT + 3
+3::
; InputBox, fnum, Read File Number
; if fnum is number
; {
	file := fname . fends ; file := fname . fnum . fends
	removeall()
	Loop, Read, %file%
	{
		if (StrLen(A_LoopReadLine) = 0) or (SubStr(A_LoopReadLine, 1, 1) = ";")
			continue
		if (SubStr(A_LoopReadLine, 1, 5) = "stime")
		{
			stime := SubStr(A_LoopReadLine, 7)
			continue
		}
		if (SubStr(A_LoopReadLine, 1, 5) = "clicc")
		{
			clicc := false
			continue
		}
		
		alocs.insert([])
		clocs += 1
		i := 1
		Loop, parse, A_LoopReadLine, `,, %A_Space%
		{
			alocs[clocs][i] := A_LoopField
			i += 1
		}
	}
	file.Close()
; }
return

; Write to file
; SHIFT + 4
+4::
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
	tmp := "stime " . stime . "`r`n"
	file.Write(tmp)
	if !clicc
		file.Write("clicc`r`n")
	for i, e in alocs
	{
		tmp := (e[1] . ", " . e[2] . ", " . e[3] . ", " . e[4] . "`r`n")
		file.Write(tmp)
	}
	file.Close()
; }
return

; Toggle clicc
; SHIFT + 5
+5::
clicc := !clicc
return

; Soft reset
; SHIFT + 6
+6::
removeall()
return
