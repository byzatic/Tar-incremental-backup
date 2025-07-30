#!/bin/bash -e
#
#
#

# function of processing year
function process_year() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- flag: force work directory state, cleanup and call initialisation
  #
  local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE FORCE_FLAG
  local COMPONENT_NAME="YEARS"
  local CHECK_BY="Y"
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${1})
  TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${3})
  FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${4})
  #
  business_logic \
    --working-directory "${WORKING_DIRECTORY}" \
    --ts-now "${TS_NOW}" \
    --backup-source "${BACKUP_SOURCE}" \
    --component-name "${COMPONENT_NAME}" \
    --check-by "${CHECK_BY}" \
    --force-flag "${FORCE_FLAG}"
}

function process_month() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- flag: force work directory state, cleanup and call initialisation
  #
  local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE FORCE_FLAG
  local COMPONENT_NAME="MONTHS"
  local CHECK_BY="MoY"
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${1})
  TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${3})
  FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${4})
  #
  business_logic \
    --working-directory "${WORKING_DIRECTORY}" \
    --ts-now "${TS_NOW}" \
    --backup-source "${BACKUP_SOURCE}" \
    --component-name "${COMPONENT_NAME}" \
    --check-by "${CHECK_BY}" \
    --force-flag "${FORCE_FLAG}"
}

function process_week() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- flag: force work directory state, cleanup and call initialisation
  #
  local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE FORCE_FLAG
  local COMPONENT_NAME="WEEKS"
  local CHECK_BY="WoY"
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${1})
  TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${3})
  FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${4})
  #
  business_logic \
    --working-directory "${WORKING_DIRECTORY}" \
    --ts-now "${TS_NOW}" \
    --backup-source "${BACKUP_SOURCE}" \
    --component-name "${COMPONENT_NAME}" \
    --check-by "${CHECK_BY}" \
    --force-flag "${FORCE_FLAG}"
}

function process_day() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- backup sources directory
  # :: $4 -- int -- flag: force work directory state, cleanup and call initialisation
  #
  local WORKING_DIRECTORY TS_NOW BACKUP_SOURCE FORCE_FLAG
  local COMPONENT_NAME="DAYS"
  local CHECK_BY="DoW"
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" ${1})
  TS_NOW=$(set_e && check_input "${FUNCNAME}" "TS_NOW" ${2})
  BACKUP_SOURCE=$(set_e && check_input "${FUNCNAME}" "BACKUP_SOURCE" ${3})
  FORCE_FLAG=$(set_e && check_input "${FUNCNAME}" "FORCE_FLAG" ${4})
  #
  business_logic \
    --working-directory "${WORKING_DIRECTORY}" \
    --ts-now "${TS_NOW}" \
    --backup-source "${BACKUP_SOURCE}" \
    --component-name "${COMPONENT_NAME}" \
    --check-by "${CHECK_BY}" \
    --force-flag "${FORCE_FLAG}"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi