#!/bin/bash -e
#
#
#

function __check_comporator() {
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_CHECKING ARG_VERIFIABLE
  ARG_VERIFIABLE=$(set_e && check_input "__check_year" "ARG_VERIFIABLE" "${1}")
  ARG_CHECKING=$(set_e && check_input "__check_year" "ARG_CHECKING" "${2}")
  if [ "${ARG_CHECKING}" == "${ARG_VERIFIABLE}" ]; then
    return 0
  else
    return 1
  fi
}

function __check_year() {
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  logging "INFO" "__check_year" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_year" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_year" "ARG_CHECKING" ${2})
  #
  ARG_VERIFIABLE=$(set_e && date +%-Y -d "@${ARG_VERIFIABLE}")
  ARG_CHECKING=$(set_e && date +%-Y -d "@${ARG_CHECKING}")
  __check_comporator "${ARG_CHECKING}" ${ARG_VERIFIABLE}
  EXIT_CODE=$?
  logging "DEBUG" "__check_year" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_year" "finish"
  return ${EXIT_CODE}
}

function __check_day_of_year(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  logging "INFO" "__check_day_of_year" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_day_of_year" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_day_of_year" "ARG_CHECKING" ${2})
  #
  ARG_VERIFIABLE=$(set_e && date +%-j -d "@${ARG_VERIFIABLE}")
  ARG_CHECKING=$(set_e && date +%-j -d "@${ARG_CHECKING}")
  __check_comporator ${ARG_CHECKING} ${ARG_VERIFIABLE}
  EXIT_CODE=$?
  logging "DEBUG" "__check_day_of_year" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_day_of_year" "finish"
  return ${EXIT_CODE}
}

function __check_month_of_year(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  logging "INFO" "__check_month_of_year" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_month_of_year" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_month_of_year" "ARG_CHECKING" ${2})
  #
  ARG_VERIFIABLE=$(set_e && date +%-m -d "@${ARG_VERIFIABLE}")
  ARG_CHECKING=$(set_e && date +%-m -d "@${ARG_CHECKING}")
  __check_comporator ${ARG_CHECKING} ${ARG_VERIFIABLE}
  EXIT_CODE=$?
  logging "DEBUG" "__check_month_of_year" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_month_of_year" "finish"
  return ${EXIT_CODE}
}

function __check_week_of_year(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  logging "INFO" "__check_week_of_year" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_year" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_week_of_year" "ARG_CHECKING" ${2})
  #
  ARG_VERIFIABLE=$(set_e && date +%-U -d "@${ARG_VERIFIABLE}")
  ARG_CHECKING=$(set_e && date +%-U -d "@${ARG_CHECKING}")
  __check_comporator ${ARG_CHECKING} ${ARG_VERIFIABLE}
  EXIT_CODE=$?
  logging "DEBUG" "__check_week_of_year" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_year" "finish"
  return ${EXIT_CODE}
}

function __check_week_of_month(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_VERIFIABLE ARG_CHECKING EXIT_CODE
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month" "ARG_CHECKING" ${2})
  __check_week_of_month_1 "${ARG_VERIFIABLE}" "${ARG_CHECKING}"
  #__check_week_of_month_2 "${ARG_VERIFIABLE}" "${ARG_CHECKING}"
  #__check_week_of_month_3 "${ARG_VERIFIABLE}" "${ARG_CHECKING}"
  EXIT_CODE=$?
  return ${EXIT_CODE}
}

# original WEEKNUMBER=$(expr 1 + $(date +%V) - $(date +%V -d $(date +%Y-%m-01)))
function __check_week_of_month_1(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  local TEMP0_ARG_VERIFIABLE TEMP0_ARG_CHECKING TEMP1_ARG_VERIFIABLE TEMP1_ARG_CHECKING TEMP2_ARG_VERIFIABLE TEMP2_ARG_CHECKING
  logging "INFO" "__check_week_of_month" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month" "ARG_CHECKING" ${2})
  #
  TEMP0_ARG_VERIFIABLE=$(date +%V -d "@${ARG_VERIFIABLE}")
  TEMP0_ARG_CHECKING=$(date +%V -d "@${ARG_CHECKING}")
  TEMP1_ARG_VERIFIABLE=$(date +%Y-%m-01 -d "@${ARG_VERIFIABLE}")
  TEMP1_ARG_CHECKING=$(date +%Y-%m-01 -d "@${ARG_CHECKING}")
  TEMP2_ARG_VERIFIABLE=$(date +%V -d ${TEMP1_ARG_VERIFIABLE})
  TEMP2_ARG_CHECKING=$(date +%V -d ${TEMP1_ARG_CHECKING})
  ARG_VERIFIABLE=$(( 1 + TEMP0_ARG_VERIFIABLE - TEMP2_ARG_VERIFIABLE ))
  ARG_CHECKING=$(( 1 + TEMP0_ARG_CHECKING - TEMP2_ARG_CHECKING ))
  __check_comporator ${ARG_CHECKING} ${ARG_VERIFIABLE}
  EXIT_CODE=$?
  logging "DEBUG" "__check_week_of_month" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_month" "finish"
  return ${EXIT_CODE}
}

# original WEEKNUMBER=$(( 1 + $(date +%V) - $(date -d "$(date -d "-$(($(date +%d)-1)) days")" +%V) ))
function __check_week_of_month_2(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_VERIFIABLE ARG_CHECKING EXIT_CODE
  local VERIFIABLE_WEEKNUMBER CHECKING_WEEKNUMBER
  local TEMP0 TEMP1 TEMP2 TEMP3 TEMP4 TEMP5
  logging "INFO" "__check_week_of_month" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month" "ARG_VERIFIABLE" "${1}")
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month" "ARG_CHECKING" "${2}")

  TEMP0=$(date +%V -d "@${ARG_VERIFIABLE}")
  TEMP1=$(date +%d -d "${ARG_VERIFIABLE}")
  TEMP2=$(date -d "-$((TEMP1-1)) days")
  VERIFIABLE_WEEKNUMBER=$(( 1 + TEMP0 - $(date -d "${TEMP2}" +%V) ))

  TEMP3=$(date +%V -d "@${ARG_CHECKING}")
  TEMP4=$(date +%d -d "@${ARG_CHECKING}")
  TEMP5=$(date -d "-$((TEMP4-1)) days")
  CHECKING_WEEKNUMBER=$(( 1 + TEMP3 - $(date -d "${TEMP5}" +%V) ))

  __check_comporator ${CHECKING_WEEKNUMBER} ${VERIFIABLE_WEEKNUMBER}
  EXIT_CODE=$?
  logging "DEBUG" "__check_week_of_month" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_month" "finish"
  return ${EXIT_CODE}
}

# original _DOM=`date +%d` _WOM=$(((${_DOM}-1)/7+1))
function __check_week_of_month_3(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_VERIFIABLE ARG_CHECKING EXIT_CODE
  local VERIFIABLE_WEEKNUMBER CHECKING_WEEKNUMBER
  local TEMP0 TEMP1
  logging "INFO" "__check_week_of_month" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month" "ARG_VERIFIABLE" "${1}")
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month" "ARG_CHECKING" "${2}")

  TEMP0=$(date +%d -d "@${ARG_VERIFIABLE}")
  VERIFIABLE_WEEKNUMBER=$(((TEMP0-1)/7+1))

  TEMP1=$(date +%d -d "@${ARG_CHECKING}")
  CHECKING_WEEKNUMBER=$(((TEMP1-1)/7+1))

  __check_comporator ${CHECKING_WEEKNUMBER} ${VERIFIABLE_WEEKNUMBER}
  EXIT_CODE=$?
  logging "DEBUG" "__check_week_of_month" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_month" "finish"
  return ${EXIT_CODE}
}

function __check_day_of_week(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  logging "INFO" "__check_day_of_week" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_day_of_week" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_day_of_week" "ARG_CHECKING" ${2})
  #
  ARG_VERIFIABLE=$(set_e && date +%-u -d "@${ARG_VERIFIABLE}")
  ARG_CHECKING=$(set_e && date +%-u -d "@${ARG_CHECKING}")
  __check_comporator "${ARG_CHECKING}" "${ARG_VERIFIABLE}"
  EXIT_CODE=$?
  logging "DEBUG" "__check_day_of_week" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_day_of_week" "finish"
  return ${EXIT_CODE}
}

function check_if_an_current_period() {
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  # :: $3 -- str -- what to check e.g. Y \ DoY \ MoY \ WoM \ DoW
  #
  logging "INFO" "check_if_an_current_period" "start"
  local ARG_VERIFIABLE_TS ARG_CHECKING_TS TYPE_OF_COMPARED_VALUES EXIT_CODE
  ARG_VERIFIABLE_TS=$(set_e && check_input "check_if_an_current_period" "ARG_VERIFIABLE_TS" ${1})
  ARG_CHECKING_TS=$(set_e && check_input "check_if_an_current_period" "ARG_CHECKING_TS" ${2})
  TYPE_OF_COMPARED_VALUES=$(set_e && check_input "check_if_an_current_period" "TYPE_OF_COMPARED_VALUES" ${3})

  case ${TYPE_OF_COMPARED_VALUES} in
    "Y")
      __check_year ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    "DoY")
      __check_day_of_year ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    "MoY")
      __check_month_of_year ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    "WoM")
      __check_week_of_month ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    "DoW")
      __check_day_of_week ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    "WoY")
      __check_week_of_year ${ARG_VERIFIABLE_TS} ${ARG_CHECKING_TS}
      EXIT_CODE=$?
      return ${EXIT_CODE}
      ;;
    *)
      logging "CRITICAL" "check_if_an_current_period" "no such type of compared values TYPE_OF_COMPARED_VALUES= ${TYPE_OF_COMPARED_VALUES}"
      system_exit 1
      ;;
  esac
  logging "INFO" "check_if_an_current_period" "finish"
}

function check_if_a0_current_period() {
  #
  # :: $1 -- int -- component directory
  # :: $2 -- int -- current timestamp
  # :: $3 -- str -- what to check e.g. Y \ DoY \ MoY \ WoM \ DoW
  #
  logging "INFO" "check_if_a0_current_period" "start"
  local CELL_A0_TS COMPONENT_DIRECTORY ARG_CHECKING_TS EXIT_CODE
  COMPONENT_DIRECTORY=$(set_e && check_input "check_if_a0_current_period" "COMPONENT_DIRECTORY" "${1}")
  ARG_VERIFIABLE_TS=$(set_e && check_input "check_if_a0_current_period" "ARG_VERIFIABLE_TS" "${2}")
  TYPE_OF_COMPARED_VALUES=$(set_e && check_input "check_if_a0_current_period" "TYPE_OF_COMPARED_VALUES" "${3}")
  if ( boolean_check_if_a0_exists "${COMPONENT_DIRECTORY}" ); then
    CELL_A0_TS=$(set_e && a0_cell "${COMPONENT_DIRECTORY}" "read_meta")
    check_if_an_current_period "${CELL_A0_TS}" "${ARG_VERIFIABLE_TS}" "${TYPE_OF_COMPARED_VALUES}"
    EXIT_CODE=$?
    logging "DEBUG" "check_if_a0_current_periodcheck_if_a0_current_period" "check_if_an_current_period return ${EXIT_CODE}"
    return ${EXIT_CODE}
  else
    logging "WARNING" "check_if_a0_current_period" "a0 not found; system_exit 1"
    system_exit 1
  fi
  logging "INFO" "check_if_a0_current_period" "finish"
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi