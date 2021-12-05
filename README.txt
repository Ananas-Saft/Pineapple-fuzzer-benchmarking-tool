# Pineapple-fuzzer-benchmarking-tool

Pineapple is an open tool to benchmark fuzzers


As dependencies, you need add Docker

Before you start benchmarking, use 

  echo "your_thread_number" > PineappleThreads


within the directory to set how many containers should run simultaneously.

Then, copy the relevant JSON files into "execInitProgram" and "execInitFuzzer".

Now, you can run Pineapple with:

  ./runPineappleBenchmark.sh
  
  
The results will be written into ./PineappleResults/
