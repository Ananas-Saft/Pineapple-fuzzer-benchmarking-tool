#!/bin/bash

#import jq

echo getting variables for fuzzer installation

#jsonFuzzer=$(cat ./initFuzzer.json | jq ".fuzzer.compile") ; test=$(echo $jsonFuzzer | jq ".git") ; echo $test
jsonData=$(cat ${HOME}/initFuzzer.json | jq ".fuzzer.compile")

echo $jsonData

get_var_data() {
        local var_suffix="$1"
        local var_data=$(echo ${jsonData} | jq -r ".${var_suffix}")		# with "-r" to get raw
        return_get_var_data=$var_data
}

get_var_list() {
        local var_suffix="$1"                                                   # with [] at the end of "$1" to get list
        local var_data=$(echo ${jsonData} | jq ".${var_suffix}")                # without "-r"
        return_get_var_list=$var_data
}

get_var_data "git.clone"
fuzzer_git_clone="$return_get_var_data"
#echo $fuzzer_git_clone
get_var_data "git.checkout"
fuzzer_git_checkout="$return_get_var_data"
get_var_data "path"
fuzzer_path="$return_get_var_data"
get_var_data "make"
fuzzer_make="$return_get_var_data"
get_var_data "CC_compiler"
fuzzer_CC_compiler="$return_get_var_data"
get_var_data "CXX_compiler"
fuzzer_CXX_compiler="$return_get_var_data"


echo
echo $fuzzer_git_clone

echo
echo "installing Fuzzer <$fuzzer_path> starts"

cd ${HOME}/
git clone ${fuzzer_git_clone}
echo
cd $fuzzer_path

#git checkout ${fuzzer_git_checkout}

$fuzzer_make

mkdir ${HOME}/vars

echo export "CC=$fuzzer_CC_compiler" > ${HOME}/vars/compileProgram.sh
echo export "CXX=$fuzzer_CXX_compiler" >> ${HOME}/vars/compileProgram.sh

# echo "CC_Fuzzer=$fuzzer_CC_compiler" > /home/fuzz/vars/compileProg.sh
# echo "CXX_Fuzzer=$fuzzer_CXX_compiler" >> /home/fuzz/vars/compileProg.sh

cd ${HOME}/
