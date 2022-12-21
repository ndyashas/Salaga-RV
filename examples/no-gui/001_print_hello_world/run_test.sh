#!/bin/bash

pushd $(dirname "$0")

../utils/run_test.sh $(dirname "$0") "${1}"
