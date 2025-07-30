#!/bin/bash -e
#
#  MIT License
#
#  Copyright (c) 2023 s.vlasov.home@icloud.com
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
# shellcheck disable=SC2046
MODEULES="$(dirname $(realpath "$0"))/src"
# lib
. ${MODEULES}/lib/root/_root.sh --source-only

function __check_comporator() {
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_CHECKING ARG_VERIFIABLE
  ARG_VERIFIABLE=$(set_e && check_input "__check_comporator" "ARG_VERIFIABLE" "${1}")
  ARG_CHECKING=$(set_e && check_input "__check_comporator" "ARG_CHECKING" "${2}")
  if [ "${ARG_CHECKING}" == "${ARG_VERIFIABLE}" ]; then
    logging "DEBUG" "__check_comporator" "comporator exit 0"
    return 0
  else
    logging "DEBUG" "__check_comporator" "comporator exit 1"
    return 1
  fi
}

#You cannot trust date +%V because it gives the (apparently useless) ISO week of year.
#This means you get odd-ball results, like Jan.1 being the 52nd week of the year.
# original WEEKNUMBER=$(expr 1 + $(date +%V) - $(date +%V -d $(date +%Y-%m-01)))
function __check_week_of_month_old(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local EXIT_CODE ARG_VERIFIABLE ARG_CHECKING
  local TEMP0_ARG_VERIFIABLE TEMP0_ARG_CHECKING TEMP1_ARG_VERIFIABLE TEMP1_ARG_CHECKING TEMP2_ARG_VERIFIABLE TEMP2_ARG_CHECKING
  logging "INFO" "__check_week_of_month_old" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month_old" "ARG_VERIFIABLE" ${1})
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month_old" "ARG_CHECKING" ${2})
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
  logging "DEBUG" "__check_week_of_month_old" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_month_old" "finish"
  return ${EXIT_CODE}
}

#You cannot trust date +%V because it gives the (apparently useless) ISO week of year.
#This means you get odd-ball results, like Jan.1 being the 52nd week of the year.
# original WEEKNUMBER=$(( 1 + $(date +%V) - $(date -d "$(date -d "-$(($(date +%d)-1)) days")" +%V) ))
function __check_week_of_month_new(){
  #
  # :: $1 -- int -- verifiable TS e.g. date +%s
  # :: $2 -- int -- checking TS e.g. date +%s
  #
  local ARG_VERIFIABLE ARG_CHECKING EXIT_CODE
  local VERIFIABLE_WEEKNUMBER CHECKING_WEEKNUMBER
  local TEMP0 TEMP1 TEMP2 TEMP3 TEMP4 TEMP5
  logging "INFO" "__check_week_of_month_new" "start"
  ARG_VERIFIABLE=$(set_e && check_input "__check_week_of_month_new" "ARG_VERIFIABLE" "${1}")
  ARG_CHECKING=$(set_e && check_input "__check_week_of_month_new" "ARG_CHECKING" "${2}")

  TEMP0=$(date +%V -d "@${ARG_VERIFIABLE}")
  TEMP1=$(date +%d -d "@${ARG_VERIFIABLE}")
  TEMP2=$(date -d "-$((TEMP1-1)) days")
  VERIFIABLE_WEEKNUMBER=$(( 1 + TEMP0 - $(date -d "${TEMP2}" +%V) ))

  TEMP3=$(date +%V -d "@${ARG_CHECKING}")
  TEMP4=$(date +%d -d "@${ARG_CHECKING}")
  TEMP5=$(date -d "-$((TEMP4-1)) days")
  CHECKING_WEEKNUMBER=$(( 1 + TEMP3 - $(date -d "${TEMP5}" +%V) ))

  __check_comporator ${CHECKING_WEEKNUMBER} ${VERIFIABLE_WEEKNUMBER}
  EXIT_CODE=$?
  logging "DEBUG" "__check_week_of_month_new" "check_comporator return ${EXIT_CODE}"
  logging "INFO" "__check_week_of_month_new" "finish"
  return ${EXIT_CODE}
}

# 1609507657 1609766857

function main() {
  local EXIT_CODE1 EXIT_CODE2 VAL1 VAL2
  init_logger "std" "DEBUG" "$(dirname $(realpath "$0"))/backup_controller.log"
  #VAL1=1609507657
  #VAL2=1609766857
  VAL1=1609766857
  VAL2=1609853257
  __check_week_of_month_old "${VAL1}" "${VAL2}"
  EXIT_CODE2=$?
  __check_week_of_month_new "${VAL1}" "${VAL2}"
  EXIT_CODE1=$?
  logging "INFO" "developer" "----------------------------------------------"
  logging "INFO" "developer" "__check_week_of_month_new return ${EXIT_CODE1}"
  logging "INFO" "developer" "__check_week_of_month_old return ${EXIT_CODE2}"
  logging "INFO" "developer" "----------------------------------------------"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi