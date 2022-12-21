#!/bin/bash

pushd "${1}"

# Clean
rm -f a.out test_bin *.vcd *_actual.dump
make -f ../utils/make-imem-hex.mk clean

# Generate the imem.fill and dmem.fill files
make -f ../utils/make-imem-hex.mk
cp imem.fill dmem.fill

# Compile design and run
iverilog -D_SIM_ ../utils/tb.v ../../../RTL/SoC.v ../../../RTL/MEM/* ../../../RTL/CORES/"${2}"/* -o test_bin
vvp test_bin
