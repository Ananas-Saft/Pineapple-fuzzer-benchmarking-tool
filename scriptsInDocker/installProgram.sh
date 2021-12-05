#!/bin/bash

#import jq
cd ${HOME}/

echo getting variables for program installation

jsonData=$(cat ${HOME}/initProgram.json | jq ".program")

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
program_git_clone="$return_get_var_data"
get_var_data "git.checkout"
program_git_checkout="$return_get_var_data"
get_var_data "path"
program_path="$return_get_var_data"
get_var_data "configure_fuzz"
program_configure_fuzz="$return_get_var_data"


get_var_data "configure_ASan"
program_configure_ASan="$return_get_var_data"
#program_configure_ASan=$(echo ${jsonData} | jq -r ".configure_ASan" ) 			# (no -r)
echo "normal configure_ASan: 
$program_configure_ASan"


modded_noR_conf_ASan=$(echo ${jsonData} | jq ".configure_ASan" )
echo "modded configure_ASan:
$modded_noR_conf_ASan"


get_var_data "make"
program_make="$return_get_var_data"

CC="gcc"
CXX="g++"

formerCC=$CC
formerCXX=$CXX

echo $formerCC
echo $formerCXX


source ${HOME}/vars/compileProgram.sh
cat ${HOME}/vars/compileProgram.sh

echo making directories

cd ${HOME}/

mkdir fuzzProg
mkdir ASanProg
cd fuzzProg

echo ---------------

echo $CC
echo $CXX

echo ${CC_fuzzer}
echo ${CC_fuzzer}

echo $program_git_clone
git clone ${program_git_clone}

cd ./$program_path

git checkout $program_git_checkout

cp -r ./ ${HOME}/ASanProg/${program_path}  					# >>ASanProg test

echo "configure program for fuzzer with:
$program_configure_fuzz"
eval $program_configure_fuzz

#CC=${CC_Fuzzer} CXX=${CXX_Fuzzer} ./configure --with-features=huge --enable-gui=none
#./configure --with-features=huge --enable-gui=none
#CC=/home/fuzz/honggfuzz/hfuzz_cc/hfuzz-clang

echo $CC
echo $CXX

echo "make program for fuzzer with:
$program_make"
eval $program_make


echo ---------------


cd ${HOME}/

export CC=$formerCC
export CXX=$formerCXX
# g++ somehow was recognized as ’g++'

echo change dir to ASanProg
cd ${HOME}/ASanProg
#cp -r ~/fuzzProg/$program_path ~/ASanProg/
#git clone ${program_git_clone}
cd $program_path
pwd
ls
ls configure

#git checkout $program_git_checkout
echo "configure program for ASan with:
$program_configure_ASan"
eval $program_configure_ASan
echo test configure ""

#$program_configure CFLAGS="-fsanitize=address -ggdb" CXXFLAGS="-fsanitize=address -ggdb" LDFLAGS="-fsanitize=address" 
#./configure --with-features=huge --enable-gui=none CFLAGS="-fsanitize=address -ggdb" CXXFLAGS="-fsanitize=address -ggdb" LDFLAGS="-fsanitize=address"

echo "make program for ASan with:
$program_make"
eval $program_make

cd ${HOME}/
