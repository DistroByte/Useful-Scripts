#SingleInstance,Force
SendMode,Input
SetKeyDelay,-1

gosub BuildList ; Assign all the letters to variables for later

keys=0
Caps = false

CapsTip = True ; Show traytip when toggling caps state
TipDelay = 1000 ; Milliseconds to show traytip for

Numpad1::NumCom(1)
Numpad2::NumCom(2)
Numpad3::NumCom(3)
Numpad4::NumCom(4)
Numpad5::NumCom(5)
Numpad6::NumCom(6)
Numpad7::NumCom(7)
Numpad8::NumCom(8)
Numpad9::NumCom(9)
NumPad0::Space
NumPadSub::Backspace

NumpadAdd::
  disp := Caps("Toggle")
  If CapsTip = True
  {
    Traytip,Thumbscript,%Disp%,10,1
    SetTimer,TrayTipClear,%TipDelay%
  }
return

TrayTipClear:
  SetTimer,TrayTipClear,Off
  TrayTip
return

Caps(state) 
; Caps(On/True)|Caps(Off/False)|Caps(Toggle)
{
  global
  if state = toggle
  {
    if caps = true
    {
      caps = false
      return "caps"
    }
    if caps = false
    {
      caps = true
      return "CAPS"
    }
  }
  if state = on
    state = true
  if state = off
    state = false
  Caps = %State%
  If Caps = True
    return "CAPS"
  Else If Caps = False
    return "caps"
}

NumCom(key)
{
  global
  ;Msgbox %Keys%/%Key%`n%Keeptrack%`n%Char%
  keys += 1
  IfLess,Keys,3
  keeptrack=%keeptrack%%key%
  If Keys > 1
    gosub SetKey
return
}

SetKey:
  ;Tooltip Com: %Keeptrack%`n`nChar: %Char%
  ;sleep 1000
  ;ToolTip

  Char := Char%KeepTrack%

  If ( Char = "{Enter}" or Char = "." )
    CapsSet = 1 ; (For Mode 3) Time to use a new capital
  WinGetActiveTitle,CurrentWin
  If CurrentWin <> %OldWin%
  {
    CapsSet = 1 ; (For Mode 3) New window is active, so use a capital
    OldWin := CurrentWin
  }

  If Caps = True
    StringUpper,Char, Char
  If Caps = 3
  {
    Char := Char%KeepTrack%
    If ( CapsSet = "True" or CapsSet = "3" )
      StringUpper, Char, Char
    If CapsSet = 1 ; Capital for beginning of sentence
      Capset = 0
  }
  ;return

Send:
  If Char = ; Invalid combo, clean up the com
    goto Cleanup
  Send %Char%
  ;goto Cleanup
  ;return
Cleanup:
NumPadDiv::
  keeptrack=
  keys=0
  Char =
return

BuildList:
  ; Letters, all on the outer 9 pad target
  ; Vowels all cross the middle in an unbent line
  Char13 = a
  Char83 = b
  Char93 = c
  Char81 = d
  Char91 = e
  Char92 = f
  Char96 = g
  Char43 = h
  Char82 = i
  Char84 = j
  Char89 = k
  Char86 = l
  Char12 = m
  Char42 = n
  Char46 = o
  Char74 = p
  Char76 = q
  Char23 = r
  Char63 = s
  Char62 = t
  Char73 = u
  Char78 = v
  Char79 = w
  Char71 = x
  Char72 = y
  Char41 = z

  ; Commands: 
  ; Single Tap (Planned feature) or Double tap to use
  Char1 = ,
  Char11 = ,
  Char3 = .
  Char33 = .
  Char4 = {Tab}
  Char44 = {Tab}
  Char9 = {BackSpace}
  Char99 = {BackSpace}
  Char6 = {Enter}
  Char66 = {Enter} ; Note that Numpad Enter also works.

  ; Numbers:
  ; Start by pressing 5 then press 
  ; the number you want to type
  ; Note that this is different then the normal Thumpad's method.
  Char50 = 0
  Char51 = 1
  Char52 = 2
  Char53 = 3
  Char54 = 4
  Char55 = 5
  Char56 = 6
  Char57 = 7
  Char58 = 8
  Char59 = 9
  Char64 = 0 
  ; Backwards combo of O (letter) produces 0 if you hate using the 0 button

  ; Symbols:
  Char39 = (
  Char18 = ?
  Char19 = /
  Char29 = `{
    Char69 = <
    Char28 = |
    Char48 = =
    Char98 = '
    Char68 = `+
    Char21 = ~
    Char24 = ]
    Char47 = >
    Char67 = {ESC}
    Char32 = _
    Char36 = :
      Char26 = [
      Char37 = \
      Char87 = `
      Char97 = "
      Char17 = )
    Char27 = `}
    Char14 = `;
    return