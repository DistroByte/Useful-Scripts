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
  ~F24::
    FileRead, key, C:\Users\James\Documents\Useful Scripts\2nd-keyboard\keypressed.txt
    if (key = "c") { ; open calculator
      if !WinExist("Calculator") {
        Run, calc.exe
        WinWait, Calculator
        WinSet, AlwaysOnTop
      } else {
        WinClose
      }
      Return
    }
    if (key = "e") { ; open email based on next number: 0 is default
      Run, thunderbird
      Return
    }
    if (key = "g") { ; open todoist
      Run, https://todoist.com/app/project/2259364084
      Return
    }
    if (key = "h") { ; open notes
      Run, https://md.james-hackett.ie/
      Return
    }
    if (key = "j") { ; open todos
      Run, https://md.james-hackett.ie/gp72FN8oRwKIudvnBhdl_g?both
      Return
    }
    if (key = "k") { ; keep window on top
      Winset, Alwaysontop, , A
      Return
    }
    if (key = "m") { ; toggle mute
      Send, ^+!K
      Return
    }
    if (key = "n") { ; toggle deafen
      Send, ^+!J
      Return
    }
    if (key ="q") { ; new chrome tab
      Run, http://www.google.com
      Return
    }
    if (key = "s") { ; search with google
      Send, ^c
      Sleep 200
      Run, http://www.google.com/search?q=%clipboard%
      Return
    }
    if (key = "t") { ; open semester 2 timetable page
      Run, https://md.james-hackett.ie/s/cPWKnj0kN
      Return
    }
    if (key = "v") {
      Run, C:\Users\James\AppData\Local\Programs\Microsoft VS Code\Code.exe
      Return
    }
    if (key = "w") { ; open incognito
      Run, cmd.exe
      Sleep, 200
      Send, start chrome /incognito{Enter}
      WinWait, ahk_exe chrome.exe
      ControlSend,, exit{Enter}, ahk_exe cmd.exe
      Return
    }
    if (key = "x"){ ; useful links
      Run, https://james-hackett.ie/pages/links/
      Return
    }
    if (WinActive("ahk_exe discord.exe")) {
      if (key = "p") {
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
    }
    if (WinActive("ahk_exe chrome.exe")) {
      if (key = "l") { ; log in to DCU
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
    }
    if (WinActive("ahk_exe Code.exe")) { ; shortcuts for VSCode
      if (key = "d") {
        Send, ^k
        Sleep, 50
        Send, ^!d
        Return
      }
      if (key = "l") { ; log in to DCU
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
      }
      if (key = "p") {
        Send, ca117{Space}
        Return
      }
      if (key = "u") { ; upload to Einstein
        Send, ^k
        Sleep, 50
        Send, ^!u
        Return
      }
    }
    if (key = "numMinus") { ; gets active window
      WinGetClass, class, A
      MsgBox, The active window's class is "%class%".
      Return
    }
  Return

  #ScrollLock::Suspend ; Win + scrollLock

  ; ~^s::
  ;   ToolTip, RELOADING...
  ;   Sleep, 300
  ;   Reload
  Return
