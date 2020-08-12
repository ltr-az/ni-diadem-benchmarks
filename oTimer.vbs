'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 08/10/2020 20:43:30
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

'Call unit_test

class oTimer
  Dim name
  Dim elapsedTime
  Dim timerList
  Dim startTime
  Dim endTIme
  Dim state
  Dim wshShell
  
function delay(seconds)
  Call wshShell.Run ("timeout /T " & seconds,1,1)
  'wshShell.Run " sleep " & milliseconds
  
end function


  

Private Sub Class_Initialize( ) 
    Set wshShell = CreateObject( "wscript.shell" )
    startTime = now
    endTime = startTime
    state = "stop"
end sub

Private Sub Class_Terminate
  Set wshShell = Nothing
end sub

function elapsed()
  endTime = now
  if (state = "halt") then
    elapsed = elapsedTime
  else
    elapsed = DateDiff("s", startTime, endTime) + elapsedTime
  end if
end function

function start()
  state = "start"
  startTime = now
end function

function reset()
  elapsedTime = 0
  startTime = now
  state = "stop"
end function

function halt()  
  state = "halt"
  endTime = now
  elapsedTime = DateDiff("s", startTime, endTime) + elapsedTime
end function
end class


function unit_test()

  Dim oMyTimer1
  Dim oMyTimer2
  Dim oMyTimer3

  Set oMyTimer1 = new oTimer
  'Set oMyTimer2 = new oTimer
  'Set oMyTimer3 = new oTimer
  
  'Basic one timer
  oMyTimer1.start
  oMyTimer1.delay 1
  logfilewrite("T1 delay 1: " & oMyTimer1.elapsed)
  oMyTimer1.delay 2
  logfilewrite("T1 delay 2: " & oMyTimer1.elapsed)
  oMyTimer1.delay 3  
  logfilewrite("T1 delay 3: " & oMyTimer1.elapsed)
  oMyTimer1.reset
  oMyTimer1.delay 1
  logfilewrite("T1 delay 1: " & oMyTimer1.elapsed)
  oMyTimer1.delay 2
  logfilewrite("T1 delay 2: " & oMyTimer1.elapsed)
  oMyTimer1.delay 3  
  logfilewrite("T1 delay 3: " & oMyTimer1.elapsed)
  oMyTimer1.reset
  oMytimer1.start
  oMyTimer1.delay 1
  logfilewrite("T1 delay 1: " & oMyTimer1.elapsed)
  oMyTimer1.delay 2
  logfilewrite("T1 delay 2: " & oMyTimer1.elapsed)
  oMyTimer1.halt
  oMyTimer1.delay 3
  oMyTimer1.start
  logfilewrite("T1 delay 3: " & oMyTimer1.elapsed)
  oMyTimer1.delay 4
  logfilewrite("T1 delay 4: " & oMyTimer1.elapsed)

  

 
end function