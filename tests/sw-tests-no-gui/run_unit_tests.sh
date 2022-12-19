#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pushd $(dirname "$0")

# This script invokes 'run_test.sh' scripts inside each of the sub-directories
# the exit code of these scripts specify wheather the tests were successful or not

exit_code=0
# Iterate through all directories
for test_dir in */ ; do
    # Ignore symbolic links
    [ -L "${test_dir%/}" ] && continue
    [ "${test_dir%/}" == "gtkwave" ] && continue;
    [ "${test_dir%/}" == "tb_utils" ] && continue;

    # Run the test
    "${test_dir}/run_test.sh" "${1}" >/dev/null 2>&1;

    # Check the status of the test, if failed, print it out.
    if [ $? -ne 0 ]; then
	echo -e "${RED}FAILED: ${test_dir%/}.${NC}"
	exit_code=1
    else
	echo -e "${GREEN}PASSED: ${test_dir%/}.${NC}"
    fi
done

exit $exit_code
