'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 08/10/2020 22:14:46
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.
Call ScriptInclude("oTimer.vbs")
Dim oTimer1, oTimerOverall
Dim iterationCount : iterationCount = 0
Dim myGrp
Dim myChannels
Dim myCh
Dim i
Dim currentDF
Dim runTime : runTime = 120
Dim myProp

sub main()

Set oTimer1 = new oTimer
Set oTimerOverall = new oTimer



Set currentDF = Navigator.Display.CurrDataFinder
'clear out the search

currentDF.QueryForm.Clear
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Folder", "=", "C:\Program Files\National Instruments\DIAdem *\Examples\*")

if Data.Root.ChannelGroups.Exists("Dataset Example Basic Search") then
  Data.Root.ChannelGroups.Remove("Dataset Example Basic Search")
end if



Set myGrp = Data.Root.ChannelGroups.Add("Dataset Example Basic Search")
Set myCh = myGrp.Channels.Add("Return Files time",DataTypeChnFloat64)
myCh.UnitSymbol = "s"
Set myCh = myGrp.Channels.Add("Return channelGroups time",DataTypeChnFloat64)
myCh.UnitSymbol = "s"
Set myCh = myGrp.Channels.Add("Return channels time",DataTypeChnFloat64)
myCh.UnitSymbol = "s"

i = 1

oTimerOverall.start


do while (oTimerOverall.elapsed < runTime)

currentDF.ResultsList.Settings.MaxCount = 32000
oTimer1.start

currentDF.QueryForm.ReturnType = eSearchFile
Call currentDF.QueryForm.Search
oTimer1.halt
myGrp.Channels(1).Values(i) = oTimer1.elapsed

if (currentDF.ResultsList.ResultsElements.IsIncomplete ) then
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " (max)  time:" & oTimer1.elapsed)
else
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " time:" &oTimer1.elapsed)
end if

oTimer1.start
currentDF.QueryForm.ReturnType = eSearchChannelGroup
Call currentDF.QueryForm.Search
oTimer1.halt
myGrp.Channels(2).Values(i) = oTimer1.elapsed
if (currentDF.ResultsList.ResultsElements.IsIncomplete) then
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " (max)  time:" & oTimer1.elapsed)
else
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " time:" &oTimer1.elapsed)
end if

oTimer1.start
currentDF.QueryForm.ReturnType = eSearchChannel
Call currentDF.QueryForm.Search
oTimer1.halt
myGrp.Channels(3).Values(i) = oTimer1.elapsed

if (currentDF.ResultsList.ResultsElements.IsIncomplete) then
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " (max)  time:" & oTimer1.elapsed)
else
  logFileWrite("Iteration " & i & ") found: " &  currentDF.ResultsList.ResultsElements.Count & " time:" &oTimer1.elapsed)
end if
logFileWrite("elapsed: " & oTimerOverall.elapsed & "/" & runTime)
i = i + 1
Loop
oTimerOverall.halt

'Sub out the extra loop for indexing.
i = i - 1
Set myProp = myGrp.Properties.Add("runs", i,DataTypeInt32)
logfilewrite(myProp.Name & " = " & myProp.Value & " in " & runTime & " seconds")
'Protect the divisor
if runtime = 0 then 
  runTime = 1
end if

Set myProp = myGrp.Properties.Add("rate", cdbl(i / runTime),DataTypeFloat32)
logfilewrite(myProp.Name & " = " & myProp.Value & " runs/sec")

end sub