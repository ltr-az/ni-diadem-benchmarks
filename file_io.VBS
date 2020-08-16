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
Dim myChLoad
Dim myChSave
Dim myChRemove
Dim i, iteration
Dim currentDF
Dim runTime : runTime = 5
Dim myProp
Dim testName : testName = "File IO"
Dim myStats
Dim oMyQuery
Dim Result
Dim myChNames
Dim myPath
Dim j
Dim myFSO
Dim myFile
Dim grpCount
Dim mySum
Dim totalBytes
Dim fileCount
Dim elapsedTime


'Call main

sub main()

Set oTimerOverall = new oTimer
Set oTimer1 = new oTimer
Set myFSO = createObject("Scripting.FileSystemObject")

Set currentDF = Navigator.Display.CurrDataFinder
'clear out the search

currentDF.QueryForm.Clear
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Folder", "=", "C:\Program Files\National Instruments\DIAdem *\Examples\*")
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Filename", "=", "*.tdm or *.tdms")

if Data.Root.ChannelGroups.Exists(testName) then
  Data.Root.ChannelGroups.Remove(testName)
end if





currentDF.ResultsList.ResultsElements.MaxCount = 32000
Set oMyQuery = currentDF.QueryForm

oMyQuery.ReturnType = eSearchFile
currentDF.QueryForm.ResultsMode = eResultsModeElements
Call currentDF.QueryForm.Search

fileCount = currentDF.ResultsList.ResultsElements.Count

'Only need to create this channel once so move out of the loops
Set myGrp = Data.Root.ChannelGroups.Add(testName)
Set myChNames = myGrp.Channels.Add("File path", DataTypeChnString)


'Use this to store where to delete from after load
grpCount = Data.Root.ChannelGroups.Count

oTimerOverall.reset
oTimerOverall.start      

totalBytes = 0
      
for iteration = 1 to runTime

Set myChLoad = myGrp.Channels.Add("Load Run " & iteration, DataTypeChnFloat64)
myChLoad.UnitSymbol = "s"
Set myChSave = myGrp.Channels.Add("Save Run " & iteration, DataTypeChnFloat64)
myChSave.UnitSymbol = "s"
Set myChRemove = myGrp.Channels.Add("Remove Run " & iteration, DataTypeChnFloat64)
myChRemove.UnitSymbol = "s"





    for i = 1 to currentDF.ResultsList.ResultsElements.Count
      oTimer1.reset
      oTimer1.start
    
      'For Each Result in currentDF.ResultsList.ResultsElements
      Set Result = currentDF.ResultsList.ResultsElements(i)
    
      'Load the File
      myPath = Result.Properties("Folder").Value & "\" & Result.Properties("Filename").Value
      Set myFile = myFSO.GetFile(myPath)
      totalBytes = totalBytes + myFile.Size
      
      'Only store on initial loop
      if (iteration = 1) then
        myChNames.Values(i) = myPath
      end if
      oTimer1.start
      Call DataFileLoad(myPath)
      oTimer1.halt
      myChLoad.Values(i) = oTimer1.elapsed  
    
      'Save the current file
      oTimer1.reset
      oTimer1.start
      
      Call DataFileSave("C:\temp\DIADem_benchmark" & Result.Properties("Filename").Value)
      oTimer1.halt
      myChSave.Values(i) = oTimer1.elapsed
      
      'Remove the groups from the Portal (my not be file related but might as well store it)
      oTimer1.reset
      oTimer1.start
      
      'Remove the added channelGroups to the test groups.
      for j = Data.Root.ChannelGroups.Count to grpCount + 1 step -1
        Data.Root.ChannelGroups.Remove(j)
      Next
      oTimer1.halt
      myChRemove.Values(i) = oTimer1.elapsed
        
      runTime = oTimerOverall.elapsed
      if runTime = 0 then
        runTime = 1
      end if
 
      if i mod 10 = 0 then
        logFileWrite("iteration: " & iteration & " File " & i & " of " & currentDF.ResultsList.ResultsElements.Count & ") :" & testName & " " &  Round(((fileCount * (iteration - 1)) + i)/runTime ,2) & " files/sec   elapsed: " & runTime)
      end if    
      
        
    next
    

' NEED MILLISECOND TIMER for the below code.


    'Log the channel summary properties
    'Could loop over them but its the weekend... :)
'    mySum = 0
'    for j = 1 to myChLoad.Size
'      mySum = mySum + myChLoad.Values(j)
'    next


'    Set myProp = myChLoad.Properties.Add("time",mySum,DataTypeFloat32)
'    logfilewrite(myChLoad.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChLoad.Properties.Add("bytes",totalBytes,DataTypeInt32)
'    logfilewrite(myChLoad.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChLoad.Properties.Add("files per sec",myChLoad.Size / mySum,DataTypeFloat32)
'    logfilewrite(myChLoad.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChLoad.Properties.Add("rate", totalBytes / mySum,DataTypeFloat32)
'    logfilewrite(myChLoad.Name & ": " & myProp.Name & " = " & myProp.Value)
'    
'    
'    
'    mySum = 0
'    for j = 1 to myChSave.Size
'      mySum = mySum + myChSave.Values(j)
'    next
'
'    Set myProp = myChSave.Properties.Add("time",mySum,DataTypeFloat32)
'    logfilewrite(myChSave.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChSave.Properties.Add("bytes",totalBytes,DataTypeInt32)
'    logfilewrite(myChSave.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Call myChSave.Properties.Add("files per sec" ,myChSave.Size / mySum,DataTypeFloat32)
'    logfilewrite(myChSave.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChSave.Properties.Add("rate",totalBytes / mySum,DataTypeFloat32)
'    logfilewrite(myChSave.Name & ": " & myProp.Name & " = " & myProp.Value)
'    
'    mySum = 0
'    for j = 1 to myChRemove.Size
'      mySum = mySum + myChRemove.Values(j)
'    next
'
'    Set myProp = myChRemove.Properties.Add("time",mySum,DataTypeFloat32)
'    logfilewrite(myChRemove.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChRemove.Properties.Add("bytes",totalBytes,DataTypeInt32)
'    logfilewrite(myChRemove.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChRemove.Properties.Add("files per sec",myChRemove.Size / mySum,DataTypeFloat32)
'    logfilewrite(myChRemove.Name & ": " & myProp.Name & " = " & myProp.Value)
'    Set myProp = myChRemove.Properties.Add("rate",totalBytes / mySum, DataTypeFloat32)
'    logfilewrite(myChRemove.Name & ": " & myProp.Name & " = " & myProp.Value)

next

    oTimerOverall.halt
    elapsedTime = oTimerOverall.elapsed
    iteration = iteration - 1  'remove the last inc.

    logfilewrite("iteration count is " & iteration & ".  Total Runtime is " & elapsedTime)
    Set myProp = myGrp.Properties.Add("mean time",elapsedTime / iteration,DataTypeFloat32)
    logfilewrite(myGrp.Name & ": " & myProp.Name & " = " & myProp.Value)
    Set myProp = myGrp.Properties.Add("mean bytes",totalBytes / iteration,DataTypeInt32)
    logfilewrite(myGrp.Name & ": " & myProp.Name & " = " & myProp.Value)
    Set myProp = myGrp.Properties.Add("mean files per sec",fileCount * iteration / elapsedTime,DataTypeFloat32)
    logfilewrite(myGrp.Name & ": " & myProp.Name & " = " & myProp.Value)
    Set myProp = myGrp.Properties.Add("mean rate",totalBytes / elapsedTime,DataTypeFloat32)
    logfilewrite(myGrp.Name & ": " & myProp.Name & " = " & myProp.Value)



end Sub

