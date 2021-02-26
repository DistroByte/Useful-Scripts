#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Sleep 2000
Run, cmd.exe
Sleep, 200
Send, {Text}C:\Users\James\Documents\Luamacros\LuaMacros.exe -r "C:\Users\James\Documents\Useful Scripts\2nd-keyboard\macros.lua"
Sleep, 100
Send, {Enter}
Sleep, 100
ControlSend,, exit{Enter}, ahk_exe cmd.exe
Return