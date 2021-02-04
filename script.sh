#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo '
script is an utility script for the skyline project
--> It compiles sources under /src/ with make
--> It runs the source with as many datafiles you want
--> It compares results with the serial version

Usage: ./script mode [datafiles..]

Mode is an interger that corresponds to the parallel technology used. In particular:
	0: Open-mp
	1: mpi

In the datafiles.. argument you can specify which datafile you want to be tested.
If no datafile is provided circle-N1000-D2.in datafile will be used by default.
Example:
	./script 0  /datafiles/circle-N1000-D2.in		(only one datafile)
	./script 0 						(same as above)
	./script 0 $(find ./datafiles/ -name /'test[1234]*/') 	(first four test datafiles)
	./script 0 $(find ./datafiles/ -name /'*.in/') 		(all datafiles)

All results are saved in ./results/
'
	exit 0
fi

if [[ $# -eq 0 || ( "$1" != "0" && "$1" != "1" ) ]]; then
	echo 'Not valid input. 
Usage: ./script mode [datafiles..]. Use -h or --help to display the help message.'
	exit 128
fi

datafiles=""

if [[ $2 == "" ]]; then
	datafiles='./datafiles/circle-N1000-D2.in'
else
	for arg in "${@:2}"; do
		if [[ $datafiles == "" ]]; then
			datafiles=$arg
		else
			datafiles="${datafiles} $arg"
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
	if [[ -e $datafile ]]; then
		echo "computing $datafile.."
		temp="${datafile##*/}"
		temp="${temp::-2}out"
		serial="./results/serial-${temp}"
		./src/skyline < $datafile > $serial
		if [[ $1 -eq 0 ]]; then
			parallel="./results/omp-${temp}"
			./src/omp-skyline < $datafile > $parallel
		else
			parallel="./results/mpi-${temp}"
			./src/mpi-skyline < $datafile > $parallel
		fi
		if diff $serial $parallel; then
			echo -e "\nresults match!\n"
		       	((correct++))
		else
			echo -e "\nresults don't match!\n"
			((errors++))
		fi	
	else
		echo "$datafile doesn't  exits!"
	fi
done

#display goodbaye message
echo "all datafiles tested!
You got $correct matching results and $errors failed computations.
"
