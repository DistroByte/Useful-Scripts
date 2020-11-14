#SingleInstance, Force
#Persistent
SendMode,Input
SetKeyDelay,-1
SetWinDelay,-1
SetControlDelay,-1
SetMouseDelay,-1
gosub VarInit

Gui,+AlwaysOnTop +ToolWindow
Gui,Add,Text,x7,Tutorial Mode:
Gui,Add,Text,vModeWp yp x+15, %Mode%
Gui,Add,Text,x7 y+15,Current Character:
Gui,Add,Picture,vPicWp x+5 h105 w83
Gui,Add,Edit,x7 w175 vInWp
Gui,Show,,Thumbscript
If IsLabel(Mode)
  goto %Mode%
return

VarInit:
  Gui2Width = 100
  Gui2Height = 100
  T_ScreenWidth := A_ScreenWidth - Gui2Width
  T_ScreenHeight = 0
  CurrentC = Red ; Colour of the current letter in the gui.
  Warmup = abcdefghijklmnopqrstuvwxyz
  Ex1 = The quick brown fox jumps over the lazy brown dog.
  Mode = StartWarmup
  Nextletter = false
  Char =
  Loop,Parse,Warmup
    Hotkey,%A_LoopField%,NextLetter,Off UseErrorLevel
return

GuiClose:
  ExitApp
return

StartWarmup:
  StringReplace,Ex1,Ex1,%A_Space%,,A
  PriorList =
  Loop,Parse,warmup
  {
    If A_Loopfield =
      continue
    Char := A_LoopField
    If Char
    {
      ;IfInString,Piror,%Char%
      Hotkey,%Char%,On
      /*
    IfNotInString,Prior,%Char%
    {
      Prior .= Char
      Hotkey,%Char%,NextLetter,On UseErrorLevel
    }
      */
      GuiControl,,PicWp,%A_LoopField%.jpg 
      gosub WaitForLetter
    }
  }
  Gui,Hide ; Hide the GUI, its AlwaysOnTop and will block the msgbox.
  Msgbox Warmup Complete.
  ExitApp
return

Random:
  Char := RandomLetter()
  If Char =
    goto Random ; Re-randomize
  if Char = %OldChar%
    goto Random ; Re-randomize
  GuiControl,,Curent,%Char%
  gosub ShowLetter
  Nextletter = false
  If Char
  {
    IfInString,Piror,%Char%
      Hotkey,%Char%,On,UseErrorLevel
    IfNotInString,Prior,%Char%
    {
      Prior .= Char
      Hotkey,%Char%,NextLetter,On UseErrorLevel
    }
  }
  If ErrorLevel
    goto Random ; Re-randomize
  gosub WaitForLetter
  ;goto Random
return

WaitForLetter:
  Loop ; Wait for next key to be pressed
  {
    If NextLetter = True
    {
      NextLetter = false
      break
    }
    sleep 10
  }
return

NextLetter:
  Send %Char%
  OldChar := Char
  If Char ; If there was a previous character
    Hotkey,%Char%,Off ; Remove prior hotkeys
  NextLetter = true
  ;If islabel(Mode)
  ;  goto %Mode%
return

ShowLetter:
  If Char =
    return
  If Char = %OldChar%
    return
  GuiControl,,PicWp,%Char%.jpg 
return

RandomLetter()
{
  global
  Random,Generated,1,26
  If Generated = 1
    return "a"
  If Generated = 2
    return "b"
  If Generated = 3
    return "c"
  If Generated = 4
    return "d"
  If Generated = 5
    return "e"
  If Generated = 6
    return "f"
  If Generated = 7
    return "g"
  If Generated = 8
    return "h"
  If Generated = 9
    return "i"
  If Generated = 10
    return "j"
  If Generated = 11
    return "k"
  If Generated = 12
    return "l"
  If Generated = 13
    return "m"
  If Generated = 14
    return "n"
  If Generated = 15
    return "o"
  If Generated = 16
    return "p"
  If Generated = 17
    return "q"
  If Generated = 18
    return "r"
  If Generated = 19
    return "s"
  If Generated = 20
    return "t"
  If Generated = 21
    return "u"
  If Generated = 22
    return "v"
  If Generated = 23
    return "w"
  If Generated = 24
    return "x"
  If Generated = 25
    return "y"
  If Generated = 26
    return "z"
return
}

NumpadMult::Reload