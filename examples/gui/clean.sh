#!/bin/bash

pushd $(dirname "$0")

for test_dir in */ ; do
    # Ignore symbolic links
    [ -L "${test_dir%/}" ] && continue
    [ "${test_dir%/}" == "utils" ] && continue;

    make -C "${test_dir}" clean;

done
