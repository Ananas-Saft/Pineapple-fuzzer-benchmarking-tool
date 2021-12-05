FROM ubuntu:20.04

# get time-zone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# get user

RUN useradd -m fuzz

# get minimum Dependencies for scripts
RUN apt-get -y update
#RUN apt-get -y apt-utils
RUN apt-get -y install git
RUN apt-get -y install build-essential
RUN apt-get -y install jq
RUN apt-get -y install python3
RUN apt-get -y install wget
# get Dependencies from file for fuzzer and program
ADD dockerDependencies /
RUN apt-get -y update && apt-get -y install $(cat ./dockerDependencies)


USER fuzz
WORKDIR /home/fuzz/

#ADD scriptsInDocker/ /home/fuzz/ 
RUN ls

# install Fuzzer
ADD initFuzzer.json /home/fuzz
ADD scriptsInDocker/installFuzzer.sh /home/fuzz
RUN /home/fuzz/installFuzzer.sh

# install CVE_program
ADD initProgram.json /home/fuzz
ADD scriptsInDocker/installProgram.sh /home/fuzz
RUN /home/fuzz/installProgram.sh

# add CVE_input
ADD scriptsInDocker/addInputFiles.sh /home/fuzz
RUN /home/fuzz/addInputFiles.sh

# add scripts
ADD scriptsInDocker/runInDocker.sh /home/fuzz/
ADD scriptsInDocker/runFuzzer.sh /home/fuzz/
ADD scriptsInDocker/asan_parser.py /home/fuzz/
ADD scriptsInDocker/__pycache__/ /home/fuzz/
ADD scriptsInDocker/runASan.py /home/fuzz/

# temp
RUN ls
RUN ls ~/fuzzProg/*/
RUN ls ~/ASanProg/*/ 

#CMD "/bin/sh"
CMD ["/home/fuzz/runInDocker.sh"]
