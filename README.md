# ni-diadem-benchmarks
Basic test suite using the default example data to benchmark DIAdem performance on a given setup


I noticed that my work laptop a i7-6600 running 2.6GHz was running faster than my home Ryzen 9 3950x and started to look for why.
I was running the same script on the same dataset.  Every spec is better on my home PC than my work PC with the main difference being CPU.
Started to think we need a bench marking tool to be able to compare relative performance between systems.

Goals:
Use the example supplied with DIAdem if installed...

Basic search:

Setup
- Search for all files in the example folder
- Search for all groups in the example folder
- Search for all channels in the example folder

Figure of merit
Run this iteratively for 120 seconds then report the number of iterations and the run rate.

Indexing:
Setup
- Search for all indexed properties in the example dataset.
- Save which are indexed.
- unindex all the indexed items
- then index them again.

repeat this for TBD time.  
Figure of merit
store the number of runs in TBD time.


File Access:

Find N number of FILES from the dataset
- Open, get the File size
- save a copy
- delete the copy

Keep total of file cound and bytes written/read

Figure of merit:
- read MB/sec
- write MB/sec

