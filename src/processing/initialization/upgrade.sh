#!/bin/bash -e
#
#
#

function reinitialisation() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- component name e.g. YEARS / MONTHS / WEEKS / DAYS
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- current timestamp
  #
  local WORKING_DIRECTORY
  local COMPONENT_NAME
  local BACKUP_SOURCE
  local TS_NOW
  lcoal BEHAVIOR_KEY
  #
  logging "INFO" "reinitialisation" "start"
  WORKING_DIRECTORY=$(set_e && check_input "reinitialisation" "WORKING_DIRECTORY" "${1}")
  COMPONENT_NAME=$(set_e && check_input "reinitialisation" "COMPONENT_NAME" "${2}")
  BACKUP_SOURCE=$(set_e && check_input "reinitialisation" "BACKUP_SOURCE" "${3}")
  TS_NOW=$(set_e && check_input "reinitialisation" "TS_NOW" "${4}")
  BEHAVIOR_KEY=$(set_e && check_input "reinitialisation" "BEHAVIOR_KEY" "${5}")
  #
  initialisation ${WORKING_DIRECTORY} ${COMPONENT_NAME} ${BACKUP_SOURCE} ${TS_NOW} ${BEHAVIOR_KEY}
  logging "INFO" "reinitialisation" "finish"
}

function initialisation() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- component name e.g. YEARS / MONTHS / WEEKS / DAYS
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- current timestamp
  #
  local WORKING_DIRECTORY COMPONENT_NAME BACKUP_SOURCE TS_NOW BEHAVIOR_KEY
  #
  logging "INFO" "initialisation" "start"
  WORKING_DIRECTORY=$(set_e && check_input "initialisation" "WORKING_DIRECTORY" "${1}")
  COMPONENT_NAME=$(set_e && check_input "initialisation" "COMPONENT_NAME" "${2}")
  BACKUP_SOURCE=$(set_e && check_input "initialisation" "BACKUP_SOURCE" "${3}")
  TS_NOW=$(set_e && check_input "initialisation" "TS_NOW" "${4}")
  BEHAVIOR_KEY=${COMPONENT_NAME}
  #
  directories_reinitialisation "${WORKING_DIRECTORY}/${COMPONENT_NAME}" "${WORKING_DIRECTORY}"
  incremental_backup_controller "${WORKING_DIRECTORY}/${COMPONENT_NAME}" "${BACKUP_SOURCE}" "${TS_NOW}" "A0"
  move_a0_to_a0_hatch_cell "${WORKING_DIRECTORY}/${COMPONENT_NAME}"
  upgrade_kit_controller "${BEHAVIOR_KEY}" "${WORKING_DIRECTORY}"

  logging "INFO" "initialisation" "finish"
}

function upgrade_kit_controller() {
  local BEHAVIOR_KEY WORKING_DIRECTORY
  logging "INFO" "upgrade_kit_controller" "start"
  BEHAVIOR_KEY=$(set_e && check_input "upgrade_kit_controller" "BEHAVIOR_KEY" "${1}")
  WORKING_DIRECTORY=$(set_e && check_input "upgrade_kit_controller" "WORKING_DIRECTORY" "${2}")
  case ${BEHAVIOR_KEY} in
    "YEARS")
      __upgrade_kit_years ${WORKING_DIRECTORY}
      ;;
    "MONTHS")
      __upgrade_kit_months ${WORKING_DIRECTORY}
      ;;
    "WEEKS")
      __upgrade_kit_weeks ${WORKING_DIRECTORY}
      ;;
    "DAYS")
      logging "INFO" "upgrade_kit_controller" "upgrade_kit_controller have no upgrade_kit for DAYS"
      ;;
    *)
      logging "CRITICAL" "upgrade_kit_controller" "no such upgrade kit for behavior key BEHAVIOR_KEY= ${BEHAVIOR_KEY}"
      system_exit 1
      ;;
  esac
  logging "INFO" "upgrade_kit_controller" "finish"
}

function __upgrade_kit_years() {
  __upgrade_child ${WORKING_DIRECTORY} "YEARS" "MONTHS"
  __upgrade_child ${WORKING_DIRECTORY} "YEARS" "WEEKS"
  __upgrade_child ${WORKING_DIRECTORY} "YEARS" "DAYS"
}

function __upgrade_kit_months() {
  __upgrade_child ${WORKING_DIRECTORY} "MONTHS" "WEEKS"
  __upgrade_child ${WORKING_DIRECTORY} "MONTHS" "DAYS"
}

function __upgrade_kit_weeks() {
  __upgrade_child ${WORKING_DIRECTORY} "WEEKS" "DAYS"
}

function __upgrade_child() {
  #
  # :: $1 -- str -- working directory
  # :: $2 -- str -- parent name (e.g. "YEARS" or "MONTHS" or "WEEKS" or "DAYS")
  # :: $3 -- str -- child name (e.g. "YEARS" or "MONTHS" or "WEEKS" or "DAYS")
  #
  logging "INFO" "__upgrade" "start"
  local WOD PARRENT_NAME CHILD_NAME
  WOD=$(set_e && check_input "__upgrade_child" "WOD" ${1})
  PARRENT_NAME=$(set_e && check_input "__upgrade_child" "PARRENT_NAME" ${2})
  CHILD_NAME=$(set_e && check_input "__upgrade_child" "CHILD_NAME" ${3})
  local COMPONENT_DIRECTORY_PARENT="${WOD}/${PARRENT_NAME}"
  local COMPONENT_DIRECTORY_CHILD="${WOD}/${CHILD_NAME}"

  if [ "${CHILD_NAME}" == "MONTHS" ]; then
    logging "INFO" "__upgrade_child" "Upgrade child MONTHS"
    __upgrade "${WOD}" "${COMPONENT_DIRECTORY_PARENT}" "${COMPONENT_DIRECTORY_CHILD}"
  elif [ "${CHILD_NAME}" == "WEEKS" ];then
    logging "INFO" "__upgrade_child" "Upgrade child WEEKS"
    __upgrade "${WOD}" "${COMPONENT_DIRECTORY_PARENT}" "${COMPONENT_DIRECTORY_CHILD}"
  elif [ "${CHILD_NAME}" == "DAYS" ];then
    logging "INFO" "__upgrade_child" "Upgrade child DAYS"
    __upgrade "${WOD}" "${COMPONENT_DIRECTORY_PARENT}" "${COMPONENT_DIRECTORY_CHILD}"
  elif [ "${CHILD_NAME}" == "NONE" ];then
    logging "INFO" "__upgrade_child" "Pass child NONE"
  else
    logging "CRITICAL" "__upgrade_child" "no such child with name ${CHILD_NAME}"
    system_exit 1
  fi
  logging "INFO" "__upgrade_child" "finish"
}

function __upgrade() {
  #
  # :: $1 -- str -- working directory
  # :: $2 -- str -- component directory parent
  # :: $3 -- str -- component directory child
  #
  logging "INFO" "__upgrade" "start"
  local WOD COMPONENT_DIRECTORY_PARENT COMPONENT_DIRECTORY_CHILD
  WOD=$(set_e && check_input "__upgrade" "WOD" "${1}")
  COMPONENT_DIRECTORY_PARENT=$(set_e && check_input "__upgrade" "COMPONENT_DIRECTORY_PARENT" "${2}")
  COMPONENT_DIRECTORY_CHILD=$(set_e && check_input "__upgrade" "COMPONENT_DIRECTORY_CHILD" "${3}")
  __remove_universal "${COMPONENT_DIRECTORY_CHILD}"
  __ds_controller "${WOD}"
  move_parent_a0_to_child_a0_cell "${COMPONENT_DIRECTORY_PARENT}" "${COMPONENT_DIRECTORY_CHILD}"
  move_parent_a0_hatch_to_child_a0_hatch_cell "${COMPONENT_DIRECTORY_PARENT}" "${COMPONENT_DIRECTORY_CHILD}"
  logging "INFO" "__upgrade" "finish"
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi