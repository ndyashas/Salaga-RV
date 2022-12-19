#!/bin/bash

pushd "${1}"

# Clean
rm -f a.out test_bin *.vcd *_actual.dump

# Compile design and run
iverilog ../tb_utils/tb.v ../../RTL/MEM/* ../../RTL/"${2}"/* -o test_bin
vvp test_bin

# Check correctness
diff -q rf_expected.dump rf_actual.dump >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "FAILED: Expected and actual register file contents differ."
    exit 1
else
    echo "PASSED: Expected and actual register file contents are same!"
fi

diff -q dmem_expected.dump dmem_actual.dump >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "FAILED: Expected and actual DMEM contents differ."
    exit 1
else
    echo "PASSED: Expected and actual DMEM contents are same!"
    exit 0
fi
