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
<^>!c::
  if !WinExist("Calculator") {
    Run, calc.exe
    WinWait, Calculator
    WinSet, AlwaysOnTop
  } else {
    WinClose
  }
Return

<^>!e:: Run, thunderbird
Return

<^>!g:: Run, https://todoist.com/app/project/2259364084
Return

<^>!h:: Run, https://md.james-hackett.ie/
Return

<^>!j:: Run, https://md.james-hackett.ie/gp72FN8oRwKIudvnBhdl_g?both
Return

<^>!k:: Winset, Alwaysontop, , A
Return

<^>!m:: Send, ^+!K
Return

<^>!n:: Send, ^+!J
Return

<^>!q:: Run, http://www.google.com
Return

<^>!s::
  Send, ^c
  Sleep 500
  Run, http://www.google.com/search?q=%clipboard%
Return

<^>!t:: Run, https://md.james-hackett.ie/s/cPWKnj0kN
Return

<^>!v:: Run, C:\Users\James\AppData\Local\Programs\Microsoft VS Code\Code.exe
Return

<^>!w:: 
  Run, cmd.exe
  Sleep, 200
  Send, start chrome /incognito{Enter}
  WinWait, ahk_exe chrome.exe
  ControlSend,, exit{Enter}, ahk_exe cmd.exe
Return

<^>!x:: Run, https://james-hackett.ie/pages/links/
Return

if (WinActive("ahk_exe discord.exe")) {
<^>!p::
  WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  WebRequest.Open("GET", "http://ip.jsontest.com/")
  WebRequest.Send()
  newIP := SubStr(WebRequest.ResponseText, 9, -3)
  FileDelete, ./ip.txt
  FileAppend, % newIP, ./ip.txt
  Send, {Text}%newIP%
  WebRequest := ""
Return
}

if (WinActive("ahk_exe chrome.exe")) {
<^>l::
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
}

if (WinActive("ahk_exe Code.exe")) { ; shortcuts for VSCode
<^>d::
  Send, ^k
  Sleep, 50
  Send, ^!d
Return

<^>!l:: ; log in to DCU
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
  Send, ^k
  Sleep, 50
  Send, ^!u
Return
}

<^>!NumpadSub::
  WinGetClass, class, A
  MsgBox, The active window's class is "%class%".
Return

#ScrollLock::Suspend ; Win + scrollLock

; ~^s::
;   ToolTip, RELOADING...
;   Sleep, 300
;   Reload