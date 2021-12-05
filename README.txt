# Pineapple-fuzzer-benchmarking-tool

Pineapple is an open tool to benchmark fuzzers


First, you need to clone this repository.
  
  git clone https://github.com/Ananas-Saft/Pineapple-fuzzer-benchmarking-tool

You will need set up Docker as dependency to run Pineapple.

Before you start benchmarking, use 

  echo "your_thread_number" > PineappleThreads


within the directory to set how many containers should run simultaneously.

Then, copy the relevant JSON files into "execInitProgram" and "execInitFuzzer".

Now, you can run Pineapple with:

  ./runPineappleBenchmark.sh
  
  
The results will be written into ./PineappleResults/
