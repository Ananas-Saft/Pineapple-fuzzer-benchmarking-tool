#!/usr/bin/python3


#Add asan_parser to your project directly!
import asan_parser
import glob
import json
from datetime import datetime

def test():
    N_compare_count = 3

    CVE_stack = ["a", "b", "c"]

#    CVE_stack = CVE_bugcase.stack[:N_compare_count]
    
    f_stack = ["a","b","c","d","e","f","g"]
    print(N_compare_count-1)
    fuzz_stack = f_stack[:3]       # newest stack is at the beginning
    print(fuzz_stack)
#    print(CVE_stack)
#    print(fuzz_stack)
    
    n = 0
    for CVE_st in CVE_stack:
#        if n >= len(fuzz_stack):       # check if fuzz_stack has still stacks
#            break
        if CVE_st != fuzz_stack[n]:     # check if CVE_stack is the same as fuzz_stack
            break
        print(n)
        print()
        n += 1
    if n == N_compare_count:            # every stack is the same
        print("stacks match")
        return True
    else:
        print("stacks do not match")
        return False

test()
