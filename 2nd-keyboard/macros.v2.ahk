
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
<^>!c:: ; open calculator
  if !WinExist("Calculator") {
    Run, calc.exe
    WinWait, Calculator
    WinSet, AlwaysOnTop
  } else {
    WinClose
  }
Return

<^>!e:: Run, thunderbird ; open email

<^>!g:: Run, https://todoist.com/app/project/2259364084 ; open todoist

<^>!h:: Run, https://md.james-hackett.ie/ ; open notes

<^>!j:: Run, https://md.james-hackett.ie/gp72FN8oRwKIudvnBhdl_g?both ; open todos

<^>!k:: Winset, Alwaysontop, , A ; keep window on top

<^>!m:: Send, ^+!K ; toggle mute

<^>!n:: Send, ^+!J ; toggle deafen

<^>!q:: Run, http://www.google.com ; new chrome tab

<^>!s:: ; search with google
  Send, ^c
  Sleep 500
  Run, http://www.google.com/search?q=%clipboard%
Return

<^>!t:: Run, https://md.james-hackett.ie/s/cPWKnj0kN ; open semester 2 timetable page

<^>!v:: Run, C:\Users\James\AppData\Local\Programs\Microsoft VS Code\Code.exe ; run vscode

<^>!w:: ; open incognito
  Run, cmd.exe
  Sleep, 200
  Send, start chrome /incognito{Enter}
  WinWait, ahk_exe chrome.exe
  ControlSend,, exit{Enter}, ahk_exe cmd.exe
Return

<^>!x:: Run, https://james-hackett.ie/pages/links/ ; useful links

#IfWinActive, ahk_exe DiscordCanary.exe
<^>!p:: ; send ip
  WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  WebRequest.Open("GET", "http://ip.jsontest.com/")
  WebRequest.Send()
  newIP := SubStr(WebRequest.ResponseText, 9, -3)
  FileDelete, ./ip.txt
  FileAppend, % newIP, ./ip.txt
  Send, {Text}%newIP%
  WebRequest := ""
Return

#IfWinActive, ahk_exe chrome.exe
<^>!l:: ; login to DCU
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
<^>!l:: ; login to DCU
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

<^>!u:: ; upload to Einstein
  if (WinActive("ahk_exe Code.exe")) {
    Send, ^k
    Sleep, 50
    Send, ^!u
  }
Return

#IfWinActive
<^>!NumpadSub:: ; gets active window
  WinGetClass, class, A
  MsgBox, The active window's class is "%class%".
Return

#ScrollLock::Suspend ; suspend script

; ~^s::
;   ToolTip, RELOADING...
;   Sleep, 300
;   Reload
Return