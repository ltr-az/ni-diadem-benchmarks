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
Dim runTime : runTime = 1
Dim myProp
Dim testName : testName = "Dataset indexing"
Dim myStats
Dim oMyQuery
Dim Result
Dim myChNames

sub main()

Set oTimer1 = new oTimer
Set oTimerOverall = new oTimer



Set currentDF = Navigator.Display.CurrDataFinder
'clear out the search

currentDF.QueryForm.Clear
Call currentDF.QueryForm.Conditions.Add(eSearchFile,"Folder", "=", "C:\Program Files\National Instruments\DIAdem *\Examples\*")

if Data.Root.ChannelGroups.Exists(testName) then
  Data.Root.ChannelGroups.Remove(testName)
end if

Set myGrp = Data.Root.ChannelGroups.Add(testName)

Set myChNames = myGrp.Channels.Add("File path",DataTypeChnString)

currentDF.ResultsList.ResultsElements.MaxCount = 32000
Set oMyQuery = currentDF.QueryForm

oMyQuery.ReturnType = eSearchFile
currentDF.QueryForm.ResultsMode = eResultsModeElements
Call currentDF.QueryForm.Search


oTimerOverall.start

for iteration = 1 to runTime

Set myCh = myGrp.Channels.Add("Re-indexing Run " & iteration, DataTypeChnFloat64)

for i = 1 to currentDF.ResultsList.ResultsElements.Count


  myCh.UnitSymbol = "s"

  oTimer1.reset
  oTimer1.start
  


  'For Each Result in currentDF.ResultsList.ResultsElements
  Set Result = currentDF.ResultsList.ResultsElements(i)
  Call currentDF.GetDataFinder.Indexer.ReindexElement(Result)    
  'Next
  oTimer1.halt
  runTime = oTimerOverall.elapsed
  if runTime = 0 then
    runTime = 1
  end if
 if i mod 10 = 0 then
  logFileWrite("File " & i & " of " & currentDF.ResultsList.ResultsElements.Count & ") Reindexing: " &  Round(i / runTIme,2) & " files/sec   elapsed: " & oTimerOverall.elapsed)
  end if

  myCh.Values(i) =  oTimer1.elapsed
  

  myChNames.Values(i) = Result.Properties("Folder").Value & "\" & Result.Properties("Filename").Value

  
  oTimer1.reset
    
next
next

oTimerOverall.halt

Call currentDF.GetDataFinder.Refresh
Set myStats = currentDF.GetDataFinder.Indexer.GetStatistics


runTime = oTimerOverall.elapsed
if runtime = 0 then 
  runTime = 1
end if
Set myProp = myGrp.Properties.Add("runs", i,DataTypeInt32)
logfilewrite(myProp.Name & " = " & myProp.Value & " in " & runTime & " seconds")
'Protect the divisor


Set myProp = myGrp.Properties.Add("rate", Round(i / runTime,2),DataTypeFloat32)
logfilewrite(myProp.Name & " = " & myProp.Value & " runs/sec")

Set myProp = myGrp.Properties.Add("efficiency", Round(myStats.IndexSize / runTime,2),DataTypeFloat32)
logfilewrite(myProp.Name & " = " & myProp.Value & " index size (kB) /sec")


logfilewrite ("Last Index Completion: " & myStats.LastCompleteIndexing.VariantDate  & VBCrLf _
& "Indexing Complete: " & myStats.IndexingComplete  & VBCrLf _ 
& "Analyzed Files: " & myStats.AnalyzedFiles & VBCrLf _
& "Indexed Files: " & myStats.IndexedFiles  & VBCrLf _ 
& "Indexed Groups: " & myStats.IndexedGroups  & VBCrLf _ 
& "Indexed Channels: " & myStats.IndexedChannels & VBCrLf _
& "Index Size: " & myStats.IndexSize)

end Sub

