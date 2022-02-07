#!/usr/bin/python3


import os
from multiprocessing import Pool
from datetime import datetime

size_pool = 8
os.system("mkdir ./PineappleResults")

#with open("./PineappleThreads", "r") as f:
#    global size_pool
#    size_pool = int(f.load())

timestamp = datetime.now().strftime("%Y-%b-%d_%H-%M")
os.mkdir("./PineappleResults/run_" + timestamp)
os.chdir("./tempDockerSetup")
working_dir = os.getcwd()


def work_process(subdir, container_nr):
    os.chdir(subdir)
    print("starting docker in: " + os.getcwd())
    container_name = "fuzz" + str(container_nr)
    
#    os.system("docker stop " + container_name)
    os.system("docker rm " + container_name)

    #print("building docker")
    #os.system("docker build --no-cache --pull -t " + container_name + " . " +  "> log_docker_build_run")   # debugging
    #os.system("docker build --no-cache -t " + container_name + " . " +  "> log_docker_build_run")          # debugging
    os.system("docker build -t " + container_name + " . " +  "> log_docker_build_run" + container_name)     # efficiency

    print("[ ] running docker container: " + container_name)
    os.system("docker run --name " + container_name +" "+ container_name +" "+ ">> log_docker_build_run" + container_name) # without -it
    global timestamp
    os.system("docker cp " + container_name + ":/home/fuzz/ASan_results" +" "+ "../../PineappleResults/run_" + timestamp + "/" + container_name) 
    #os.system("docker cp " + container_name + ":/home/fuzz/ASan_results" +" "+ "../../ASan_results/" + container_name + "_" + timestamp)
    print("[+] copied ASan_results/" + container_name)

    os.system("docker stop "+ container_name)
    os.system("docker rm " + container_name)

    global working_dir
    os.chdir(working_dir)

def pool_manager(nr=2):
    p = Pool(nr)
    print(nr)

    docker_nr = 20 
    var_list = []
    #print(list(filter(os.path.isdir, os.listdir(".") )) )

    for subdir in list(filter(os.path.isdir, os.listdir(".") )):
        var = (subdir, docker_nr)
        var_list.append(var)
        docker_nr += 1
    print(var_list)
    p.starmap(work_process, var_list)



pool_manager(size_pool)

