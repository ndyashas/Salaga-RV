#!/bin/bash

pushd $(dirname "$0")

rm -f *.vcd *_bin *_actual.dump *.fill
rm -f *.o *.elf *.bin *.dissasm
