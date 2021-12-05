#!/bin/bash

#import jq

cd ~/

jsonData=$(cat ~/initFuzzer.json | jq ".fuzzer")

echo $jsonData

get_var_data() {
	local var_suffix="$1"
	local var_data=$(echo ${jsonData} | jq -r ".${var_suffix}")
	return_get_var_data=$var_data
}

get_var_data "compile.path"
fuzzer_pre_path=$return_get_var_data
get_var_data "compile.sub_path"
fuzzer_sub_path=$return_get_var_data
fuzzer_path="~/${fuzzer_pre_path}${fuzzer_sub_path}"			# addressable path for commands

get_var_data "exportable_environment_var[]"
fuzzer_environment_var=$return_get_var_data
echo $fuzzer_environment_var
for env_var in $fuzzer_environment_var
	do
		export $env_var
	done

get_var_data "args.in"
fuzzer_in=$return_get_var_data
echo $fuzzer_in
get_var_data "args.out_write[]"
fuzzer_out_list=$return_get_var_data
echo $fuzzer_out_list
fuzzer_out=""
for f_out in $fuzzer_out_list
	do
		fuzzer_out="${fuzzer_out} ${f_out}"
	done
echo $fuzzer_out
get_var_data "args.timeout_set_on_ms"
fuzzer_timeout=$return_get_var_data					# in milliseconds
echo $fuzzer_timeout
get_var_data "args.time_duration_set_on_s"
fuzzer_time_duration=$return_get_var_data				# in seconds
echo $fuzzer_time_duration
get_var_data "args.time_duration_nr_in_s"
fuzzer_time_duration_nr=$return_get_var_data				# in seconds
echo $fuzzer_time_duration_nr
get_var_data "args.extra[]"
fuzzer_extra_list=$return_get_var_data
echo "$fuzzer_extra_list --> list"
fuzzer_extra=""
for f_extra in $fuzzer_extra_list
        do
                fuzzer_extra="${fuzzer_extra} ${f_extra}"
        done
echo $fuzzer_extra
get_var_data "args.file_insert"
fuzzer_file_insert=$return_get_var_data
echo $fuzzer_file_insert
get_var_data "args.mark_off_program"
fuzzer_mark_off_program=$return_get_var_data
echo $fuzzer_mark_off_program

get_var_data "multithreading_suffix[]"
fuzzer_multithreading_suffix=$return_get_var_data
echo "$fuzzer_multithreading_suffix --> multithreading_suffix"

fuzzer_arguments="$fuzzer_in $fuzzer_out $fuzzer_timeout $fuzzer_time_duration $fuzzer_extra"

############################################

jsonData=$(cat ./initProgram.json | jq -r ".program")

echo $jsonData

get_var_data "path"
program_pre_path=$return_get_var_data
get_var_data "sub_path"
program_sub_path=$return_get_var_data
program_path="~/fuzzProg/${program_pre_path}${program_sub_path}"	# addressable path for commands
get_var_data "args[]"
program_args_list=$return_get_var_data
echo "$program_args_list --> list"
program_args=""
for p_args in $program_args_list
        do
		if [[ $p_args == "@@" ]]
			then
				p_args=$fuzzer_file_insert
			fi
		program_args="${program_args} ${p_args}"
        done

echo forming and executing commands for fuzzer

if [[ !(-n $(echo $fuzzer_multithreading_suffix) ) ]]
	then
		echo single-threading
		echo "fuzzing thread:"
                exec_fuzzer="${fuzzer_path} ${fuzzer_arguments} ${f_thread} ${fuzzer_mark_off_program} $program_path $program_args &"
	#	eval $exec_fuzzer
		echo $fuzzer_path
                echo "$exec_fuzzer"
		exec_fuzzer_test=$(echo "$exec_fuzzer")
		echo $exec_fuzzer_test
		eval $exec_fuzzer_test

		echo $exec_fuzzer > temp.txt
	#	bash ~/testt.sh


#		echo "$exec_fuzzer_test" | eval
#		~/honggfuzz/honggfuzz
#		$exec_fuzzer_test
#		echo testtt
#		testtt="ls"
#		$testtt
#		eval $testtt
#		$exec_fuzzer

	else
	echo multi-threading
	for f_thread in $fuzzer_mulithreading_suffix
	do
		echo "fuzzing thread:"
		exec_fuzzer="${fuzzer_path} ${fuzzer_arguments} ${f_thread} ${fuzzer_mark_off_program} $program_path $program_args &"
		echo "$exec_fuzzer"
#		eval $exec_fuzzer	
		echo $fuzzer_path
                echo "$exec_fuzzer"
		exec_fuzzer_test=$(echo "$exec_fuzzer")
		echo $exec_fuzzer_test
		eval $exec_fuzzer_test
#		echo $exec_fuzzer > temp.txt
#		bash ~/testt.sh


#		testtt="ls"
#		$testtt
#		eval $testtt
#		$exec_fuzzer
	done
fi

echo fuzzing has started

echo waiting to finish fuzzing

sleep $((fuzzer_time_duration_nr + 10))
echo sleep ended
