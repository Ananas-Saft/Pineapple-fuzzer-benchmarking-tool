#!/bin/bash

if [[ $(cat /proc/sys/kernel/core_pattern) != core ]] 
	then	
		echo '[+] writing "core" to /prog/sys/kernel/core_pattern'
		sudo bash -c 'echo "core" > /proc/sys/kernel/core_pattern'			#sudo ./modify_core_pattern.sh
	fi

echo '[+] script sets up a docker container to fuzz old program versions for a CVE and then check for matches automatically'
#echo '[ ] this script needs docker and python3 to function properly'


echo '[ ] this script has been tested for "Docker version 20.10.7, build 20.10.7-0ubuntu1~20.04.1"'
echo "[ ] you are currently running: $(docker --version)"


echo '[ ] this script has been tested for "Python 3.8.10"'
echo "[ ] you are currently running: $(python3 --version)"

#echo '[ ] checking for "Dockerfile" in the current directory'
if test -f "./Dockerfile"
        then
                echo '[+] "Dockerfile" could be found in the current directory'
	else
		echo '[-] missing "Dockerfile" in the current directory and thus this script will be stopped'
		echo '[-] please start this script in its original directory'
		exit 2
	fi

### start (mulitple) docker container
echo "[ ] making temporary directories to start Docker containers"

rm -rf tempDockerSetup/				# right at $dir declaration to reduce conflicts; here to reduce used space
mkdir tempDockerSetup/
cd tempDockerSetup/
containerNr=0

for eIFuzzer in ../execInitFuzzer/*.json
do

	for eIProgram in ../execInitProgram/*.json
	do
		dir=fuzzTemp${containerNr}/
		echo [+] forming dir $dir
		mkdir $dir
		cd $dir

		pwd
		echo $eIFuzzer -- $eIProgram

		cp ../${eIFuzzer} ./initFuzzer.json
	
		cp ../${eIProgram} ./initProgram.json

		cp ../../Dockerfile ./
		cp ../../getDockerDependencies.py ./
		cp -r ../../scriptsInDocker/ ./

		

		#echo '[+] formatting dependencies from .json files for Docker'
		python3 getDockerDependencies.py


		#echo "[+] building docker in the directory: $(pwd)"
		#echo "[ ] $(pwd)" 
		
	#	containerName=fuzz${containerNr}
#		docker build --pull --no-cache -t ${containerName} .			# debugging
#		docker build --no-cache -t ${containerName} .				# debugging
	#	docker build -t ${containerName} .					# efficiency

	#	echo "[+] running docker container \"$containerName\""
	#	docker run -dit --name ${containerName} -d ${containerName}

		((containerNr++))
		cd ..
	done
done

cd ..

###########

python3 superviseDocker.py &
disown

