#!/bin/bash

# Giulio Golinelli
# 0000883007
# 17/02/2021
# High Performance Computing
#
# Script utility



#check for help message
if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo $'
script is an utility script for the skyline project
--> It compiles sources under /src/ and /datafiles/ with make
--> It runs as many sources, as many datafiles and as many cores you want with a single command
--> It compares datafile\'s output between eachother and shows differences

Usage: ./script method [-s] [--cores=\'list_of_cores\'] [datafiles..]

Method:
Method is a string that corresponds to the parallel technology used. In particular:
	s: serial, not parallel
	o: Open-mp parallel technology
	m: mpi parallel technology

-s	--silence	
suppress output execution of skyline algorithms	

--cores=list_of_cores
Optional argument used to test multiple cores.
list_of_cores is a numerical, space separated string representing the order of cores to be used in each method.
If not specified, max number of avaible cores is used.

[datafiles..]
In the datafiles.. argument you can specify which datafile you want to be tested.
If no datafile is provided circle-N1000-D2.in datafile will be used by default.

Examples:
	./script.sh so /datafiles/circle-N1000-D2.in	
	(only one datafile, serial + omp, max number of cores)
	
	./script.sh os	(same as above)
	
	./script.sh os --cores=\'1 2 4\'
	(same as above but first with 1, then with 2 and finally with 4 cores)
	
	./script.sh som $(find ./datafiles/ -name \'test[1234]*\')
	(first 4 test datafiles, all methods, max cores)
	
	./script.sh mos -s --cores=\'2\' $(find ./datafiles/ -name \'*.in\')
	(all datafiles, all methods, silent mode, 2 cores)

All results are saved in ./results/
'
	exit 0
fi

if [ "$1" == '-c' -o "$1" == '--compile-only' ]; then
	echo "-> Compiling datafiles..."
	make -C ./datafiles/
	echo "-> Compiling sources..."
	make -C ./src/
	exit 0
fi

#check for mandatory argument
# regex from: https://stackoverflow.com/questions/66201060/regex-operator-and-grep-e-fail/66201250#66201250
if ! echo "$1" | grep -qsP '^(?!.*(.).*\1)[som]+$'; then
	echo 'Not valid input. 
Usage: ./script method [datafiles..]. Use -h or --help to display the help message.'
	exit 128
fi

methods="$1"
shift; #deleting mandatory argument from $@

#by default the maximum number of cores is used
cores=$(nproc --all)
datafiles=''

#check for optional arguments
for arg in "${@}"; do
	#check for silent mode
	if [[ $arg == "-s" || $arg == "--silence" ]]; then
		exec 2>/dev/null
	#check for number of cores
	elif [[ $arg == --cores=* ]]; then
		cores=${arg:8}
	#check for daratfiles
	else
		if [[ -e $arg ]]; then
			if [[ $datafiles == '' ]]; then
				datafiles=$arg
			else
				datafiles="${datafiles} $arg"
			fi
		else
			echo "datafile ${arg} doesn't exits!"
		fi
	fi
done
#set default datafile
if [[ $datafiles == '' ]]; then
	datafiles='./datafiles/circle-N1000-D2.in'
fi

#creating /results/ folder if not already exists
mkdir -p ./results/

#make datafiles if not done yet
echo 'checking datafiles..'
make -C ./datafiles/


#compile all sources
echo "compiling sources.."
make -C ./src/

correct=0
failed=0
#for every datafile
for datafile in $datafiles; do
	echo -e "\n-> computing $datafile.."
	#builidng output filenames	
	temp="${datafile##*/}"
	temp="${temp::-2}out"
	#for every core
	for core in $cores; do
		temp_methods=$methods;
		#for every mode
		outs=''
		while [ -n "$temp_methods" ]; do
		    current_mode=${temp_methods:0:1}
		    out="./results/${current_mode}-${temp}"
		    outs="${outs} ${out}"
		    case "$current_mode" in
		    's')
			echo -e "\ncomputing serial.."
			./src/skyline < ${datafile} > ${out};;
		    'o')
			echo -e "\ncomputing omp with $core cores.."
			OMP_NUM_THREADS=$core ./src/omp-skyline < ${datafile} > ${out};;
		    'm')
			echo -e "\ncomputing mpi with $core cores.."
			mpirun -n $core ./src/mpi-skyline < ${datafile} > ${out};;
		    esac
		    temp_methods=${temp_methods:1}
		done
		outs=( $outs )
		if [[ ${#outs[@]} -gt 1 ]]; then
		    echo -e "\ncomputing differences.."
		    if [[ ${#outs[@]} -eq 2 ]]; then
			diff ${outs[@]}
		    else
			diff3 ${outs[@]}
		    fi
		    if [[ $? -eq 0 ]]; then
			echo '> results match!'
			(( correct++ ))
		    else
			echo "> results don't match!"
			(( failed++ ))
		    fi
		fi
	done
done

#display goodbaye message
echo -e "\nall datafiles tested!"
datafiles=( $datafiles )
computations=$((${#datafiles[@]} * ( $(grep -o ' ' <<< "$cores" | grep -c .) + 1 ) * ${#methods}))
echo "$correct correct and $failed failed matches upon ${#datafiles[@]} datafiles with $computations total computations!"
