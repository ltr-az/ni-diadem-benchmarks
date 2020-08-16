'-------------------------------------------------------------------------------
'-- VBS script file
'-- Created on 08/04/2020 15:42:25
'-- Author: 
'-- Comment: 
'-------------------------------------------------------------------------------
Option Explicit  'Forces the explicit declaration of all the variables in a script.

Data.Root.Clear



Dim oScriptCollection : Set oScriptCollection = CreateObject("System.Collections.ArrayList")
Dim currentScript
Dim myPath
Dim testNo
Dim time_start
Dim time_end

myPath = CurrentScriptPath

Call oScriptCollection.Add("Basic Search")
Call oScriptCollection.Add("Indexing")
Call oScriptCollection.Add("file_io")

Data.Root.Clear
call getPCinfo()

Set time_start = Data.Root.Properties.Add ("test~start", now,DataTypeDate)
testNo = 1
for each currentScript in oScriptCollection
  Call ScriptInclude(myPath & currentScript, "Benchmark")
  
  logfilewrite("--- BEGING ---")
  logfilewrite("Test " & testNo & " " & currentScript)
  Call Benchmark.main()
  logfilewrite("--- END ---")
  testNo = testNo + 1
  
next

call getPCinfo()

Data.Root.Name = "DIAdem Benchmark"
Call Data.Root.Properties.Add ("version~major", 0,DataTypeInt16)
Call Data.Root.Properties.Add ("version~minor", 0,DataTypeInt16)
Call Data.Root.Properties.Add ("cm_ref", "https://github.com/ltr-az/ni-diadem-benchmarks",DataTypeString)
Set time_end = Data.Root.Properties.Add ("test~end", now,DataTypeDate)
Call Data.Root.Properties.Add ("test~time", DateDiff("s",time_end.Value,time_start.Value),DataTypeInt32)
logfileWrite ""
logfileWrite "*** Benchmark complete ***"
logfileWrite ""

sub getPCinfo()

  Dim oWMI
  Dim objItems
  Dim objProcessor
  Dim myPC
  
  Set oWMI = getObject("winmgmts:\\.\root\cimv2")
  Set objItems = oWMI.ExecQuery("Select * from Win32_Processor")
  for each objProcessor in objItems
  
  Call Data.Root.Properties.Add("system~manufacture", objProcessor.Manufacturer,DataTypeString)
  logfileWrite "Manufacturer: " & objProcessor.Manufacturer
  
  Call Data.Root.Properties.Add("system~Name", objProcessor.Name,DataTypeString)
  logfileWrite "Name: " & objProcessor.Name
  
  Call Data.Root.Properties.Add("system~Description", objProcessor.Description,DataTypeString)
  logfileWrite "Description: " & objProcessor.Description
  
  Call Data.Root.Properties.Add("system~MaxClockSpeed", objProcessor.MaxClockSpeed,DataTypeInt32)
  logfileWrite "Maximum Clock Speed: " & objProcessor.MaxClockSpeed
  
  next

end sub
