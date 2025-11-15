## Makefile for generating inputs
NPOINTS:=100000

CFLAGS=-Wall -Wpedantic -std=c99

.PHONY: all

all: \
	circle \
	test1 \
	test2 \
	test3 \
	test4 \
	test5 \
	test6 \
	test7 \
	worst

## a small 2d circle
circle:
	rbox 1000 s D2 W1 > circle.in

## surface of a 3d square
test1:
	rbox $(NPOINTS) W0 > test1.in

## surface of a 4d sphere
test2:
	rbox $(NPOINTS) s D4 > test2.in

## 10d diamond
test3:
	rbox $(NPOINTS) d D10 > test3.in

## 8d simplex
test4:
	rbox $(NPOINTS) y D8 > test4.in

## 20d sphere
test5:
	rbox $(NPOINTS) s D20 > test5.in

## 50d diamond
test6:
	rbox $(NPOINTS) d D50 > test6.in

## 200d diamond
test7:
	rbox $(NPOINTS) d D200 > test7.in

## worst-case scenario
worst: inputgen
	./inputgen $(NPOINTS) 10 > worst.in

clean:
	\rm -f *.in inputgen
