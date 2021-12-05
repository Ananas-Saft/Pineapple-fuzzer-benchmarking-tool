#!/usr/bin/python3


import json

with open("dockerDependencies", "w") as dD:

    with open("initFuzzer.json", "r") as f:
        data = json.load(f)
        
        for dep in data["dockerDependencies"]:
            dD.write(dep+"\n")
       

#        print(json.dumps(data, skipkeys=False, indent=2))
#        print(type(data))
#        print(data["dockerDependencies"])

    with open("initProgram.json", "r") as f:
        data = json.load(f)

        for dep in data["dockerDependencies"]:
            dD.write(dep+"\n")


#        print(json.dumps(data, skipkeys=False, indent=2))
#        print(type(data))
#        print(data["dockerDependencies"])
