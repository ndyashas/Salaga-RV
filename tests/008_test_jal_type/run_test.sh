#!/bin/bash

pushd $(dirname "$0")

# Clean
rm -f a.out test_bin *.vcd *_actual.dump

# Compile design and run
iverilog tb.v ../../RTL/MEM/* ../../RTL/CORES/"${1}"/* -o test_bin
vvp test_bin

# Check correctness
diff -q rf_expected.dump rf_actual.dump >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "FAILED: JAL-Type test - Register file."
    exit 1
else
    echo "PASSED: JAL-Type test - Register file."
fi

diff -q dmem_expected.dump dmem_actual.dump >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "FAILED: JAL-Type test - DMEM."
    exit 1
else
    echo "PASSED: JAL-Type test - DMEM."
    exit 0
fi
