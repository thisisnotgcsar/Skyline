#!/bin/bash

# Giulio Golinelli
# 0000883007
# 17/02/2021
# High Performance Computing
#
# Script utility



#check for help message
if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo '
script is an utility script for the skyline project
--> It compiles sources under /src/ with make
--> It runs the source with as many datafiles you want
--> It compares results with the serial version

Usage: ./script method [-s] [datafiles..]

Method:
Method is a string that corresponds to the parallel technology used. In particular:
	s: serial, not parallel
	o: Open-mp parallel technology
	m: mpi parallel technology

-s	--silence	suppress output execution of skyline algorithms	

[datafiles..]
In the datafiles.. argument you can specify which datafile you want to be tested.
If no datafile is provided circle-N1000-D2.in datafile will be used by default.
Example:
	./script.sh so /datafiles/circle-N1000-D2.in		(only one datafile, serial + omp)
	./script.sh os 						(same as above)
	./script.sh som $(find ./datafiles/ -name /'test[1234]*/')	(first four test datafiles, all methods)
	./script.sh mos -s $(find ./datafiles/ -name /'*.in/') 	(all datafiles, all methods, silent mode)

All results are saved in ./results/
'
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

#check for silent mode
if [[ $1 == "-s" || $1 == "--silence" ]]; then
	exec 2>/dev/null
	shift; #deleting -s optional argument from $@
fi

#creating /results/ folder if not already exists
mkdir -p ./results/

#make datafiles if not done yet
echo 'checking datafiles..'
make -C ./datafiles/

#loading datafiles
datafiles=""
if [[ $1 == "" ]]; then
	datafiles='./datafiles/circle-N1000-D2.in'
else
	for datafile in "${@}"; do
		if [[ -e $datafile ]]; then
			if [[ $datafiles == "" ]]; then
				datafiles=$datafile
			else
				datafiles="${datafiles} $datafile"
			fi
		else
			echo "${datafile} doesn't  exits!"
		fi
	done
fi


#compile all sources
echo "compiling sources.."
make -C ./src

correct=0
failed=0
#for every datafile
for datafile in $datafiles; do
	echo -e "\n-> computing $datafile.."
	#builidng output filenames
	outs=''	
	temp="${datafile##*/}"
	temp="${temp::-2}out"
	temp_methods=$methods;
	#for every mode -> compute
	while [ -n "$temp_methods" ]; do
	    current_mode=${temp_methods:0:1}
	    out="./results/${current_mode}-${temp}"
	    outs="${outs} ${out}"
	    case "$current_mode" in
	    's')
		echo "computing serial.."
		./src/skyline < ${datafile} > ${out};;
	    'o')
		echo "computing omp.."
		./src/omp-skyline < ${datafile} > ${out};;
	    'm')
		echo "computing mpi.."
		mpirun ./src/mpi-skyline < ${datafile} > ${out};;
	    esac
	    temp_methods=${temp_methods:1}
	done
	outs=( $outs )
	if [[ ${#outs[@]} -gt 1 ]]; then
	    echo 'computing differences..'
	    if [[ ${#outs[@]} -eq 2 ]]; then
                diff ${outs[@]}
            else
                diff3 ${outs[@]}
            fi
	    if [[ $? -eq 0 ]]; then
		echo 'results match!'
		(( correct++ ))
            else
		echo "results don't match!"
	    	(( failed++ ))
	    fi
	fi
done

#display goodbaye message
echo -e "\nall datafiles tested!"
datafiles=( $datafiles )
echo "$correct correct and $failed failed matches upon ${#datafiles[@]} datafiles with $((${#datafiles[@]} * ${#methods})) total computations!"
