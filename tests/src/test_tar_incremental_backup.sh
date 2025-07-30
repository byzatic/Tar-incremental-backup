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
. ${MODEULES}/lib/basic/_basic.sh --source-only
#
. ${MODEULES}/backup_tar_controller.sh --source-only
. ${MODEULES}/a_cell.sh --source-only


function check_if_broken() {
  local TEST_EXPLANATION=${1}
  if [ "${TEST_EXPLANATION}" != "0" ]; then
    echo "tests not passed"
    exit 1
  else
    if [ "${2}" == "exit" ]; then
      echo "tests passed"
      exit 0
    fi
  fi
}

function __prepare_test_workflow() {
  local DIRECTORY_STRUCTURE BACKUP_SOURCE ELEMENT_DIRECTORY FILE_NAMES_STRUCTURE_META FILE_NAMES_STRUCTURE_SNAR ELEMENT_FILE_NAME TEST_WORKSPACE
  local TS_TODAY BACKUP_SOURCE TEST_WORKSPACE DIR_PARENT_NAME DIR_CHILD_NAME
  TS_TODAY=$(set_e && check_input "__prepare_test_workflow" "UNIX_TIMESTAMP" ${1})
  BACKUP_SOURCE=$(set_e && check_input "__prepare_test_workflow" "BACKUP_SOURCE" ${2})
  TEST_WORKSPACE=$(set_e && check_input "__prepare_test_workflow" "TEST_WORKSPACE" ${3})
  DIR_PARENT_NAME=$(set_e && check_input "__prepare_test_workflow" "DIR_PARENT_NAME" ${4})
  DIR_CHILD_NAME=$(set_e && check_input "__prepare_test_workflow" "DIR_CHILD_NAME" ${5})


  local BACKUP_SOURCE TEST_WORKSPACE DIR_PARENT_NAME DIR_CHILD_NAME

  logging "DEBUG" "__prepare_test_workflow" "srtart"
  DIRECTORY_STRUCTURE=( "${BACKUP_SOURCE}"  "${TEST_WORKSPACE}" "${TEST_WORKSPACE}/${DIR_PARENT_NAME}" "${TEST_WORKSPACE}/${DIR_CHILD_NAME}" )

  for ELEMENT_DIRECTORY in "${DIRECTORY_STRUCTURE[@]}"
  do
    __remove_universal ${ELEMENT_DIRECTORY}
    __make_directory ${ELEMENT_DIRECTORY}
    logging "DEBUG" "__prepare_test_workflow" "recreated ${ELEMENT_DIRECTORY}"
  done

  FILE_NAMES_STRUCTURE_META=( "a0_hatch_cell.meta" "a0_cell.meta")
  for ELEMENT_FILE_NAME in "${FILE_NAMES_STRUCTURE_META[@]}"
  do
    FILE_PATH="${TEST_WORKSPACE}/${DIR_PARENT_NAME}/${ELEMENT_FILE_NAME}"
    __create_file "${FILE_PATH}"
    echo "${TS_TODAY}" > "${FILE_PATH}"
  done

  FILE_NAMES_STRUCTURE_SNAR=( "a0_hatch_cell.snar" "a0_cell.snar")
  for ELEMENT_FILE_NAME in "${FILE_NAMES_STRUCTURE_SNAR[@]}"
  do
    FILE_PATH="${TEST_WORKSPACE}/${DIR_PARENT_NAME}/${ELEMENT_FILE_NAME}"
    __create_file "${FILE_PATH}"
  done

  START_META_A0=$(set_e && get_meta_a0 "${TEST_WORKSPACE}/${DIR_PARENT_NAME}")
  START_META_A0_HATCH=$(set_e && get_meta_a0_hatch "${TEST_WORKSPACE}/${DIR_PARENT_NAME}")
  logging "DEBUG" "__prepare_test_workflow" "PARENT a0 cell meta: ${START_META_A0}"
  logging "DEBUG" "__prepare_test_workflow" "PARENT a0 hatch cell meta: ${START_META_A0_HATCH}"

  logging "DEBUG" "__prepare_test_workflow" "finish"
}

function get_meta_a0() {
  local WORKDIR=${1} META
  META=$(set_e && cat ${WORKDIR}/a0_cell.meta )
  freturn ${META}
}

function get_meta_a1() {
  local WORKDIR=${1} META
  META=$(set_e && cat ${WORKDIR}/a1_cell.meta )
  freturn ${META}
}

function get_meta_a0_hatch() {
  local WORKDIR=${1} META
  META=$(set_e && cat ${WORKDIR}/a0_hatch_cell.meta )
  freturn ${META}
}

function test_generate_archive_name() {
  local EXIT_CODE
  local TS_TODAY BACKUP_SOURCE TEST_WORKSPACE DIR_PARENT_NAME DIR_CHILD_NAME UNIX_TIMESTAMP
  TS_TODAY=$(set_e && check_input "test_generate_archive_name" "TS_TODAY" ${1})
  BACKUP_SOURCE=$(set_e && check_input "test_generate_archive_name" "BACKUP_SOURCE" ${2})
  TEST_WORKSPACE=$(set_e && check_input "test_generate_archive_name" "TEST_WORKSPACE" ${3})
  DIR_PARENT_NAME=$(set_e && check_input "test_generate_archive_name" "DIR_PARENT_NAME" ${4})
  DIR_CHILD_NAME=$(set_e && check_input "test_generate_archive_name" "DIR_CHILD_NAME" ${5})
  UNIX_TIMESTAMP="1686137112"
  TS_TODAY=${UNIX_TIMESTAMP}
  logging "DEBUG" "test_generate_archive_name" "TS_TODAY=UNIX_TIMESTAMP= ${UNIX_TIMESTAMP}"
  __prepare_test_workflow ${UNIX_TIMESTAMP} ${BACKUP_SOURCE} ${TEST_WORKSPACE} ${DIR_PARENT_NAME} ${DIR_CHILD_NAME}
  echo "${UNIX_TIMESTAMP}" > "${TEST_WORKSPACE}/${DIR_PARENT_NAME}/a1_cell.meta"
  logging "DEBUG" "test_generate_archive_name" "a1_cell.meta data is $(set_e && get_meta_a1 ${TEST_WORKSPACE}/${DIR_PARENT_NAME})"

  GENERATED_NAME=$(set_e && generate_archive_name ${UNIX_TIMESTAMP} "${TEST_WORKSPACE}/${DIR_PARENT_NAME}")
  logging "DEBUG" "test_generate_archive_name" "GENERATED_NAME= ${GENERATED_NAME}"

  FACT_NAME="archive_2023.6.1.3_1686137112_1686137112_2023-06-07T11:25:12Z"
  logging "DEBUG" "test_generate_archive_name" "FACT_NAME= ${FACT_NAME}"
  if [ "${GENERATED_NAME}" == "${FACT_NAME}" ]; then
    logging "DEBUG" "test_generate_archive_name" "result: OK"
  else
    logging "DEBUG" "test_generate_archive_name" "result: ERROR"
    EXIT_CODE=1
  fi
  return ${EXIT_CODE}
}

function test_get_YYMMWWDD() {
  local UNIX_TIMESTAMP="1686137112" EXIT_CODE
  get_YYMMWWDD ${UNIX_TIMESTAMP}
  TEST_GET_YYMMWWDD_RESPONCE=$(set_e && get_YYMMWWDD ${UNIX_TIMESTAMP} )
  logging "DEBUG" "test_get_YYMMWWDD" "TEST_GET_YYMMWWDD_RESPONCE ${TEST_GET_YYMMWWDD_RESPONCE}"
  MUST_GET_YYMMWWDD_RESPONCE="2023.6.1.3"
  logging "DEBUG" "test_get_YYMMWWDD" "MUST_GET_YYMMWWDD_RESPONCE ${MUST_GET_YYMMWWDD_RESPONCE}"
  if [ "${TEST_GET_YYMMWWDD_RESPONCE}" == "${MUST_GET_YYMMWWDD_RESPONCE}" ]; then
    logging "DEBUG" "test_get_YYMMWWDD" "result: OK"
  else
    logging "DEBUG" "test_get_YYMMWWDD" "result: ERROR"
    EXIT_CODE=1
  fi
  return ${EXIT_CODE}
}

function test_incremental_backup_controller() {
  local EXIT_CODE
  local TS_TODAY BACKUP_SOURCE TEST_WORKSPACE DIR_PARENT_NAME DIR_CHILD_NAME UNIX_TIMESTAMP
  local RESULT1 RESULT2
  TS_TODAY=$(set_e && check_input "test_generate_archive_name" "TS_TODAY" ${1})
  BACKUP_SOURCE=$(set_e && check_input "test_generate_archive_name" "BACKUP_SOURCE" ${2})
  TEST_WORKSPACE=$(set_e && check_input "test_generate_archive_name" "TEST_WORKSPACE" ${3})
  DIR_PARENT_NAME=$(set_e && check_input "test_generate_archive_name" "DIR_PARENT_NAME" ${4})
  DIR_CHILD_NAME=$(set_e && check_input "test_generate_archive_name" "DIR_CHILD_NAME" ${5})
  UNIX_TIMESTAMP=${TS_TODAY}
  logging "DEBUG" "test_generate_archive_name" "TS_TODAY=UNIX_TIMESTAMP= ${UNIX_TIMESTAMP}"
  __prepare_test_workflow ${UNIX_TIMESTAMP} ${BACKUP_SOURCE} ${TEST_WORKSPACE} ${DIR_PARENT_NAME} ${DIR_CHILD_NAME}
  __remove_universal "${TEST_WORKSPACE}/${DIR_PARENT_NAME}/*"
  __remove_universal "${TEST_WORKSPACE}/${DIR_CHILD_NAME}/*"
  head -c 1M </dev/urandom >${BACKUP_SOURCE}/file1
  head -c 1M </dev/urandom >${BACKUP_SOURCE}/file2
  head -c 1M </dev/urandom >${BACKUP_SOURCE}/file3
  head -c 1M </dev/urandom >${BACKUP_SOURCE}/file4
  #
  #
  #
  incremental_backup_controller "${TEST_WORKSPACE}/${DIR_PARENT_NAME}" "${BACKUP_SOURCE}" "${TS_TODAY}"
  #
  #
  #
  RESULT1=0
  RESULT2=1
  if [ "${RESULT1}" == "${RESULT2}" ]; then
    logging "DEBUG" "test_get_YYMMWWDD" "result: OK"
  else
    logging "DEBUG" "test_get_YYMMWWDD" "result: ERROR"
    EXIT_CODE=1
  fi
  return ${EXIT_CODE}
}



function test_run() {
  local TS_TODAY BASEDIR TESTS_DIR TEST_BACKUP_SOURCE TEST_WORK_DIR TEST_BUNDLE_EXIT_CODE
  BASEDIR=$(dirname $(realpath "$0"))
  logging "DEBUG" "main" "BASEDIR= ${BASEDIR}"
  TESTS_DIR="${BASEDIR}/TESTS"
  logging "DEBUG" "main" "TESTS_DIR= ${TESTS_DIR}"
  TEST_BACKUP_SOURCE="${TESTS_DIR}/BACKUP_DIR"
  logging "DEBUG" "main" "TEST_BACKUP_SOURCE= ${TEST_BACKUP_SOURCE}"
  TEST_WORK_DIR="${TESTS_DIR}/DIST"
  logging "DEBUG" "main" "TEST_WORK_DIR= ${TEST_WORK_DIR}"
  TS_TODAY=$(set_e && date +%-s)

  logging "DEBUG" "test_get_YYMMWWDD" "----------------------------------------"
  test_get_YYMMWWDD
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}

  logging "DEBUG" "test_generate_archive_name" "----------------------------------------"
  test_generate_archive_name ${TS_TODAY} ${TEST_BACKUP_SOURCE} ${TEST_WORK_DIR} "YEARS" "MONTHS"
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}

  logging "DEBUG" "test_incremental_backup_controller" "----------------------------------------"
  test_incremental_backup_controller ${TS_TODAY} ${TEST_BACKUP_SOURCE} ${TEST_WORK_DIR} "YEARS" "MONTHS"
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}

  check_if_broken ${TEST_BUNDLE_EXIT_CODE} "exit"
}

function main() {
  test_run
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
