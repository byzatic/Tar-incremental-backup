#!/bin/bash -e
#
#
#

function main_business_logic() {
  local WORKING_DIRECTORY SOURCE_DIRECTORY GLOBAL_INIT_FLAG GLOBAL_FORCE_FLAG BACKUP_PLAN CURRENT_TIMESTAMP
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${1}")
  SOURCE_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "SOURCE_DIRECTORY" "${2}")
  GLOBAL_FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "GLOBAL_FORCE_FLAG" "${3}")
  BACKUP_PLAN=$(set_e && check_input "${FUNCNAME}" "BACKUP_PLAN" "${4}")
  CURRENT_TIMESTAMP=$(set_e && check_input "${FUNCNAME}" "CURRENT_TIMESTAMP" "${5}")

  case ${BACKUP_PLAN} in
    "yearly")
      process_year "${WORKING_DIRECTORY}" "${CURRENT_TIMESTAMP}" "${SOURCE_DIRECTORY}" "${GLOBAL_FORCE_FLAG}"
      ;;
    "monthly")
      process_month "${WORKING_DIRECTORY}" "${CURRENT_TIMESTAMP}" "${SOURCE_DIRECTORY}" "${GLOBAL_FORCE_FLAG}"
      ;;
    "weekly")
      process_week "${WORKING_DIRECTORY}" "${CURRENT_TIMESTAMP}" "${SOURCE_DIRECTORY}" "${GLOBAL_FORCE_FLAG}"
      ;;
    "daily")
      process_day "${WORKING_DIRECTORY}" "${CURRENT_TIMESTAMP}" "${SOURCE_DIRECTORY}" "${GLOBAL_FORCE_FLAG}"
      ;;
    *)
      logging "CRITICAL" "${FUNCNAME}" "no such backup plan ${BACKUP_PLAN}"
      system_exit 1
      ;;
  esac
}

if [ "${1}" != "--source-only" ]; then
  main "${@}"
fi