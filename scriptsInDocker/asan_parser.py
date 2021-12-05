import os
import subprocess
import time
import signal
import re

# Taken and modified from https://github.com/tum-i4/macke/blob/wildfire/macke/Asan.py
# Author of original and modification: Fabian Kilger


def is_internal_function(name, location):
    if name == "free" or name == "raise" or name == "abort" or name == "gsignal":
        return True

    if name.startswith("__asan") or name.startswith("__sanitizer") or name.startswith("__interceptor"):
        return True

    if name.startswith("bool __sanitizer::") or name.startswith("__assert") or name.startswith("__GI___assert"):
        return True

    if "libasan" in location or "libc.so" in location:
        return True

    return False


def get_error_type_from_description(description):
    desc_parts = description.split(b' ')
    if b'on' in description:
        return b' '.join(desc_parts[0:desc_parts.index(b'on')]).decode("utf-8")
    else:
        return desc_parts[0].decode("utf-8", 'ignore').rstrip(':')
    return description

class AsanResult:
    """
    Container, that stores all information about a program run with asan
    """

    def __init__(self, program_output):
        self.output = program_output
        self.iserror = b"==ERROR:" in self.output
        self.errortype = None

        if self.iserror:
            self.parse_asan_output()

        # parse_asan_output might decide to set iserror to False
        if self.iserror:
            self.file, self.function, self.line = self.get_vulnerable_instruction()


    def get_errortype(self):
        return self.errortype

    def get_vulnerable_instruction(self):
        assert self.iserror
        if self.stack:
            location = self.stack[0][1]
            # Split into file, linenumber, lineoffset
            splits = location.split(':')
            if len(splits) > 1:
                return splits[0], self.stack[0][0], splits[1]
            return splits[0], self.stack[0][0], "0"
        return "<Unknown>", "<Unknown>", "0"

    def has_stack_trace(self):
        """ Return true if stack trace data is found """
        # Check for "#0" and "#1"
        return b"#0" in self.output and b"#1" in self.output

    def parse_asan_output(self):
        assert self.iserror

        lines = self.output.splitlines()
        for line in lines:
            # Get the first word after the "Sanitizer:" string on the line that contains "==ERROR:"
            if b"==ERROR:" in line:
                beginline = lines.index(line)
                description = line[line.find(b"Sanitizer:")+11:]
                description.strip()
                self.errortype = get_error_type_from_description(description)

                # On segfault check next line for READ/WRITE
                if self.errortype == "SEGV":
                    nl = lines[beginline+1]
                    if b"zero page" in nl:
                        nl = lines[beginline+2]
                    if b"READ" in nl:
                        self.errortype += " READ"
                    elif b"WRITE" in nl:
                        self.errortype += " WRITE"
                    else:
                        print(self.output)
                        assert False
                break
                    

        self.stack = []
        has_location = re.compile("^.*:[0-9]+:[0-9]+$")
        stack_entry_regex = re.compile(r"\s*#\d+ 0x[\da-f]* (?:in ([\S ]*))? (.*)")
        
        if self.has_stack_trace():
            # line number and frame-number
            lno = beginline + 1
            fno = 0

            while b"#0" not in lines[lno]:
                lno += 1

            while lno < len(lines) and b"#%d" % fno in lines[lno]:

                l = lines[lno].strip().decode("utf-8", 'ignore')

                match = stack_entry_regex.match(l)
                if not match:
                    break

                if match[1] is None:
                    fname = "<unknown>"
                else:
                    fname = match[1].strip()

                location = match[2]


                # Exclude internal functions
                if not is_internal_function(fname, location):
                    self.stack.append((fname, location))
                lno += 1
                fno += 1


def gently_kill_process(p):
    os.killpg(os.getpgid(p.pid), signal.SIGABRT)
    o = b""
    b = b""
    try:
        (o, e) = p.communicate(None, timeout=.1)
    except subprocess.TimeoutExpired:
        os.killpg(os.getpgid(p.pid), signal.SIGKILL)
        (o, e) = p.communicate()

    return o, e
        


def run_timed_process(command, *args, timeout=1, **kwargs):
    p = subprocess.Popen(command, *args, **kwargs, stdout=subprocess.PIPE, stderr=subprocess.PIPE, preexec_fn=os.setsid)


    output = b""
    err = b""
    try:
        (o, e) = p.communicate(None, timeout=timeout)
        output += o
        err += e
    # On hangup try to safely kill the process to get ASAN error messages
    except subprocess.TimeoutExpired:
        (o, e) = gently_kill_process(p)
        output += o
        err += e
        err += b"\n\nTIMEOUTED"

    return p.returncode, output, err


def get_stacktrace_for_testcase(program, args, testcase_file, timeout):
    """
    returns list of stacktrace entries (each one a dict with entries "file", "function", "linenumber")
    """
    menv = os.environ.copy()
    menv["ASAN_OPTIONS"] = "detect_leaks=0,handle_abort=1,handle_sigill=1"


    if any(map(lambda arg: arg == "@@", args)):
        # Copy args so that we can modify the copy
        args = args.copy()
        args[args.index("@@")] = testcase_file
        returncode, out, err = run_timed_process([program] + args, env=menv, timeout=timeout)
    else:
        infd = open(testcase_file, "r")
        returncode, out, err = run_timed_process([program] + args, stdin=infd, env=menv, timeout=timeout)
        infd.close()
    ar = AsanResult(err)

    if err.endswith(b"\n\nTIMEOUTED"):
        ar.errortype = "HANG"
    return ar
