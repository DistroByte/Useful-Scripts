
; This script does not need a second keyboard to run. It uses right alt, or alt gr to determine hotkeys.
; This does mean that you cannot use regular alt gr functions (like accents etc) on keys that are mapped. 

; The script can be paused at any stage with windows + scrolllock. The same keycombo enables the
; script again.

#NoEnv
SendMode Input
#InstallKeybdHook
#UseHook On
Menu, Tray, Icon, shell32.dll, 283
SetCapsLockState, AlwaysOff
Capslock::Shift
#SingleInstance force
#MaxHotkeysPerInterval 2000
#WinActivateForce ;https://autohotkey.com/docs/commands/_WinActivateForce.html

#IfWinActive

#+s::Send, {CtrlDown}{PrintScreen Down}{CtrlUp}{PrintScreen Up} ; Win + Shift + S runs sharex

<^>!Numpad1::Send, {AltDown}{PrintScreen Down}{AltUp}{PrintScreen Up} ; ALTGR + Num1 capture window

<^>!Numpad2::Send, {PrintScreen} ; ALTGR + Num2 capture monitor

<^>!a::Run, "C:\Program Files\Adobe\Adobe Premiere Pro 2020\Adobe Premiere Pro.exe" ; ALTGR + A runs Premiere Pro: video editor

<^>!c:: ; ALTGR + C open calculator
  if !WinExist("Calculator") {
    Run, calc.exe
    WinWait, Calculator
    WinSet, AlwaysOnTop
    WinActivate, A
  } else {
    WinClose
  }
Return

<^>!e:: Run, thunderbird ; ALTGR + G open email

<^>!g:: Run, https://todoist.com/app/project/2259364084 ; ALTGR + G open todoist

<^>!h:: Run, https://md.james-hackett.ie/ ; ALTGR + H open notes

<^>!j:: Run, https://md.james-hackett.ie/gp72FN8oRwKIudvnBhdl_g?both ; ALTGR + J open todos

<^>!k:: Winset, Alwaysontop, , A ; ALTGR + Kkeep window on top

<^>!m:: Send, ^+!K ; ALTGR + M toggle mute

<^>!n:: Send, ^+!J ; ALTGR + N toggle deafen

<^>!q:: Run, http://www.google.com ; ALTGR + Q new chrome tab

<^>!s:: ; ALTGR + S search with google
  Send, ^c
  Sleep 500
  Run, http://www.google.com/search?q=%clipboard%
Return

<^>!t:: Run, https://md.james-hackett.ie/19i4gAB5QHKuOHL1DY3hQA?both ; ALTGR + T open semester 2 timetable page

<^>!v:: Run, C:\Users\James\AppData\Local\Programs\Microsoft VS Code\Code.exe ; ALTGR + V run vscode

<^>!w:: ; ALTGR + W open incognito
  Run, cmd.exe
  Sleep, 200
  Send, start firefox /incognito{Enter}
  WinWait, ahk_exe firefox.exe
  ControlSend,, exit{Enter}, ahk_exe cmd.exe
Return

<^>!,::Run, https://www.netflix.com/browse

<^>!.:: WinMinimize, A

<^>!x:: Run, https://james-hackett.ie/pages/links/ ; ALTGR + X useful links

#IfWinActive, ahk_exe thunderbird.exe
  <^>!Down:: Send, f ; ALTGR + DownArrow next email

  <^>!Up:: Send, b ; ALTGR + UpArrow previous email
Return

#IfWinActive, ahk_exe DiscordCanary.exe
<^>!p:: ; ALTGR + P send ip
  WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  WebRequest.Open("GET", "http://ip.jsontest.com/")
  WebRequest.Send()
  newIP := SubStr(WebRequest.ResponseText, 9, -3)
  FileDelete, ./ip.txt
  FileAppend, % newIP, ./ip.txt
  Send, {Text}%newIP%
  WebRequest := ""
Return

#IfWinActive, ahk_exe firefox.exe
<^>!l:: ; ALTGR + L login to DCU
  FileRead, pword, ..\password.txt
  FileRead, uname, ..\username.txt
  Sleep, 200
  Send, {Text}%uname%
  Sleep, 50
  Send, {Tab}
  Sleep, 200
  Send, {Text}%pword%
  Sleep, 50
  Send, {Enter}
Return

#IfWinActive, ahk_exe Code.exe
<^>!l:: ; ALTGR + L login to DCU
  FileRead, pword, ..\password.txt
  FileRead, uname, ..\username.txt
  Sleep, 200
  Send, {Text}%uname%
  Sleep, 50
  Send, {Enter}
  Sleep, 200
  Send, {Text}%pword%
  Sleep, 50
  Send, {Enter}
Return

<^>!u:: ; ALTGR + U upload to Einstein
  Sleep, 400
  Send, ^k
  Sleep, 100
  Send, ^!u
Return

#IfWinActive
<^>!NumpadSub:: ; ALTGR + NumpadMinus gets active window
  WinGetClass, class, A
  MsgBox, The active window's class is "%class%".
Return

<^>!NumpadAdd::
  Process, Exist, getxp.exe 
  NewPID = %ErrorLevel%
  If (NewPID = 0)
  {
    Run, C:\Users\James\Documents\Useful Scripts\2nd-keyboard\getxp.exe
    Return
  }
  Else 
  {
    Runwait, taskkill /im getxp.exe /f
    Return
  }
Return

#ScrollLock::Suspend ; Windows + Scroll Lock suspend script

; $esc::
;   KeyWait,esc,T0.5 ;wait 0.5 seconds for release key
;   If (ErrorLevel) ;more than 0.5 sec have passed
;   {
;     Send {esc}
;     keyHeld = 1
;     KeyWait,esc
;   }
; Return

; $esc up::
;   If (keyHeld = 0) ;If not held down
;     Send ``
;   Else
;     keyHeld = 0
; Return

; shift & esc::
;   Send |
;   keyHeld = 1
; Return

; <^>!#::
;   ToolTip, RELOADING...
;   Sleep, 300
;   Reload
; Return