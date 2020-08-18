# ni-diadem-benchmarks
Basic test suite using the default example data to benchmark DIAdem performance on a given setup


I noticed that my work laptop a i7-6600 running 2.6GHz was running faster than my home Ryzen 9 3950x and started to look for why.
I was running the same script on the same dataset.  Every spec is better on my home PC than my work PC with the main difference being CPU.
Started to think we need a bench marking tool to be able to compare relative performance between systems.

Goals:
Use the example supplied with DIAdem if installed...

<b>Basic search:</b>

Setup
- Search for all files in the example folder
- Search for all groups in the example folder
- Search for all channels in the example folder

Figure of merit
Run this iteratively for 120 seconds then report the number of iterations and the run rate.

<b>Indexing:</b>

Setup
- find all the files in the examples.
- then re-index each file

test steps
The amount of time it takes to re-index all files and the time per files.


<b>File IO:</b>

Setup
- Find all the tdm and TDMS files in the example dataset

test steps
Load each file 
Save each file to C:\temp
remove the channelGroups added
repeat for each file in the example dataset
repeat this run 5 times.

output :
files per second
bytes per second
elapsed time

Figure of merit:
- Bytes / second


<b>Sorting</b>
Setup
- Loads all the examples data into the portal by file

Test steps iterate through 3 times.
- go through each channel and sort ascending and then sort decending
- keep cummulated number of elements sorted.
- record the time to sort for each iteration in a channel
- record the number of elements sorted.

Figure of merit:
- The total time to sort on each run
- The elements / sec / run
- the mean of these paramters are stored in the sort channelGroup


Storage of result datasets
- At the end of the test the commands to store the result back to github are printed in the log output.
- use these to commit to the ~/datasets folder or use the git tool of choice.

Comparisons
- The idea here being that you would clone the datasets to your drive.
- index the datasets folder
- then run some queries to get the data you want to compare.
- May get more fancy if anyone ever commits data.


