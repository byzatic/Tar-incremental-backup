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
#
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

function test_prepare_data() {
  logging "DEBUG" "test_prepare_data" "srtart"

  rm -rf ${TEST_BACKUP_SOURCE}
  logging "DEBUG" "test_prepare_data" "removed ${TEST_BACKUP_SOURCE}"
  mkdir -p ${TEST_BACKUP_SOURCE}
  logging "DEBUG" "test_prepare_data" "created ${TEST_BACKUP_SOURCE}"
  rm -rf ${TEST_WORK_DIR}
  logging "DEBUG" "test_prepare_data" "removed ${TEST_WORK_DIR}"
  mkdir -p ${TEST_WORK_DIR}
  logging "DEBUG" "test_prepare_data" "created ${TEST_BACKUP_SOURCE}"
  rm -rf ${TEST_A_DIR}
  logging "DEBUG" "test_prepare_data" "removed ${TEST_A_DIR}"
  mkdir -p ${TEST_A_DIR_PARENT}
  logging "DEBUG" "test_prepare_data" "created ${TEST_A_DIR_PARENT}"
  mkdir -p ${TEST_A_DIR_CHILD}
  logging "DEBUG" "test_prepare_data" "created ${TEST_A_DIR_CHILD}"

  touch "${TEST_A_DIR_PARENT}/a0_hatch_cell.meta"
  touch "${TEST_A_DIR_PARENT}/a0_hatch_cell.snar"
  touch "${TEST_A_DIR_PARENT}/a0_cell.meta"
  touch "${TEST_A_DIR_PARENT}/a0_cell.snar"
  echo ${TS_TODAY} > "${TEST_A_DIR_PARENT}/a0_cell.meta"
  echo ${TS_TODAY} > "${TEST_A_DIR_PARENT}/a0_hatch_cell.meta"

  START_META_PARENT=$(set_e && cat ${TEST_A_DIR_PARENT}/a0_cell.meta )
  START_META_CHILD=$(set_e && cat ${TEST_A_DIR_PARENT}/a0_hatch_cell.meta )
  logging "DEBUG" "test_prepare_data" "PARENT a0_hatch_cell: ${START_META_PARENT}"
  logging "DEBUG" "test_prepare_data" "CHILD a0_hatch_cell: ${START_META_CHILD}"

  logging "DEBUG" "test_prepare_data" "finish"
}

function test_f() {
  test_prepare_data
  set +e
  logging "DEBUG" "test_f" "srtart"

  local COMPONENT_DIRECTORY_PARENT
  local COMPONENT_DIRECTORY_CHILD
  local WRITE_DATA="a03df0"
  #
  local A0_F_GSFP
  local A0_F_GTFP
  local A0_HATCH_F_GSFP
  local A0_HATCH_F_GTFP
  local A0_F_RT
  local A0_HATCH_F_RT
  local A0_HATCH_F_RS
  local A0_F_WT
  local A0_HATCH_F_WT
  local TEST_A0_RD
  local TEST_A0_HATCH_RD

  local EXIT_CODE=0

  COMPONENT_DIRECTORY_PARENT=${TEST_A_DIR_PARENT}
  COMPONENT_DIRECTORY_CHILD=${TEST_A_DIR_CHILD}
  #
  #
  #
  A0_F_GSFP=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "__get_snar_file_path")
  #
  A0_HATCH_F_GSFP=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "__get_snar_file_path")
  #
  A0_F_GTFP=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "__get_ts_file_path")
  #
  A0_HATCH_F_GTFP=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "__get_ts_file_path")
  #
  A0_F_RT=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "read_meta")
  #
  A0_HATCH_F_RT=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "read_meta")
  #
  A0_F_RS=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "read_snar_path")
  #
  A0_HATCH_F_RS=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "read_snar_path")
  #
  A0_F_WT=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "write_meta" ${WRITE_DATA})
  #
  A0_HATCH_F_WT=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "write_meta" ${WRITE_DATA})
  #
  #
  TEST_A0_RD=$(set_e &&  cat ${COMPONENT_DIRECTORY_PARENT}/a0_hatch_cell.meta )
  TEST_A0_HATCH_RD=$(set_e &&  cat ${COMPONENT_DIRECTORY_PARENT}/a0_hatch_cell.meta )
  #
  #
  #
  logging "DEBUG" "main" "---------------[__get_snar_file_path]---------------"
  logging "DEBUG" "test_f" "__get_snar_file_path: A0_F_GSFP= ${A0_F_GSFP}"
  logging "DEBUG" "test_f" "__get_snar_file_path: A0_HATCH_F_GSFP= ${A0_HATCH_F_GSFP}"
  logging "DEBUG" "main" "---------------[__get_ts_file_path]---------------"
  logging "DEBUG" "test_f" "__get_ts_file_path: A0_F_GTFP= ${A0_F_GTFP}"
  logging "DEBUG" "test_f" "__get_ts_file_path: A0_HATCH_F_GTFP= ${A0_HATCH_F_GTFP}"
  logging "DEBUG" "main" "---------------[read_ts]---------------"
  logging "DEBUG" "test_f" "read_ts: A0_F_RT= ${A0_F_RT}"
  logging "DEBUG" "test_f" "read_ts: A0_HATCH_F_RT= ${A0_HATCH_F_RT}"
  logging "DEBUG" "main" "---------------[read_snar]---------------"
  logging "DEBUG" "test_f" "read_snar: A0_F_RS= ${A0_F_RS}"
  logging "DEBUG" "test_f" "read_snar: A0_HATCH_F_RS= ${A0_HATCH_F_RS}"
  logging "DEBUG" "main" "---------------[write_ts]---------------"
  logging "DEBUG" "test_f" "write ${WRITE_DATA}"
  logging "DEBUG" "test_f" "write_ts: A0_F_WT= ${A0_F_WT}"
  logging "DEBUG" "test_f" "write_ts: A0_HATCH_F_WT= ${A0_HATCH_F_WT}"
  logging "DEBUG" "test_f" "write_ts: A0 data was = ${START_META_PARENT}"
  logging "DEBUG" "test_f" "write_ts: A0_HATCH data was = ${START_META_CHILD}"
  logging "DEBUG" "test_f" "write_ts: A0 data become= ${TEST_A0_RD}"
  logging "DEBUG" "test_f" "write_ts: A0_HATCH data become= ${TEST_A0_HATCH_RD}"

  set -e

  if [ "${A0_F_GSFP}" == "${TEST_A_DIR_PARENT}/a0_cell.snar" ] && [ "${A0_HATCH_F_GSFP}" == "${TEST_A_DIR_PARENT}/a0_hatch_cell.snar" ]; then
    echo "test for __get_snar_file_path: OK"
  else
    echo "test for __get_snar_file_path: ERROR"
    EXIT_CODE=1
  fi

  if [ "${A0_F_GTFP}" == "${TEST_A_DIR_PARENT}/a0_cell.meta" ] && [ "${A0_HATCH_F_GTFP}" == "${TEST_A_DIR_PARENT}/a0_hatch_cell.meta" ]; then
    echo "test for __get_ts_file_path: OK"
  else
    echo "test for __get_ts_file_path: ERROR"
    EXIT_CODE=1
  fi

  if [ "${A0_F_RT}" == "${TS_TODAY}" ] && [ "${A0_HATCH_F_RT}" == "${TS_TODAY}" ]; then
    echo "test for read_ts: OK"
  else
    echo "test for read_ts: ERROR"
    EXIT_CODE=1
  fi

  if [ "${A0_F_RS}" == "${TEST_A_DIR_PARENT}/a0_cell.snar" ] && [ "${A0_HATCH_F_RS}" == "${TEST_A_DIR_PARENT}/a0_hatch_cell.snar" ]; then
    echo "test for read_snar: OK"
  else
    echo "test for read_snar: ERROR"
    EXIT_CODE=1
  fi

  if [ "${TEST_A0_RD}" == "${WRITE_DATA}" ] && [ "${TEST_A0_HATCH_RD}" == "${WRITE_DATA}" ]; then
    echo "test for read_snar: OK"
  else
    echo "test for read_snar: ERROR"
    EXIT_CODE=1
  fi

  return ${EXIT_CODE}

  logging "DEBUG" "test_f" "finish"
}


function test__move_a0_to_a0_hatch_cell() {
  test_prepare_data
  set +e
  local TS_TODAY="sdfvdfsrfvs"
  local EXIT_CODE=0
  local COMPONENT_DIRECTORY_PARENT=${TEST_A_DIR_PARENT}
  echo ${TS_TODAY} > "${COMPONENT_DIRECTORY_PARENT}/a0_cell.meta"
  echo ${TS_TODAY} > "${COMPONENT_DIRECTORY_PARENT}/a0_cell.snar"
  move_a0_to_a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT}
  TEST_A0_HATCH_CELL=$(set_e &&  cat ${COMPONENT_DIRECTORY_PARENT}/a0_hatch_cell.meta )
  TEST_A0_CELL=$(set_e &&  cat ${COMPONENT_DIRECTORY_PARENT}/a0_hatch_cell.snar )
  set -e

  if [ "${TEST_A0_CELL}" == "${TS_TODAY}" ] && [ "${TEST_A0_HATCH_CELL}" == "${TS_TODAY}" ]; then
    echo "test for move_a0_to_a0_hatch_cell: OK"
  else
    echo "test for move_a0_to_a0_hatch_cell: ERROR"
    EXIT_CODE=1
  fi

  return ${EXIT_CODE}

}


function test__move_parent_a0_to_child_a0_cell() {
  test_prepare_data
  set +e
  local TS_TODAY="sdfvdfsrfvs"
  local EXIT_CODE=0
  local COMPONENT_DIRECTORY_PARENT=${TEST_A_DIR_PARENT}
  local COMPONENT_DIRECTORY_CHILD=${TEST_A_DIR_CHILD}
  echo ${TS_TODAY} > "${COMPONENT_DIRECTORY_PARENT}/a0_cell.meta"
  echo ${TS_TODAY} > "${COMPONENT_DIRECTORY_PARENT}/a0_cell.snar"
  move_parent_a0_to_child_a0_cell ${COMPONENT_DIRECTORY_PARENT} ${COMPONENT_DIRECTORY_CHILD}
  TEST_A0_HATCH_CELL=$(set_e &&  cat ${COMPONENT_DIRECTORY_CHILD}/a0_cell.meta )
  TEST_A0_CELL=$(set_e &&  cat ${COMPONENT_DIRECTORY_CHILD}/a0_cell.snar )
  set -e

  if [ "${TEST_A0_CELL}" == "${TS_TODAY}" ] && [ "${TEST_A0_HATCH_CELL}" == "${TS_TODAY}" ]; then
    echo "test for move_parent_a0_to_child_a0_cell: OK"
  else
    echo "test for move_parent_a0_to_child_a0_cell: ERROR"
    EXIT_CODE=1
  fi

  return ${EXIT_CODE}

}

function test_main() {
  local BASEDIR TESTS_DIR TEST_BACKUP_SOURCE TEST_WORK_DIR
  local TEST_A_DIR TEST_A_DIR_PARENT TEST_A_DIR_CHILD
  local START_META_PARENT START_META_CHILD
  local TEST_BUNDLE_EXIT_CODE=0
  # shellcheck disable=SC2046
  BASEDIR=$(dirname $(realpath "$0"))
  logging "DEBUG" "main" "BASEDIR= ${BASEDIR}"
  TESTS_DIR="${BASEDIR}/TESTS"
  logging "DEBUG" "main" "TESTS_DIR= ${TESTS_DIR}"
  TEST_BACKUP_SOURCE="${TESTS_DIR}/BACKUP_DIR"
  logging "DEBUG" "main" "TEST_BACKUP_SOURCE= ${TEST_BACKUP_SOURCE}"
  TEST_WORK_DIR="${TESTS_DIR}/DIST"
  logging "DEBUG" "main" "TEST_WORK_DIR= ${TEST_WORK_DIR}"

  TEST_A_DIR="${TESTS_DIR}/a_test"
  logging "DEBUG" "main" "TEST_A_DIR= ${TEST_A_DIR}"
  TEST_A_DIR_PARENT="${TEST_A_DIR}/a_test_PARENT"
  logging "DEBUG" "main" "TEST_A_DIR_PARENT= ${TEST_A_DIR_PARENT}"
  TEST_A_DIR_CHILD="${TEST_A_DIR}/a_test_CHILD"
  logging "DEBUG" "main" "TEST_A_DIR_CHILD= ${TEST_A_DIR_CHILD}"

  TS_TODAY=$(set_e && date +%-s)
  logging "DEBUG" "main" "TS_TODAY= ${TS_TODAY}"

  logging "DEBUG" "main" "------------------------------"

  test_f
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}

  test__move_a0_to_a0_hatch_cell
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}

  test__move_parent_a0_to_child_a0_cell
  TEST_BUNDLE_EXIT_CODE=$?
  check_if_broken ${TEST_BUNDLE_EXIT_CODE}


  check_if_broken ${TEST_BUNDLE_EXIT_CODE} "exit"

  logging "DEBUG" "main" "------------------------------"
}


function main() {
  test_main
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
