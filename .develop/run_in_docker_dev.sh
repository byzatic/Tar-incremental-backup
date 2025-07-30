#!/usr/bin/env bash
printf "Running scriptlet\n"
set -e
set -x

# shellcheck disable=SC2046
DIRECTORY=$(dirname $(readlink -e "$0"))

cd ${DIRECTORY}

bash ./debugger.sh ${DEBUGGER_CMD}