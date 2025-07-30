#!/bin/bash -e
#
#
#

function __processing_controller() {
  local BEHAVIOR_KEY WORKING_DIRECTORY COMPONENT_NAME BACKUP_SOURCE UNIX_TIMESTAMP CHECK_BY
  local CONTROLLER_RESULT

  BEHAVIOR_KEY=$(set_e && check_input "${FUNCNAME}" "BEHAVIOR_KEY" "${1}")
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${2}")
  COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" "${3}")
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" "${4}")
  UNIX_TIMESTAMP=$(set_e && check_input "${FUNCNAME}" "UNIX_TIMESTAMP" "${5}")
  CHECK_BY=$(set_e && check_input "${FUNCNAME}" "CHECK_BY" "${6}")

  logging "DEBUG" "${FUNCNAME}" "run ${BEHAVIOR_KEY}"

  case ${BEHAVIOR_KEY} in
    "run_init")
      logging "INFO" "${FUNCNAME}" "called run_init"
      # TODO: Very dirty cheat ( | tail -n1 ) but it's working,
      #  otherwise all logging stdout accumulate in CONTROLLER_RESULT;
      #  I don't know why, and I don't have any time to debug it.
      CONTROLLER_RESULT=$(set_e && init_controller ${WORKING_DIRECTORY} ${BACKUP_SOURCE} ${UNIX_TIMESTAMP} ${COMPONENT_NAME} | tail -n1)
      if [ "$?" == "1" ]; then
        logging "CRITICAL" "${FUNCNAME}" "the init_controller has failed"
        system_exit 1
      fi
      case ${CONTROLLER_RESULT} in
        "cmd:initialisation_pass")
          freturn "0"
          ;;
        "cmd:initialisation_complete")
          freturn "1"
          ;;
        *)
          logging "CRITICAL" "${FUNCNAME}" "Initialisation controller has entered an uncertain state -> CONTROLLER_RESULT=${CONTROLLER_RESULT}"
          system_exit 1
          ;;
      esac
      ;;
    "run_force")
      logging "INFO" "${FUNCNAME}" "called run_init"
      reinitialisation ${WORKING_DIRECTORY} "${COMPONENT_NAME}" ${BACKUP_SOURCE} ${UNIX_TIMESTAMP}
      ;;
    "run_main")
      logging "INFO" "${FUNCNAME}" "called run_init"
      __core "${WORKING_DIRECTORY}" "${TS_NOW}" "${BACKUP_SOURCE}" "${FORCE_FLAG}" "${COMPONENT_NAME}" "${CHECK_BY}"
      ;;
    *)
      logging "CRITICAL" "__processing_controller" "__processing_controller have no option ${BEHAVIOR_KEY}"
      system_exit 1
      ;;
  esac
}

function business_logic () {
    #
    # :: $1 -- str -- backup sources directory
    # :: $2 -- int -- flag: force work directory state, cleanup and call initialisation
    #
    local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE COMPONENT_NAME CHECK_BY FORCE_FLAG
    #
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --working-directory)
                WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${2})
                shift 2
                ;;
            --ts-now)
                TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
                shift 2
                ;;
            --backup-source)
                BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${2})
                shift 2
                ;;
            --component-name)
                COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" ${2})
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
            *)
                logging "CRITICAL" "${FUNCNAME}" "Error: Unknown argument '${1}'"
                system_exit 1
                ;;
        esac
    done

    if [ "${FORCE_FLAG}" == "1" ]; then
      logging "INFO" "${FUNCNAME}" "Reinitialization requesting"
      __processing_controller "run_force" "${WORKING_DIRECTORY}" "${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${TS_NOW}" "${CHECK_BY}"
      logging "INFO" "${FUNCNAME}" "Reinitialization complete"
    else
      logging "INFO" "${FUNCNAME}" "Initialization requesting"
      INIT_STATE=$(set_e && __processing_controller "run_init" "${WORKING_DIRECTORY}" "${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${TS_NOW}" "${CHECK_BY}")
      if [ "$?" == "1" ]; then
        logging "CRITICAL" "${FUNCNAME}" "the processing_controller has failed"
        system_exit 1
      fi

      if [ "${INIT_STATE}" == "0" ]; then
        logging "INFO" "${FUNCNAME}" "Initialization not need"
        logging "INFO" "${FUNCNAME}" "Core job requesting"
        __processing_controller "run_main" "${WORKING_DIRECTORY}" "${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${TS_NOW}" "${CHECK_BY}"
        logging "INFO" "${FUNCNAME}" "Core job complete"
      else
        logging "INFO" "${FUNCNAME}" "Initialization complete"
      fi
    fi
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
