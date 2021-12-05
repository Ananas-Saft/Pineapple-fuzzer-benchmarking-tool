#!/bin/bash

# move to input directory for CVE
cd ${HOME}/
mkdir ${HOME}/inCVE
cd ${HOME}/inCVE/


echo getting variables for CVE

jsonData=$(cat ${HOME}/initProgram.json | jq ".program.CVE_file")

echo $jsonData

get_var_data() {
        local var_suffix="$1"
        local var_data=$(echo ${jsonData} | jq -r ".${var_suffix}")		# with "-r" to get raw
        return_get_var_data=$var_data
}

get_var_list() {
        local var_suffix="$1"                                                   # with [] at the end of "$1" to get a list
        local var_data=$(echo ${jsonData} | jq ".${var_suffix}")                # without "-r"
        return_get_var_list=$var_data						# also helps with true/false
}

get_var_data "link"
CVE_file_link_list="$return_get_var_data"
get_var_list "unpack"
CVE_file_unpack="$return_get_var_list"
get_var_data "unpack_cmd"
CVE_file_unpack_cmd="$return_get_var_data"


for CVE_file_link in $CVE_file_link_list
	do
	dlNR=0
	echo downloading input
	wget -O "inputFileCVE${dlNR}" $CVE_file_link
#	wget -O "CVEFile.tgz" $CVE_file_link

	if [[ $CVE_file_unpack ]]
		then
			echo unpacking downloaded file
			$CVE_file_unpack_cmd "inputFileCVE${dlNR}"
#			$CVE_file_unpack_cmd "CVEFile.tgz"
		fi
	((dlNR++))
	done
cd ${HOME}/
	
# move to input directory for Fuzzer
mkdir ${HOME}/inFuzz
mkdir ${HOME}/outFuzz
cd ${HOME}/inFuzz/

echo getting variables for program input

jsonData=$(cat ${HOME}/initProgram.json | jq ".program.inputs")

echo $jsonData

get_var_data "cmd_for_sample_files"
inputs_cmd_for_sample_files="$return_get_var_data"
get_var_list "link[]"
inputs_link="$return_get_var_list"
get_var_list"unpack"
inputs_unpack="$return_get_var_list"
get_var_data "unpack_cmd"
inputs_unpack_cmd="$return_get_var_data"

inputs_nr=0

#echo "a*b\+\|[0-9]\|\d{1,9}" > 1 ; echo "^\d{1,10}$" > 2
if [[ $inputs_cmd_for_sample_files ]]
	then
		echo "executing command to create sample files in dir $pwd
"		"$inputs_cmd_for_sample_files"
		eval $inputs_cmd_for_sample_files
		#echo $inputs_echo_write > input_echo_written
	fi

for file_URL in $inputs_link
	do
		wget -O input${inputs_nr} $file_URL
		inuts_nr=$((++inputs_nr))
		if [[ $inputs_unpack ]]
			then
				echo unpacking file to link $inputs_link
				$inputs_unpack_cmd 
			fi
	done

cd ${HOME}/
