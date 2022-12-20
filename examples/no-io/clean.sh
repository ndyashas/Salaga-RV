#!/bin/bash

pushd $(dirname "$0")

for test_dir in */ ; do
    # Ignore symbolic links
    [ -L "${test_dir%/}" ] && continue
    [ "${test_dir%/}" == "gtkwave" ] && continue;
    [ "${test_dir%/}" == "tb_utils" ] && continue;

    "${test_dir}/clean.sh" >/dev/null 2>&1;

done
