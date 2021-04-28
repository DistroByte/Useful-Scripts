#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Sleep, 5000

Loop {
  Send, This is for xp
    Send, {Enter}
  Sleep, 30000
}