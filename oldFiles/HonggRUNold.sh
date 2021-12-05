#!/bin/bash

##### 	maybe add Version or core count for $2
# 	in function checkParameter


#####-------------------------------------------------------

echo starting Hongfuzz

if [[ $1 = -help ]]
	then
                        echo    "-ffmpeg to fuzz FFmpeg""
"                               "-help for more information"
                                exit 1
        fi




## current log nr (cl)
cl_nr=1
cl_dir=~/fuzzData/log_dir/honggf/log0_ffmpeg

## cache size
cache_sz=150

## set env variables

##### cl -> Current Log

## Current Log NumbeR (cl)
read cl_nr < var_runHonggF_cl_nr
cl_nr=$((++cl_nr))
echo $cl_nr > var_runHonggF_cl_nr


# echo env var set

## No UI (background)
# set -v later

########### move noUI to here
########### --> --verbose --threads 7

## create new log_dir

function newLogDIR() {

	##### cl -> Current Log
	cl_dir=~/fuzzData/log_dir/honggf/log${cl_nr}${1}

        mkdir $cl_dir
        cd $cl_dir
        echo new log dir set
	echo $cl_dir
}
newLogDIR

## start fuzzing
echo ----------------------------------------------------

echo start fuzzing

# check for parameter

function checkParameter() {
##### maybe add Fuzzer or Version for $2

        if [ -n $1 ]   # -n --> not empty | -z --> empty
                then
                        echo    found parameter"
	"			1 - $1"
	"			maybe even"
	"			2 - $2"
	"			3 - $3"
	"			or more
                else
                        echo missing parameter
			exit 1
        fi
}
checkParameter "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"

# exec functions

function startFuzzFFmpeg_Hongg() {
        
	# set noUI & LOG & core count
	

	honggfuzz -i ~/fuzzData/inHonggFuzz/ffmpeg/01Ticket8594/ -W ~/fuzzData/outHonggFuzz/ffmpeg/02Ticket8594/ -T --verbose --logfile "${cl_dir}/${cl_nr}_log" --threads 7 -- ~/fuzzData/honggInstrument/ffmpeg-4.1.5/ffmpeg -i ___FILE___ a.mp3

	
	#afl-fuzz -i ~/fuzzData/in_AFL/pbm -o ~/fuzzData/out_AFL/ffmpegPbm_01 -M main0 -- ~/fuzzData/Instrument/ffmpeg_CVE/ffmpeg-4.1.5/ffmpeg -i @@ > log_main0 &
	
	echo all Honggfuzz fuzzing threads have started
}

function startFuzzVIM_Hongg(){
	
	honggfuzz -i ~/fuzzData/inHonggFuzz/vim/01_in/ -W ~/fuzzData/outHonggFuzz/vim/01_out/ --tmout_sigvtalrm --verbose --logfile "${cl_dir}/${cl_nr}_log" --threads 7 -- ~/fuzzData/honggInstrument/vim/src/vim -u NONE -X -Z -e -s -S  ___FILE___ 
	
# -W | --workspace --> output
# -T | --tmout_sigvtalrm --> save crashes and timeouts
# ? -o
# ? -c '-qa!'

	echo all Honggfuzz fuzzing threads have started
}


# exec parameter

function execParameter() {
        case "$1" in
                -ffmpeg)
                        echo startFuzzing FFmpeg
			startFuzzFFmpeg_Hongg
                        ;;

		-vim)
			echo startFuzzing VIM
			startFuzzVIM_Hongg
			;;
               
                *)
                        echo    '||ERROR|| ERR: execParameter missing
                                > "could not start fuzzing"
                                > use -help for more information'
                        ;;
        esac

}
execParameter "$1" "$2" "$3"

echo ----------------------------------------------------

echo $cl_dir

echo starting script is finished
#####-------------------------------------------------
