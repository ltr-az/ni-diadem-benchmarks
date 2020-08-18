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
Dim i, iteration
Dim currentDF
Dim runTime : runTime = 3
Dim myProp
Dim testName : testName = "sort"
Dim elapsedTime
Dim oMyQuery
Dim Result
Dim groupChannelCount
Dim thisFile
Dim chSort
Dim chSortUp
Dim channelSortCount : channelSortCount = 0
Dim channelSortSize
Dim myChannelElements
Dim myChannelRate
Dim myChannelRun

'Call main()

sub main()

Set oTimer1 = new oTimer
Set oTimerOverall = new oTimer



Set currentDF = Navigator.Display.CurrDataFinder
'clear out the search

currentDF.QueryForm.Clear
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Folder", "=", "C:\Program Files\National Instruments\DIAdem *\Examples\*")
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Filename", "=", "*.tdm or *.tdms")

if Data.Root.ChannelGroups.Exists(testName) then
  Data.Root.ChannelGroups.Remove(testName)
end if

Set myGrp = Data.Root.ChannelGroups.Add(testName)

'Store the original ChannelGroup Count
groupChannelCount = Data.Root.ChannelGroups.Count


currentDF.ResultsList.ResultsElements.MaxCount = 32000
Set oMyQuery = currentDF.QueryForm

oMyQuery.ReturnType = eSearchFile
currentDF.QueryForm.ResultsMode = eResultsModeElements
Call currentDF.QueryForm.Search

Set myChannelRun = myGrp.Channels.Add("Run", DataTypeChnFloat64)
Set myChannelElements = myGrp.Channels.Add("element size", DataTypeChnFloat64)
Set myCh = myGrp.Channels.Add("Sort time", DataTypeChnFloat64)


for iteration = 1 to runTime

channelSortCount = 0
channelSortSize = channelSortSize = 0
myChannelRun.Values(iteration) = iteration



'Load all the data from channels into the Data.Portal.
'NOTE that in 2020 if you try to load from the external search results >50 elements DIAdem crashes.
'Submitted bug report

for each thisFile in currentDF.ResultsList.ResultsElements
  Call DataFileLoad(thisFile.properties("Folder").Value & "\" & thisFile.properties("filename").Value)
next



oTimerOverall.start


myCh.UnitSymbol = "s"
  
for i = groupChannelCount + 1 to currentDF.ResultsList.ResultsElements.Count
  for each chSort in Data.Root.ChannelGroups(i).Channels
  
  channelSortCount = channelSortCount + 1
  oTimer1.reset
  oTimer1.start
  
  channelSortSize = channelSortSize + chSort.Size
  Set chSortUp = ChnMultipleSortExt(chSort,,"DOWN","LowerCase","false")
  Set chSortUp = chSortUp(1)

  Call ChnMultipleSortExt(chSortUp,,"UP","LowerCase","true")

  

  oTimer1.halt
  elapsedTime = oTimerOverall.elapsed
  if elapsedTime = 0 then
    elapsedTime = 1
  end if
 if channelSortCount mod 10 = 0 then
    logFileWrite("Run: " & iteration & " Channel " & channelSortCount & ") sort: " &  Round(channelSortCount / elapsedTime,2) & " ch/sec   Elements: " & channelSortSize & " elapsed: " & oTimerOverall.elapsed)
 end if

  oTimer1.reset
    
next
next


oTimerOverall.halt
myCh.Values(iteration) =  oTimerOverall.elapsed
myChannelElements(iteration) = channelSortSize
oTimerOverall.reset

for i = Data.Root.ChannelGroups.Count to groupChannelCount + 1 step -1
  'removing added sorted fields
  Call Data.Root.ChannelGroups.Remove(i)
next

Call currentDF.GetDataFinder.Refresh


next

'Calc stats
Set ChnResult = chnDiv(myChannelElements, myCh, "rate")
Set myChannelRate = ChnResult.Item(1)

if elapsedTime = 0 then 
  elapsedTime = 1
end if

Set ChnResult = ChnStatisticsChannelCalc(myCh, eStatsArithmeticMean, NOVALUE, NOVALUE, False, False, False, "NameName")
Set ChnResult = ChnStatisticsChannelCalc(myChannelElements, eStatsArithmeticMean, NOVALUE, NOVALUE, False, False, False, "NameName")
Set ChnResult = ChnStatisticsChannelCalc(myChannelRate, eStatsArithmeticMean, NOVALUE, NOVALUE, False, False, False, "NameName")


Set myProp = myGrp.Properties.Add("run_count", iteration - 1,DataTypeInt32)
logfilewrite(myProp.Name & " = " & myProp.Value)
Set myProp = myGrp.Properties.Add("mean elapsed", myCh.Properties("Result~Statistics~MeanValues~ArithmeticMean").Value,DataTypeInt32)
'Protect the divisor


Set myProp = myGrp.Properties.Add("mean rate", myChannelRate.properties("Result~Statistics~MeanValues~ArithmeticMean").Value, DataTypeFloat32)
logfilewrite(myProp.Name & " = " & myProp.Value & " rate")

Set myProp = myGrp.Properties.Add("mean rate", myChannelElements.properties("Result~Statistics~MeanValues~ArithmeticMean").Value, DataTypeFloat32)
logfilewrite(myProp.Name & " = " & myProp.Value & " element count")


end Sub

