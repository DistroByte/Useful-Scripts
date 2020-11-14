#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#singleinstance force
#Persistent

if 1	; screen coordinates
  coord=screen
else
  coord=relative
tooltip, %coord%
sleep, 1000

CoordMode, ToolTip, %coord%
CoordMode, Pixel, %coord%
CoordMode, Mouse, %coord%
CoordMode, Caret, %coord%
CoordMode, Menu, %coord%

SetTimer, WatchCursor, 100
return

WatchCursor:
  MouseGetPos,xpos , ypos 
  ToolTip, xpos: %xpos%`nypos: %ypos%
return

esc::exitapp

f12::reload