#!/bin/bash -e
#
#
#

function __period_controller() {
  local BEHAVIOR_KEY
  local WORKING_DIRECTORY COMPONENT_NAME BACKUP_SOURCE UNIX_TIMESTAMP FORCE_UPGRADE

  BEHAVIOR_KEY=$(set_e && check_input "${FUNCNAME}" "BEHAVIOR_KEY" "${1}")
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${2}")
  COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" "${3}")
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" "${4}")
  UNIX_TIMESTAMP=$(set_e && check_input "${FUNCNAME}" "UNIX_TIMESTAMP" "${5}")
  FORCE_UPGRADE=$(set_e && check_input "${FUNCNAME}" "UNIX_TIMESTAMP" "${6}" "None")

  logging "DEBUG" "${FUNCNAME}" "run ${BEHAVIOR_KEY}"

  case ${BEHAVIOR_KEY} in
    "run_current_period")
       logging "INFO" "${FUNCNAME}" "called run_current_period"
       incremental_backup_controller "${WORKING_DIRECTORY}/${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${UNIX_TIMESTAMP}" "A0_HATCH"
       ;;
    "run_not_current_period")
       logging "INFO" "${FUNCNAME}" "called run_not_current_period"
       incremental_backup_controller "${WORKING_DIRECTORY}/${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${UNIX_TIMESTAMP}" "A0"
       move_a0_to_a0_hatch_cell "${WORKING_DIRECTORY}/${COMPONENT_NAME}"
       if [ "${FORCE_UPGRADE}" == "FORCE_UPGRADE" ]; then
         logging "INFO" "${FUNCNAME}" "force upgrade"
         develop_file_logging "DEBUG" "${FUNCNAME}" "force upgrade"
       else
         develop_file_logging "DEBUG" "${FUNCNAME}" "run upgrade"
         upgrade_kit_controller "${COMPONENT_NAME}" "${WORKING_DIRECTORY}"
       fi
       ;;
    *)
      logging "CRITICAL" "${FUNCNAME}" "Unknown behavior key: ${BEHAVIOR_KEY}"
      system_exit 1
      ;;
  esac
}

function __processor() {
    local WORKING_DIRECTORY COMPONENT_NAME BACKUP_SOURCE TS_NOW COMPONENT_WORKING_DIRECTORY CHECK_BY FORCE_FLAG IGNORE_CURRENT_PERIOD FORCE_UPGRADE
    #
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --working-directory)
                WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${2})
                shift 2
                ;;
            --component-name)
                COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" ${2})
                shift 2
                ;;
            --backup-source)
                BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${2})
                shift 2
                ;;
            --ts-now)
                TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
                shift 2
                ;;
            --component-working-directory)
                COMPONENT_WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "COMPONENT_WORKING_DIRECTORY" ${2})
                shift 2
                ;;
            --check-by)
                CHECK_BY=$(set_e && check_input "${FUNCNAME}" "CHECK_BY" ${2})
                shift 2
                ;;
            --force-flag)
                FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${2})
                shift 2
                ;;
            --ignore-current-period)
                IGNORE_CURRENT_PERIOD=$(set_e && check_input "${FUNCNAME}" "IGNORE_CURRENT_PERIOD" ${2})
                shift 2
                ;;
            --who-is)
                WHO_IS=$(set_e && check_input "${FUNCNAME}" "WHO_IS" ${2})
                shift 2
                ;;
            --force-upgrade)
                FORCE_UPGRADE=$(set_e && check_input "${FUNCNAME}" "FORCE_UPGRADE" ${2})
                shift 2
                ;;
            *)
                logging "CRITICAL" "${FUNCNAME}" "Error: Unknown argument '${1}'"
                system_exit 1
                ;;
        esac
    done

    local FORCE_UPGRADE_VAL=$(if [ FORCE_UPGRADE == "Yes" ]; then echo "FORCE_UPGRADE"; else echo "None"; fi)
    logging "DEBUG" "${FUNCNAME}" "FORCE_UPGRADE_VAL is set to ${FORCE_UPGRADE_VAL}"

    if ( ! check_if_a0_current_period ${COMPONENT_WORKING_DIRECTORY} ${TS_NOW} ${CHECK_BY} ); then
      logging "DEBUG" "${FUNCNAME}" "a0 is not in current period"
      __period_controller "run_not_current_period" ${WORKING_DIRECTORY} "${COMPONENT_NAME}" ${BACKUP_SOURCE} ${TS_NOW} ${FORCE_UPGRADE_VAL}
    else
      logging "DEBUG" "${FUNCNAME}" "a0 is in current period"
      case "${IGNORE_CURRENT_PERIOD}" in
        "Yes")
          logging "DEBUG" "${FUNCNAME}" "Ignoring current period"
          ;;
        "No")
          logging "DEBUG" "${FUNCNAME}" "Call processing controller for current period"
          __period_controller "run_current_period" ${WORKING_DIRECTORY} "${COMPONENT_NAME}" ${BACKUP_SOURCE} ${TS_NOW} ${FORCE_UPGRADE_VAL}
          ;;
      esac

      logging "INFO" "${FUNCNAME}" "pass ${WHO_IS} processing"
    fi
    logging "INFO" "${FUNCNAME}" "${WHO_IS} processing complete"
}

function __core() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- flag: initialisation from non-initialised work directory state
  # :: $5 -- int -- flag: force work directory state, cleanup and call initialisation
  #
  local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE FORCE_FLAG COMPONENT_NAME CHECK_BY
  local IGNORE_CURRENT_PERIOD="Yes"
  local FORCE_UPGRADE="No"
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${1})
  TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${3})
  FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${4})
  COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" ${5})
  CHECK_BY=$(set_e && check_input "${FUNCNAME}" "CHECK_BY" ${6})
  #
  logging "DEBUG" "${FUNCNAME}" "Starting to process the ${COMPONENT_NAME}"

  if [ "${FORCE_FLAG}" == "1" ]; then
    __processing_controller "run_force" ${WORKING_DIRECTORY} "${COMPONENT_NAME}" ${BACKUP_SOURCE} ${TS_NOW}
  fi

  if [ "${COMPONENT_NAME}" == "DAYS" ]; then
    IGNORE_CURRENT_PERIOD="No"
    FORCE_UPGRADE="Yes"
  fi

  __processor \
      --working-directory "${WORKING_DIRECTORY}" \
      --component-name "${COMPONENT_NAME}" \
      --backup-source "${BACKUP_SOURCE}" \
      --ts-now "${TS_NOW}" \
      --component-working-directory "${WORKING_DIRECTORY}/${COMPONENT_NAME}" \
      --check-by "${CHECK_BY}" \
      --force-flag "${FORCE_FLAG}" \
      --ignore-current-period "${IGNORE_CURRENT_PERIOD}" \
      --who-is "${COMPONENT_NAME}" \
      --force-upgrade "${FORCE_UPGRADE}"

  logging "DEBUG" "${FUNCNAME}" "${COMPONENT_NAME} processing completed"

  case "${COMPONENT_NAME}" in
      "YEARS")
          logging "DEBUG" "${FUNCNAME}" "YEARS calls MONTHS"
          __core "${WORKING_DIRECTORY}" "${TS_NOW}" "${BACKUP_SOURCE}" "${FORCE_FLAG}" "MONTHS" "MoY"
          ;;
      "MONTHS")
          logging "DEBUG" "${FUNCNAME}" "MONTHS calls WEEKS"
          __core "${WORKING_DIRECTORY}" "${TS_NOW}" "${BACKUP_SOURCE}" "${FORCE_FLAG}" "WEEKS" "WoY"
          ;;
      "WEEKS")
          logging "DEBUG" "${FUNCNAME}" "WEEKS calls DAYS"
          __core "${WORKING_DIRECTORY}" "${TS_NOW}" "${BACKUP_SOURCE}" "${FORCE_FLAG}" "DAYS" "DoW"
          ;;
      "DAYS")
          logging "DEBUG" "${FUNCNAME}" "DAYS haven't child"
          ;;
      *)
          logging "CRITICAL" "${FUNCNAME}" "Error: Unknown component name: ${COMPONENT_NAME}"
          system_exit 1
          ;;
  esac

}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi