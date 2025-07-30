#!/bin/bash -e

MODULES="$(dirname $(realpath "$0"))/src"
# lib
. ${MODULES}/lib/root/_root.sh --source-only
# support
. ${MODULES}/support/version.sh --source-only
# backup_controller
. ${MODULES}/backup_controller/check.sh --source-only
. ${MODULES}/backup_controller/a_cell.sh --source-only
. ${MODULES}/backup_controller/backup_tar_controller.sh --source-only
. ${MODULES}/backup_controller/directory_structure_controller.sh --source-only
# processing
. ${MODULES}/processing/processing.sh --source-only
. ${MODULES}/processing/core.sh --source-only
. ${MODULES}/processing/managers.sh --source-only
# processing.initialisation
. ${MODULES}/processing/initialization/init_controller.sh --source-only
. ${MODULES}/processing/initialization/upgrade.sh --source-only
# business_logic
. ${MODULES}/main_business_logic.sh --source-only


function main() {
  # TODO: EXCLUDE_FILE
  local WORKING_DIRECTORY SOURCE_DIRECTORY GLOBAL_FORCE_FLAG BACKUP_PLAN CURRENT_TIMESTAMP
  #
  init_logger "std" "DEBUG" "$(dirname $(realpath "$0"))/backup_controller.log"
  #
  while [[ $# -gt 0 ]]; do
      case "$1" in
          --working-directory)
              WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${2}")
              #logging "DEBUG" "${FUNCNAME}" "working directory WORKING_DIRECTORY= ${WORKING_DIRECTORY}"
              shift 2
              ;;
          --source-directory)
              SOURCE_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "SOURCE_DIRECTORY" "${2}")
              #logging "DEBUG" "${FUNCNAME}" "source directory SOURCE_DIRECTORY= ${SOURCE_DIRECTORY}"
              shift 2
              ;;
          --global-force-flag)
              GLOBAL_FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "GLOBAL_FORCE_FLAG" "${2}")
              #logging "DEBUG" "${FUNCNAME}" "force flag GLOBAL_FORCE_FLAG= ${GLOBAL_FORCE_FLAG}"
              shift 2
              ;;
          --backup-plan)
              BACKUP_PLAN=$(set_e && check_input "${FUNCNAME}" "BACKUP_PLAN" "${2}")
              #logging "DEBUG" "${FUNCNAME}" "backup plan BACKUP_PLAN= ${BACKUP_PLAN}"
              shift 2
              ;;
          --current-timestamp)
              CURRENT_TIMESTAMP=$(set_e && check_input "${FUNCNAME}" "CURRENT_TIMESTAMP" ${2} "$(set_e && date +%s)")
              #logging "DEBUG" "${FUNCNAME}" "current timestamp CURRENT_TIMESTAMP= ${CURRENT_TIMESTAMP}"
              shift 2
              ;;
          *)
              logging "CRITICAL" "${FUNCNAME}" "Unknown argument '${1}'"
              system_exit 1
              ;;
      esac
  done

  logging "DEBUG" "${FUNCNAME}" "application version $(get_version)"

  main_business_logic "${WORKING_DIRECTORY}" "${SOURCE_DIRECTORY}" "${GLOBAL_FORCE_FLAG}" "${BACKUP_PLAN}" "${CURRENT_TIMESTAMP}"
}


if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi