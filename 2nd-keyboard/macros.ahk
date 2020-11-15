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
    FileRead, key, "C:\Users\James\Documents\Useful Scripts\2nd-keyboard\keypressed.txt"
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
    if (key = "p") {
      WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      WebRequest.Open("GET", "http://ip.jsontest.com/")
      WebRequest.Send()
      FileRead, oldIP, ./ip.txt
      if (oldIP != WebRequest.ResponseText) {
        FileDelete, ./ip.txt
        FileAppend, WebRequest.ResponseText, ./ip.txt
      }
      WebRequest := ""
      Return
    }
    if (key = "s") { ; search with google
      Send, ^c
      Sleep 100
      Run, http://www.google.com/search?q=%clipboard%
      Return
    }
    if (key = "z") { ; echo file contents of einstein bash checker
      FileRead, stat, C:\Users\James\Documents\Useful Scripts\dcu-scripts\online.txt
      MsgBox, %stat%
    }
    if (WinActive("ahk_id 0x207e4")) { ; shortcuts for Opera
      if (key = "num0") { ; opens workspace 1
        Send, +^1
        Return
      }
      if (key = "num1") { ; opens workspace 2
        Send, +^2
        Return
      }
      if (key = "num2") { ; opens workspace 3
        Send, +^3
        Return
      }
      if (key = "num3") { ; opens workspace 4
        Send, +^4
        Return
      }
    }
    ; if (WinActive("ahk_id 0x170614")) { ; shortcuts for VSCode
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
    if (key = "u") { ; upload to Einstein
      Send, ^k
      Sleep, 50
      Send, ^!u
      Return
    }
    ; }
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
