#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo '
script is an utility script for the skyline project
--> It compiles sources under /src/ with make
--> It runs the source with as many datafiles you want
--> It compares results with the serial version

Usage: ./script method [-s] [datafiles..]

Method:
Method is a string that corresponds to the parallel technology used. In particular:
	omp: Open-mp parallel technology
	mpi: mpi parallel technology

-s	--silence	suppress output execution of skyline algorithms	

[datafiles..]
In the datafiles.. argument you can specify which datafile you want to be tested.
If no datafile is provided circle-N1000-D2.in datafile will be used by default.
Example:
	./script 0  /datafiles/circle-N1000-D2.in		(only one datafile)
	./script 0 						(same as above)
	./script 0 $(find ./datafiles/ -name /'test[1234]*/') 	(first four test datafiles)
	./script 0 -s $(find ./datafiles/ -name /'*.in/') 	(all datafiles, silent mode)

All results are saved in ./results/
'
	exit 0
fi

#check for mandatory argument
if [[ $# -eq 0 || ( "$1" != "omp" && "$1" != "mpi" ) ]]; then
	echo 'Not valid input. 
Usage: ./script mode [datafiles..]. Use -h or --help to display the help message.'
	exit 128
fi
mode=$1
shift; #deleting mandatory argument from $@

#check for silent mode
if [[ $1 == "-s" || $1 == "--silence" ]]; then
	exec 2>/dev/null
	shift; #deleting -s optional argument from $@
fi

#creating /results/ folder if not already exists
mkdir -p ./results/

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

#executing
correct=0
errors=0

for datafile in $datafiles; do
	echo "computing $datafile.."
	temp="${datafile##*/}"
	temp="${temp::-2}out"
	serial="./results/serial-${temp}"
	parallel="./results/${mode}-${temp}"
	./src/skyline < ${datafile} > $serial
	./src/${mode}-skyline < ${datafile} > $parallel
	if diff ${serial} ${parallel}; then
		echo -e "\nresults match!\n"
		((correct++))
	else
		echo -e "\nresults don't match!\n"
		((errors++))
	fi	
done

#display goodbaye message
echo "all datafiles tested!
You got $correct matching results and $errors failed computations.
"
