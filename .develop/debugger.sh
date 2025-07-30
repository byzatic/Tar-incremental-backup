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

function test_program() {
  local __LOG_LEVEL__ __LOG_FILE__ __LOG_MODE__
  local BACKUP_CONTROLLER_EXITCODE
  local BACKUP_OUTPUT BACKUP_SOURCE INIT_FLAG_STATE FORCE_FLAG_STATE REMAININGDAY BASEDIR
  BACKUP_OUTPUT=$(set_e && check_input "test_program" "BACKUP_OUTPUT" "${1}")
  BACKUP_SOURCE=$(set_e && check_input "test_program" "BACKUP_SOURCE" "${2}")
  INIT_FLAG_STATE=$(set_e && check_input "test_program" "INIT_FLAG_STATE" "${3}")
  FORCE_FLAG_STATE=$(set_e && check_input "test_program" "FORCE_FLAG_STATE" "${4}")
  REMAININGDAY=$(set_e && check_input "test_program" "REMAININGDAY" "${5}")
  BASEDIR=$(set_e && check_input "test_program" "BASEDIR" "${6}")
  #
  ${BASEDIR}/backup_controller.sh \
    --working-directory "${BACKUP_OUTPUT}"  \
    --source-directory "${BACKUP_SOURCE}" \
    --global-force-flag "${FORCE_FLAG_STATE}" \
    --backup-plan "yearly" \
    --current-timestamp "${REMAININGDAY}"
  BACKUP_CONTROLLER_EXITCODE=$?
  if [ "${BACKUP_CONTROLLER_EXITCODE}" != "0" ]; then
    echo -e "$( date +%Y.%m.%d-%H:%M:%S) [ERROR] (test): something goes wrong in ${BASEDIR}/backup_controller.sh; exit code ${BACKUP_CONTROLLER_EXITCODE}"
    echo -e "$( date +%Y.%m.%d-%H:%M:%S) [ERROR] (test): call was ${BASEDIR}/backup_controller.sh ${BACKUP_OUTPUT} ${BACKUP_SOURCE} ${INIT_FLAG_STATE} ${FORCE_FLAG_STATE} ${SCRIPT_MODE} ${REMAININGDAY}"
    exit 1
  else
    echo -e "$( date +%Y.%m.%d-%H:%M:%S) [DEBUG] (test): backup_controller.sh finished with exit code ${BACKUP_CONTROLLER_EXITCODE}"
  fi
}

function ceate_test_files() {
  local BACKUP_SOURCE DATE_INT FTS
  BACKUP_SOURCE=$(set_e && check_input "__processing_controller" "BACKUP_SOURCE" "${1}")
  DATE_INT=$(set_e && check_input "__processing_controller" "DATE_INT" "${2}")
  FTS=$(set_e && get_fts ${DATE_INT})
  ADD_FILE="${BACKUP_SOURCE}/new_file_${FTS}.test"
  head -c 1M </dev/urandom >${ADD_FILE}
}

function day_add_6sec() {
  local REMAININGDAY
  REMAININGDAY=$(set_e && check_input "day_add_6sec" "REMAININGDAY" "${1}")
  REMAININGDAY=$(( ${REMAININGDAY} + 6 ))
  freturn ${REMAININGDAY}
}

function get_fts() {
  local DATE_INT FTS
  DATE_INT=$(set_e && check_input "get_fts" "DATE_INT" "${1}")
  FTS=$(date +%Y.%m.%d-%H:%M:%S -d "@${DATE_INT}")
  freturn "${FTS}"
}

function recreate_test_workflow() {
  local WORK_DIR
  WORK_DIR=$(set_e && check_input "create_test_workflow" "DATE_INT" "${1}")
  rm -rf ${WORK_DIR}
  logging "DEBUG" "test" "removed ${WORK_DIR}"
  mkdir -p ${WORK_DIR}
  logging "DEBUG" "test" "created ${WORK_DIR}"
}

function clean_test_workflow() {
  local WORK_DIR
  WORK_DIR=$(set_e && check_input "create_test_workflow" "DATE_INT" "${1}")
  rm -rf ${WORK_DIR}/*
  logging "DEBUG" "test" "removed ${WORK_DIR}"
  mkdir -p ${WORK_DIR}
  logging "DEBUG" "test" "created ${WORK_DIR}"
}

function create_workflow() {
  BASEDIR=$(set_e && check_input "create_workflow" "BASEDIR" "${1}")
  APPLICATION_MODE=$(set_e && check_input "create_workflow" "APPLICATION_MODE" "${2}")
  BACKUP_SOURCE=$(set_e && check_input "create_workflow" "BACKUP_SOURCE" "${3}")
  BACKUP_OUTPUT=$(set_e && check_input "create_workflow" "BACKUP_OUTPUT" "${4}")
  if [ "${APPLICATION_MODE}" != "docker" ]; then
    recreate_test_workflow ${BACKUP_SOURCE}
    recreate_test_workflow ${BACKUP_OUTPUT}
  else
    clean_test_workflow "${BACKUP_SOURCE}"
    clean_test_workflow "${BACKUP_OUTPUT}"
  fi
}

function main() {
  local COMMANDLY APPLICATION_MODE SIDE_DATA
  local WORKFLOW_DIR BACKUP_SOURCE BACKUP_OUTPUT
  local TS_ONE_DAY
  local DAYS_TO_PROCESS START_DATE STOP_DATE PROCESSING_DATE
  local FORCE_FLAG_STATE INIT_FLAG_STATE
  local REPEATS
  init_logger "std" "DEBUG" "$(dirname $(realpath "$0"))/backup_controller.log"
  logging "DEBUG" "debugger" "start scriptlet"
  # COMMANDLY - set_days / init_only / repeats
  COMMANDLY=$(set_e && check_input "debugger" "COMMANDLY" "${1}" "force")
  # - 12 (for set_days) / 10 (for repeats)
  SIDE_DATA=$(set_e && check_input "debugger" "DAYS_TO_PROCESS" "${2}" "25")
  # APPLICATION_MODE - docker / regular
  APPLICATION_MODE=$(set_e && check_input "debugger" "MODE" "${__APPLICATION_MODE__}" "regular")

  # shellcheck disable=SC2046
  BASEDIR=$(dirname $(realpath "$0"))
  if [ "${APPLICATION_MODE}" != "docker" ]; then
    WORKFLOW_DIR="${BASEDIR}/TESTs"
    BACKUP_SOURCE="${WORKFLOW_DIR}/BACKUP_SOURCE"
    BACKUP_OUTPUT="${WORKFLOW_DIR}/BACKUP_OUTPUT"
    logging "DEBUG" "debugger" "BASEDIR=${BASEDIR}"
    logging "DEBUG" "debugger" "WORKFLOW_DIR=${WORKFLOW_DIR}"
    logging "DEBUG" "debugger" "BACKUP_SOURCE=${BACKUP_SOURCE}"
    logging "DEBUG" "debugger" "BACKUP_OUTPUT=${BACKUP_OUTPUT}"
  else
    BACKUP_SOURCE="/backup_source"
    BACKUP_OUTPUT="/backup_output"
    logging "DEBUG" "debugger" "BACKUP_SOURCE=${BACKUP_SOURCE}"
    logging "DEBUG" "debugger" "BACKUP_OUTPUT=${BACKUP_OUTPUT}"
  fi

  create_workflow "${BASEDIR}" "${APPLICATION_MODE}" "${BACKUP_SOURCE}" "${BACKUP_OUTPUT}"


  #START_DATE="1590845257" # original test start date
  START_DATE="1609507657"
  logging "DEBUG" "debugger" "start date: $(set_e && get_fts "${START_DATE}")"

  TS_ONE_DAY=86400
  if [ "${COMMANDLY}" == "set_days" ]; then
    logging "DEBUG" "debugger" "processing of ${SIDE_DATA} days"
    STOP_DATE=$(( START_DATE + $(( TS_ONE_DAY * SIDE_DATA )) ))
  else
    STOP_DATE=$(date +%-s)
  fi
  logging "DEBUG" "debugger" "stop date: $(set_e && get_fts "${STOP_DATE}")"

  FORCE_FLAG_STATE="0"
  INIT_FLAG_STATE="1"
  logging "DEBUG" "debugger" "force flag state disabled"
  logging "DEBUG" "debugger" "init flag state enabled"

  PROCESSING_DATE=${START_DATE}
  while [ ${PROCESSING_DATE} -le ${STOP_DATE} ]
  do
    logging "DEBUG" "debugger" "-----------------------------------------------------------"
    logging "DEBUG" "debugger" "current day -> PROCESSING_DATE=${PROCESSING_DATE}"
    ceate_test_files "${BACKUP_SOURCE}" "${PROCESSING_DATE}"
    logging "DEBUG" "debugger" "current day -> FORCE_FLAG_STATE=${FORCE_FLAG_STATE}"
    logging "DEBUG" "debugger" "current day -> INIT_FLAG_STATE=${INIT_FLAG_STATE}"
    logging "DEBUG" "debugger" "-----------------------------------------------------------"
    #
    test_program "${BACKUP_OUTPUT}" "${BACKUP_SOURCE}" "${INIT_FLAG_STATE}" "${FORCE_FLAG_STATE}" "${PROCESSING_DATE}" "${BASEDIR}"
    #
    FORCE_FLAG_STATE="0"
    INIT_FLAG_STATE="0"
    logging "DEBUG" "debugger" "force flag state disabled"
    logging "DEBUG" "debugger" "init flag state disabled"
    #
    #
    #

    if [ "${COMMANDLY}" == "ds" ]; then
      HCECK_TEMP=$(set_e && get_fts ${PROCESSING_DATE})
      if [ "${HCECK_TEMP}" == "2020.06.09-16:27:37" ]; then
        logging "DEBUG" "debugger" "stop on ${HCECK_TEMP}"
        system_exit 0
      fi
    fi

    if [ "${COMMANDLY}" == "init_only" ]; then
      logging "DEBUG" "debugger" "init_only flag enabled -> COMMANDLY=${COMMANDLY}"
      system_exit 0
    fi

    if [ "${COMMANDLY}" == "repeats" ]; then
      logging "DEBUG" "debugger" "starting repeats for ${SIDE_DATA} times"
      REPEATS=0
      DATE_INT="${PROCESSING_DATE}"
      logging "DEBUG" "debugger" "DATE_INT is ${DATE_INT}"
      while [ ${REPEATS} -le ${SIDE_DATA} ]
      do
        logging "DEBUG" "debugger" "=======[repeat day + 6]======="
        logging "DEBUG" "debugger" "REPEATS -> ${REPEATS}"
        REPEATS_WAS=${REPEATS}
        logging "DEBUG" "test" "day -> $(set_e && get_fts ${DATE_INT})"
        logging "DEBUG" "debugger" "=======[repeat day + 6]======="
        DATE_INT=$(set_e && day_add_6sec "${DATE_INT}")
        ceate_test_files "${BACKUP_SOURCE}" "${DATE_INT}"
        test_program "${BACKUP_OUTPUT}" "${BACKUP_SOURCE}" "${INIT_FLAG_STATE}" "${FORCE_FLAG_STATE}" "${DATE_INT}" "${BASEDIR}"
        logging "DEBUG" "repeat_day" "finish day $(set_e && get_fts ${DATE_INT})"
        REPEATS=$(( REPEATS + 1 ))
        logging "DEBUG" "debugger" "=======[repeat day + 6]======="
        logging "DEBUG" "debugger" "REPEATS was -> ${REPEATS_WAS}"
        logging "DEBUG" "debugger" "REPEATS now -> ${REPEATS}"
        logging "DEBUG" "debugger" "day -> $(set_e && get_fts ${DATE_INT})"
        logging "DEBUG" "debugger" "=======[repeat day + 6]======="
      done
      system_exit 0
    fi
    logging "DEBUG" "debugger" "PROCESSING_DATE was ${PROCESSING_DATE}"
    PROCESSING_DATE=$(( PROCESSING_DATE + TS_ONE_DAY ))
    logging "DEBUG" "debugger" "PROCESSING_DATE become ${PROCESSING_DATE}"
  done
  logging "INFO" "test" "finish test"
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi