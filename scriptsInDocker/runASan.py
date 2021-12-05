#!/usr/bin/python3


#Add asan_parser to your project directly!
import asan_parser
import glob
import json
from datetime import datetime

### var needed:

#global path_CVE_in
#global inputsFrom

def init_var():
    global path_CVE_in
    path_CVE_in = "/home/fuzz/inCVE/**"

    with open("./initFuzzer.json", "r") as f:
        data = json.load(f)["fuzzer"]

        global fuzzer_name
        fuzzer_name = data["compile"]["sub_path"]

        global path_fuzzer_out_w
        global sub_path_fuzzer_out_r_list
        path_fuzzer_out_w = data["args"]["out_write"][1] 
        sub_path_fuzzer_out_r_list = data["args"]["out_read"]

        global timeout_fuzzer_ms
        global timeout_s
        timeout_fuzzer_ms = data["args"]["timeout_nr_in_ms"]
        timeout_s = timeout_fuzzer_ms / 1000



    with open("./initProgram.json", "r") as f:
        data = json.load(f)["program"]

        global program_name
        global program_version
        program_name = data["sub_path"]
        program_version = data["git"]["checkout"]

        global program_path
        global program_args
        program_path = "/home/fuzz/ASanProg/" + data["path"] + data["sub_path"]
        program_args = data["args"]

        global N_compare_count
        N_compare_count = data["stack_N-compare"]


def get_all_inputs():

    # collect all CVE inputs --> index 0
    global path_CVE_in
    global path_fuzzer_out_w
    global inputsFrom
    inputs_from_CVE = []
#    if path_CVE_in[-1] == "/":
#        path_CVE_in = path_CVE_in + "**"
    print("Collected CVE inputs:")
    for files in glob.glob(path_CVE_in, recursive=True):
        inputs_from_CVE.append(files)
        print(files)
    #print(path_CVE_in)
    #print(glob.glob(path_CVE_in, recursive=True))
    print()

    # collect all fuzzer inputs --> index 1
    inputs_from_fuzzer = []
    print("sub_path_fuzzer_out_r_list:")
    print(sub_path_fuzzer_out_r_list)
    for sub_path in sub_path_fuzzer_out_r_list:
        if path_fuzzer_out_w[-1] != "/":
            path_fuzzer_out_w = path_fuzzer_out_w + "/"
        fuzzer_path = path_fuzzer_out_w + sub_path
        print("fuzzer_path (=path_fuzzer_out_w + sub_path):")
        print(fuzzer_path)
        for files in glob.glob(fuzzer_path, recursive=True):
            inputs_from_fuzzer.append(files)
        #print("files found:")
        #print(glob.glob(fuzzer_path, recursive=True))

    inputsFrom = [inputs_from_CVE, inputs_from_fuzzer]
    #print(inputsFrom)
    # end def


def execute_bugcase(program, bugArg, inputForBug):
    global timeout_s
    bugcase  = asan_parser.get_stacktrace_for_testcase(program, bugArg, inputForBug, timeout_s)
    
    return bugcase


def compare_stacktrace(CVE_stack, fuzz_bugcase, inputFromFuzzer):
#    print(":"+str(N_compare_count))
    global N_compare_count

#    CVE_stack = CVE_bugcase.stack[:N_compare_count]
    fuzz_stack = fuzz_bugcase.stack[:N_compare_count]       # newest stack is at the beginning
#    print(CVE_stack)
#    print(fuzz_stack)
    
    len_f_stack = len(fuzz_stack)

    if 0 == len_f_stack:            # skip emty stacks
        return False
    
    if N_compare_count > len_f_stack:        # skip short stacks
            print("short stack: " + str(len_f_stack) )
            return False
            #break

    n = 0
    for CVE_st in CVE_stack:
        if CVE_st != fuzz_stack[n]:     # check if CVE_stack is the same as fuzz_stack
            return False
            #break
        n += 1
    if n == N_compare_count:            # every stack is the same
        print("[+] fuzzed_bugcase equals CVE_bugcase in <" + str(n) + "> of " + str(N_compare_count) + " stacktraces to check")
        print("[+] input from Fuzzer has been " + str(inputFromFuzzer))
        return True
    else:
        return False


init_var()
get_all_inputs()

CVE_stacks = []
CVE_stacks_inputs = []
CVE_b_number = -1
for inCVE in inputsFrom[0]:
    global N_compare_count
    CVE_b_number += 1
    CVE_b = execute_bugcase(program_path, program_args, inCVE)
    print("CVE_b: ")
    print(CVE_b)

    print("iserror: " + str(CVE_b.iserror))
    if CVE_b.iserror:
        CVE_stack_till_N = CVE_b.stack[:N_compare_count]       # newest stack is at the beginning 
        CVE_stacks.append(CVE_stack_till_N)
        CVE_stacks_inputs.append(inCVE)
        print("stack till N=" + str(N_compare_count) + ": " + str(CVE_b.stack[:N_compare_count]))    
        print("program_path: " + program_path)
        print("program_args: " + str(program_args))
        print("inCVE: " + inCVE)

    else:
        print("[-] Input " + str(inCVE) + ", number " + str(CVE_b_number) + " hasn't generated a stacktrace and thus will be left out")
        continue


    #print("output.decode: " + str(CVE_b.output.decode('utf-8')))               # print decoded output
    #print("stack: " + str(CVE_b.stack))                                        # print stack
    #print("stack till N=" + str(N_compare_count) + ": " + str(CVE_b.stack[:N_compare_count]))

print(CVE_stacks)
print("[+] from inputs: ")
print(CVE_stacks_inputs)


if len(CVE_stacks) <= 0:
    exit("[!] ERROR: no valid CVE_input which produces a stacktrace could be found in " + path_CVE_in)
    exit(1)
elif len(CVE_stacks) == 1:
    print(str(len(CVE_stacks)) + " CVE_bugcase which produces a stacktrace has been found")
else:
    print(str(len(CVE_stacks)) + " CVE_bugcases which produces a stacktrace have been found")

with open("/home/fuzz/ASan_results", "w") as f:
    current_time = datetime.now()
    f.write("# ASan_results from " + str(current_time) + " (YYYY-MM-DD hh:mm:ss.ms__µs)" + "\n")
    f.write("# Benchmarked fuzzer " + fuzzer_name + " at program " + program_name +" "+ program_version + "\n")
    f.write("# Following inputfiles have the last " + str(N_compare_count) + " stackstraces in common as the inputs " + str(CVE_stacks_inputs) + "\n")       # str(inputsFrom[0])

    for input_by_fuzzer in inputsFrom[1]:
        #f.write("# following inputfiles have the last " + str(N_compare_count) + " stackstraces in common as the inputs " + str(CVE_stacks_inputs) + "\n")       # str(inputsFrom[0])
        fuzzer_b = execute_bugcase(program_path, program_args, input_by_fuzzer)
        # print(fuzzer_b.output.decode('utf-8'))
    
        if not(fuzzer_b.iserror):                                           # checking if any bug was found --> faster for-loop
            continue

        for CVE_s in CVE_stacks:       
#            if CVE_b.errortype != fuzzer_b.errortype:                       # comparing errortypes --> faster for-loop
#                continue

            if compare_stacktrace(CVE_s, fuzzer_b, input_by_fuzzer):        # comparing stacktraces
                print("[+] a matching pair of bugcases has been found")
                f.write("\n" + input_by_fuzzer)

