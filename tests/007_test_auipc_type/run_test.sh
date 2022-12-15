#!/bin/bash

pushd $(dirname "$0")

# Clean
rm -f a.out test_bin *.vcd *_actual.dump

# Compile design and run
iverilog tb.v ../../RTL/MEM/* ../../RTL/"${1}"/* -o test_bin
vvp test_bin

# Check correctness
diff -q rf_expected.dump rf_actual.dump >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "FAILED: LUI test."
    exit 1
else
    echo "PASSED: LUI test."
    exit 0
fi
