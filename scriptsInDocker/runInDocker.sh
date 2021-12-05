#!/bin/bash

cd ${HOME}/

bash runFuzzer.sh	# sleep in "runFuzzer.sh" to let fuzzers find bugs

cd ${HOME}/

python3 runASan.py 
