;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mostly Required to Function Properly
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include <ClickJam>
#NoEnv                      ; + performance, don't look up env vars
#UseHook On                 ; + responsiveness, no recursive macros
#Persistent                 ; necessary for macros
#SingleInstance Force       ; releod script on relaunch
SetWorkingDir %A_ScriptDir% ; sets working dir to script dir
SendMode Input              ; + speed & reliability, alias Send to SendInput
SetDefaultMouseSpeed, 0     ; move the mouse instantly, TODO make this configurable 
CoordMode, Mouse, Screen    ; move the mouse using screen coordinates, TODO make this configurable

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jam   := new ClickJam(0) ; object to load/store/execute macros

;; TODO, make part of ClickJam
fname       := "ClickJam." ; base name of config files
fnum        := 0           ; file number used in config file name
fext        := ".json"     ; file extention for config files
keypress_on := false       ; whether we should repeatedly press a key or not
keypress     = a           ; key to repeatedly press
hold_time   := 5           ; milliseconds between click down/up
delay_time  := 100         ; milliseconds between clicks
rand_clicks := 1           ; times to randomly click inside rectangle
rand_delay  := 0           ; wait up to this much extra time on delay_time
x_offset    := 0           ; add this to the x coordinate of all mouse actions
y_offset    := 0           ; add this to the y coordinate of all mouse actions
max_delay   := delay_time + rand_delay
loc_cnt     := 0           ; number of stored click locations
loc_que     := []          ; 2D queue of click locations
timer       := 0           ; use SetTimer %timer% if > 0 when starting clicks
tim_cnt     := 0           ; number of stored click locations
tim_que     := []          ; 2D queue of click locations


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For convenience
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
m1 = Left
m2 = Right
m3 = Middle
m4 = X1
m5 = X2
wu = WheelUp
wd = WheelDown
wl = WheelLeft
wr = WheelRight


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Application Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
f1::Pause
f2::Suspend
f3::Reload
f4::Edit
f6::ExitApp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clear loc_que
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
removeall()
{
  global
  while (loc_cnt > 0)
  {
    loc_que.remove(loc_cnt)
    loc_cnt -= 1
  }
  return
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Necessary for toggle to work
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#MaxThreadsPerHotkey 2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stop click
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
~LButton::
~RButton::
~MButton::
~XButton1::
~XButton2::
~WheelUp::
~WheelDown::
~WheelLeft::
~WheelRight::
toggle := false
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Click unlocked mouse or stop click
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
`::
toggle := !toggle
Loop
{
  if (!toggle)
  {
    break
  }

  Random, real_delay, delay_time, max_delay

  Click Down
  Sleep hold_time
  Click Up
  Sleep real_delay
}
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command queue format reminder
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [0,x,y,b,t]      click {L, R, M, X1, X2}
;; [1,x,y,u,v,b,t]  rand click button
;; [2,x,y,b]        wheel {WU, WD, WL, WR}
;; [3,k]            change keypress
;; [4,o]            set keypress_on
;; [5,k]            one time keypress


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Execute a single click location array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExecuteClick(loc)
{
  global
  
  Random, real_delay, delay_time, max_delay
  
  if (loc[1] == 0)
  {
    ;; [0,x,y,b,t] click {L, R, M, X1, X2}
    x := loc[2] + x_offset
    y := loc[3] + y_offset
    b := loc[4]
    t := loc[5]
    Click Down %b% %x% %y% %t%
    Sleep hold_time
    Click Up %b%
    Sleep real_delay
  }
  else if (loc[1] == 1)
  {
    ;; [1,x,y,u,v,b,t] rand click button
    WinActivate, ahk_id loc[3]
    b := loc[6]
    t := loc[7]
    Loop, %rand_clicks%
    {
      if (!toggle)
      {
        break
      }
      Random, x, loc[2], loc[4]
      Random, y, loc[3], loc[5]
      x += x_offset
      y += y_offset
      Click Down %b% %x% %y% %t%
      Sleep hold_time
      Click Up %b%
      Random, real_delay, delay_time, max_delay
      Sleep real_delay
    }
  }
  else if (loc[1] == 2)
  {
    ;; [2,x,y,b] wheel {WU, WD, WL, WR}
    x := loc[2] + x_offset
    y := loc[3] + y_offset
    b := loc[4]
    ;; kinda works
    Click %b% %x% %y%
    Sleep real_delay
  }
  else if (loc[1] == 3)
  {
    ;; [3,k] change keypress
    Send {%keypress% Up}
    keypress := loc[2]
  }
  else if (loc[1] == 4)
  {
    ;; [4,o] set keypress_on
    o := loc[2]
    if (keypress_on and !o)
    {
      Send {%keypress% Up}
    }
    keypress_on := o
  }
  else if (loc[1] == 5)
  {
    ;; [5,k] press k
    k := loc[2]
    m := loc[3]
    Send %m%{%k%}
    Sleep real_delay
  }
  else if (loc[1] == 6)
  {
    ;; [5,t] sleep t
    t := loc[2]
    Sleep t
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Click based on loc_que if it exists
;; otherwise lock the mouse position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSHIFT + `
<+`::
toggle := !toggle
i := 0
MouseGetPos, x, y
start_time := A_TickCount
Loop
{
  if (!toggle)
  {
    break
  }
  
  if (keypress_on)
  {
    Send {%keypress% Down}
  }
  
  if (i == loc_cnt and timer > 0 and tim_cnt > 0)
  {
    if (A_TickCount - start_time > timer)
    {
      j := 0
      
      Loop, %tim_cnt%
      {
        if (!toggle)
        {
          break
        }
        
        j += 1
        ExecuteClick(tim_que[j])
      }
      
      start_time := A_TickCount
    }
  }
  
  if (loc_cnt > 0)
  {
    i := Mod(i, loc_cnt)
    i += 1
    
    ExecuteClick(loc_que[i])
  }
  else
  {
    i := 0
    ; TODO try doing stuff with send like : Send a{Click D L 123 123}
    Click Down %x% %y%
    Sleep hold_time
    Click Up
    Random, real_delay, delay_time, max_delay
    Sleep real_delay
  }
}
if (keypress_on)
{
  Send {%keypress% Up}
}
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This prevents a lot of unexpected behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#MaxThreadsPerHotkey 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push locations to loc_que
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LALT + ` = move
<!`::
MouseGetPos, x, y
loc_que.insert([0, x, y, m1, 0])
loc_cnt += 1
return
;; LALT + LButton = left
<!LButton::
MouseGetPos, x, y
loc_que.insert([0, x, y, m1, 1])
loc_cnt += 1
return
;; LALT + RButton = right
<!RButton::
MouseGetPos, x, y
loc_que.insert([0, x, y, m2, 1])
loc_cnt += 1
return
;; LALT + MButton = middle
<!MButton::
MouseGetPos, x, y
loc_que.insert([0, x, y, m3, 1])
loc_cnt += 1
return
;; LALT + XButton1 = m4
<!XButton1::
MouseGetPos, x, y
loc_que.insert([0, x, y, m4, 1])
loc_cnt += 1
return
;; LALT + XButton2 = m5
<!XButton2::
MouseGetPos, x, y
loc_que.insert([0, x, y, m5, 1])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pop location from loc_que
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + `
<^`::
loc_que.remove(loc_cnt)
loc_cnt -= 1
if (loc_cnt < 0)
  loc_cnt := 0
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push random locations to loc_que
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSHIFT + LALT + ` = move
<+<!`::
MouseGetPos, x, y
KeyWait, ``
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m1, 0])
loc_cnt += 1
return
;; LSHIFT + LALT + LButton = left
<+<!LButton::
MouseGetPos, x, y
KeyWait, LButton
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m1, 1])
loc_cnt += 1
return
;; LSHIFT + LALT + RButton = right
<+<!RButton::
MouseGetPos, x, y
KeyWait, RButton
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m2, 1])
loc_cnt += 1
return
;; LSHIFT + LALT + MButton = middle
<+<!MButton::
MouseGetPos, x, y
KeyWait, MButton
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m3, 1])
loc_cnt += 1
return
;; LSHIFT + LALT + XButton1 = m4
<+<!XButton1::
MouseGetPos, x, y
KeyWait, XButton1
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m4, 1])
loc_cnt += 1
return
;; LSHIFT + LALT + XButton2 = m5
<+<!XButton2::
MouseGetPos, x, y
KeyWait, XButton2
MouseGetPos, u, v
loc_que.insert([1, x, y, u, v, m5, 1])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push scroll location to loc_que
;; TODO needs testing/polishing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LALT + WheelUp
<!WheelUp::
MouseGetPos, x, y
loc_que.insert([2, x, y, wu])
loc_cnt += 1
return
;; LALT + WheelDown
<!WheelDown::
MouseGetPos, x, y
loc_que.insert([2, x, y, wd])
loc_cnt += 1
return
;; LALT + WheelLeft
<!WheelLeft::
MouseGetPos, x, y
loc_que.insert([2, x, y, wl])
loc_cnt += 1
return
;; LALT + WheelRight
<!WheelRight::
MouseGetPos, x, y
loc_que.insert([2, x, y, wr])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push repeated key press to loc_que
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + `
<^<+`::
Input, k, IL1
loc_que.insert([3, k])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push repeated key press on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LALT + `
<^<!`::
loc_que.insert([4, 1])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push repeated key press off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + LALT + `
<^<+<!`::
loc_que.insert([4, 0])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push one time key press
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RCTRL + `
>^`::
Input, k, IL1
loc_que.insert([5, k])
loc_cnt += 1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Decrease delay_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + 1
<^<+1::
delay_time -= 5
if (delay_time < 1)
{
  delay_time := 1
}
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Increase delay_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + 2
<^<+2::
delay_time += 5
delay_time := delay_time - Mod(delay_time, 5)
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Soft reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + 3
<^<+3::
removeall()
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set repeated key press
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + 4
<^<+4::
Input, keypress, IL1
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Toggle repeated key press
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + 5
<^<+5::
keypress_on := !keypress_on
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Change fnum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSHIFT + LALT + 0
<+<!0::
fnum := 0
return
;; LSHIFT + LALT + 1
<+<!1::
fnum := 1
return
;; LSHIFT + LALT + 2
<+<!2::
fnum := 2
return
;; LSHIFT + LALT + 3
<+<!3::
fnum := 3
return
;; LSHIFT + LALT + 4
<+<!4::
fnum := 4
return
;; LSHIFT + LALT + 5
<+<!5::
fnum := 5
return
;; LSHIFT + LALT + 6
<+<!6::
fnum := 6
return
;; LSHIFT + LALT + 7
<+<!7::
fnum := 7
return
;; LSHIFT + LALT + 8
<+<!8::
fnum := 8
return
;; LSHIFT + LALT + 9
<+<!9::
fnum := 9
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read from file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + R
<^<+r::
file := fname . fnum . fext
removeall()
keypress_on := false
timer := 0
Loop, Read, %file%
{
  if (StrLen(A_LoopReadLine) == 0 or SubStr(A_LoopReadLine, 1, 1) = ";")
  {
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 10) = "delay_time")
  {
    delay_time := SubStr(A_LoopReadLine, 12)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 9) = "hold_time")
  {
    hold_time := SubStr(A_LoopReadLine, 11)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 1) = "keypress_on")
  {
    keypress_on := true
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 8) = "keypress")
  {
    keypress := SubStr(A_LoopReadLine, 10)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 9) = "set_timer")
  {
    timer := SubStr(A_LoopReadLine, 11)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 11) = "rand_clicks")
  {
    rand_clicks := SubStr(A_LoopReadLine, 13)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 10) = "rand_delay")
  {
    rand_delay := SubStr(A_LoopReadLine, 12)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 8) = "x_offset")
  {
    x_offset := SubStr(A_LoopReadLine, 10)
    continue
  }
  
  if (SubStr(A_LoopReadLine, 1, 8) = "y_offset")
  {
    y_offset := SubStr(A_LoopReadLine, 10)
    continue
  }
  
  if (timer > 0)
  {
    tim_que.insert([])
    tim_cnt += 1
    i := 1
    Loop, parse, A_LoopReadLine, CSV
    {
      tim_que[tim_cnt][i] := A_LoopField
      i += 1
    }
  }
  else
  {
    loc_que.insert([])
    loc_cnt += 1
    i := 1
    Loop, parse, A_LoopReadLine, CSV
    {
      loc_que[loc_cnt][i] := A_LoopField
      i += 1
    }
  }
}
max_delay   := delay_time + rand_delay
file.Close()
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Write to file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + W
<^<+w::
fpath := fname . fnum . fext
file := FileOpen(fpath, "w")

if (!IsObject(file))
{
  MsgBox Can't open "%fpath%" for writing.
  return
}

tmp := "delay_time " . delay_time . "`r`n"
file.Write(tmp)

tmp := "hold_time " . hold_time . "`r`n"
file.Write(tmp)

tmp := "rand_clicks " . rand_clicks . "`r`n"
file.Write(tmp)

tmp := "rand_delay " . rand_delay . "`r`n"
file.Write(tmp)

tmp := "x_offset " . x_offset . "`r`n"
file.Write(tmp)

tmp := "y_offset " . y_offset . "`r`n"
file.Write(tmp)

if (keypress_on)
{
  tmp := "keypress_on`r`nkeypress " . keypress . "`r`n"
  file.Write(tmp)
}

for i, e in loc_que
{
  tmp := ""
  for j, k in e
  {
    if ("" . k == A_Space)
    {
      k := "Space"
    }
    if ("" . tmp != "")
    {
      tmp := "" . tmp . ","
    }
    tmp := "" . tmp . k
  }
  tmp := "" . tmp . "`r`n"
  file.Write(tmp)
}

if (timer > 0)
{
  tmp := "set_timer " . set_timer . "`r`n"
  file.Write(tmp)

  for i, e in tim_que
  {
    tmp := ""
    for j, k in e
    {
      if ("" . k == A_Space)
      {
        k := "Space"
      }
      if ("" . tmp != "")
      {
        tmp := "" . tmp . ","
      }
      tmp := "" . tmp . k
    }
    tmp := "" . tmp . "`r`n"
    file.Write(tmp)
  }
}

file.Close()
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dump a debug log
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LCTRL + LSHIFT + D
<^<+d::
FormatTime, dt, , yyyyMMddHHmmss
fpath := fname . "dbg_" . dt . ".log"
file := FileOpen(fpath, "w")

if (!IsObject(file))
{
  MsgBox, Can't open %fpath% for writing.
  return
}

;; TODO write debug info

file.Close()
return
