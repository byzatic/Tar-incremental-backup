#!/usr/bin/env bash
printf "Running scriptlet\n"
set -e
set -x

# shellcheck disable=SC2046
DIRECTORY=$(dirname $(readlink -e "$0"))

cd ${DIRECTORY}

bash ./backup_controller.sh --working-directory "/backup_output"  --source-directory "/backup_source" --global-force-flag "${FORCE_FLAG_STATE}" --backup-plan "${BACKUP_MODE}" --current-timestamp ""