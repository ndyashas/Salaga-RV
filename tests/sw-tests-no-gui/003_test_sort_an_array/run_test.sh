#!/bin/bash

pushd $(dirname "$0")

../tb_utils/run_test.sh $(dirname "$0") "${1}"
