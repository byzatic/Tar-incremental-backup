#!/bin/bash -e
#
#
#

function a0_cell() {
  #
  # :: $1 -- str -- component directory
  # :: $2 -- str -- behavior key e.g. read_ts / read_snar / write_ts
  # :: $3 -- str -- write data (OPTIONAL)
  #
  local COMPONENT_DIRECTORY
  local BEHAVIOR_KEY
  local WRITE_DATA
  logging "DEBUG" "a0_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "a0_cell" "COMPONENT_DIRECTORY" ${1})
  BEHAVIOR_KEY=$(set_e && check_input "a0_cell" "BEHAVIOR_KEY" ${2})
  WRITE_DATA=$(set_e && check_input "a0_cell" "WRITE_DATA" ${3} "ARG-PASS")
  #
  local CELL_DADA
  local CELL_META_PATH
  local CELL_SNAR_PATH
  CELL_META_PATH="${COMPONENT_DIRECTORY}/a0_cell.meta"
  CELL_SNAR_PATH="${COMPONENT_DIRECTORY}/a0_cell.snar"

  CELL_DADA=$(set_e && __a_cell_commander ${CELL_META_PATH} ${CELL_SNAR_PATH} ${BEHAVIOR_KEY} ${WRITE_DATA})
  logging "DEBUG" "a0_cell" "finish"
  freturn ${CELL_DADA}
}

function a0_hatch_cell() {
  #
  # :: $1 -- str -- component directory
  # :: $2 -- str -- behavior key e.g. read_ts / read_snar / write_ts
  # :: $3 -- str -- write data (OPTIONAL)
  #
  local COMPONENT_DIRECTORY
  local BEHAVIOR_KEY
  local WRITE_DATA
  logging "DEBUG" "a0_hatch_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "a0_hatch_cell" "COMPONENT_DIRECTORY" ${1})
  BEHAVIOR_KEY=$(set_e && check_input "a0_hatch_cell" "BEHAVIOR_KEY" ${2})
  WRITE_DATA=$(set_e && check_input "a0_hatch_cell" "WRITE_DATA" ${3} "ARG-PASS")
  #
  local CELL_DADA
  local CELL_META_PATH
  local CELL_SNAR_PATH
  CELL_META_PATH="${COMPONENT_DIRECTORY}/a0_hatch_cell.meta"
  CELL_SNAR_PATH="${COMPONENT_DIRECTORY}/a0_hatch_cell.snar"

  CELL_DADA=$(set_e && __a_cell_commander "${CELL_META_PATH}" "${CELL_SNAR_PATH}" "${BEHAVIOR_KEY}" "${WRITE_DATA}")
  logging "DEBUG" "a0_hatch_cell" "finish"
  freturn ${CELL_DADA}
}

function a1_cell() {
  #
  # :: $1 -- str -- component directory
  # :: $2 -- str -- behavior key e.g. read_ts / read_snar / write_ts
  # :: $3 -- str -- write data (OPTIONAL)
  #
  local COMPONENT_DIRECTORY
  local BEHAVIOR_KEY
  local WRITE_DATA
  logging "INFO" "a1_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "a1_cell" "COMPONENT_DIRECTORY" ${1})
  BEHAVIOR_KEY=$(set_e && check_input "a1_cell" "BEHAVIOR_KEY" ${2})
  WRITE_DATA=$(set_e && check_input "a1_cell" "WRITE_DATA" ${3} "ARG-PASS")
  #
  local CELL_DADA
  local CELL_META_PATH
  local CELL_SNAR_PATH
  CELL_META_PATH="${COMPONENT_DIRECTORY}/a1_cell.meta"
  CELL_SNAR_PATH="${COMPONENT_DIRECTORY}/a1_cell.snar"

  CELL_DADA=$(set_e && __a_cell_commander ${CELL_META_PATH} ${CELL_SNAR_PATH} ${BEHAVIOR_KEY} ${WRITE_DATA})
  logging "INFO" "a1_cell" "finish"
  freturn ${CELL_DADA}
}

function __a_cell_commander() {
  #
  # :: $1 -- str -- cell meta file path
  # :: $1 -- str -- cell snar file path
  # :: $2 -- str -- behavior key e.g. read_ts / read_snar / write_ts
  #                 behavior key (not for external usage) __get_snar_file_path / __get_ts_file_path
  # :: $3 -- str -- write data (OPTIONAL)
  #
  local CELL_DADA
  local CELL_META_PATH
  local CELL_SNAR_PATH
  local BEHAVIOR_KEY
  local WRITE_DATA
  CELL_META_PATH=$(set_e && check_input "__a_cell_commander" "CELL_META_PATH" ${1})
  CELL_SNAR_PATH=$(set_e && check_input "__a_cell_commander" "CELL_SNAR_PATH" ${2})
  BEHAVIOR_KEY=$(set_e && check_input "__a_cell_commander" "BEHAVIOR_KEY" ${3})
  WRITE_DATA=$(set_e && check_input "a0_hatch_cell" "WRITE_DATA" ${4} "ARG-PASS")
  local CELL_STATUS

  case ${BEHAVIOR_KEY} in
    "read_meta")
      logging "INFO" "__a_cell_commander" "called read_meta"
      CELL_DADA=$(set_e && __read_file ${CELL_META_PATH})
      logging "INFO" "__a_cell_commander" "returned: ${CELL_DADA}"
      freturn ${CELL_DADA}
      ;;
    "write_meta")
      logging "INFO" "__a_cell_commander" "called write_meta"
      CELL_DADA=$(set_e && __write_file ${CELL_META_PATH} ${WRITE_DATA})
      logging "INFO" "__a_cell_commander" "write cell complete"
      ;;
    "read_meta_path")
      logging "INFO" "__a_cell_commander" "called read_meta_path"
      CELL_DADA=${CELL_META_PATH}
      logging "INFO" "__a_cell_commander" "returned: ${CELL_DADA}"
      freturn ${CELL_DADA}
      ;;
    "init_meta")
      logging "INFO" "__a_cell_commander" "called init_meta"
      __remove_universal ${CELL_META_PATH}
      __create_file ${CELL_META_PATH}
      logging "INFO" "__a_cell_commander" "metafile ${CELL_META_PATH} inited"
      ;;
    "check_meta")
      logging "INFO" "__a_cell_commander" "called check_snar"
      __check_file_exists ${CELL_META_PATH}
      CELL_STATUS=$?
      freturn ${CELL_STATUS}
      logging "INFO" "__a_cell_commander" "returned: ${CELL_STATUS}"
      ;;
    "read_snar")
      logging "INFO" "__a_cell_commander" "called read_ts"
      CELL_DADA=$(set_e && __read_file ${CELL_SNAR_PATH})
      logging "INFO" "__a_cell_commander" "returned: ${CELL_DADA}"
      freturn ${CELL_DADA}
      ;;
    "write_snar")
      logging "INFO" "__a_cell_commander" "called write_ts"
      CELL_DADA=$(set_e && __write_file ${CELL_SNAR_PATH} ${WRITE_DATA})
      logging "INFO" "__a_cell_commander" "write cell complete"
      ;;
    "read_snar_path")
      logging "INFO" "__a_cell_commander" "called read_snar_path"
      CELL_DADA=${CELL_SNAR_PATH}
      logging "INFO" "__a_cell_commander" "returned: ${CELL_DADA}"
      freturn ${CELL_DADA}
      ;;
    "init_snar")
      logging "INFO" "__a_cell_commander" "called init_snar"
      __remove_universal ${CELL_SNAR_PATH}
      __create_file ${CELL_SNAR_PATH}
      logging "INFO" "__a_cell_commander" "metafile ${CELL_SNAR_PATH} inited"
      ;;
    "check_snar")
      logging "INFO" "__a_cell_commander" "called check_snar"
      __check_file_exists ${CELL_SNAR_PATH}
      CELL_STATUS=$?
      freturn ${CELL_STATUS}
      logging "INFO" "__a_cell_commander" "returned: ${CELL_STATUS}"
      ;;
    "__get_snar_file_path")
      logging "INFO" "__a_cell_commander" "called __get_snar_file_path"
      logging "INFO" "__a_cell_commander" "returned: ${CELL_SNAR_PATH}"
      freturn ${CELL_SNAR_PATH}
      ;;
    "__get_ts_file_path")
      logging "INFO" "__a_cell_commander" "called __get_ts_file_path"
      logging "INFO" "__a_cell_commander" "returned: ${CELL_META_PATH}"
      freturn ${CELL_META_PATH}
      ;;
    *)
      logging "CRITICAL" "__a_cell_commander" "A0 Cell have no option ${BEHAVIOR_KEY}"
      system_exit 1
      ;;
  esac
}


function move_a0_to_a0_hatch_cell() {
  #
  # :: $1 -- str -- component directory
  #
  local COMPONENT_DIRECTORY
  local A0_SNAR_FILE_PATH
  local A0_TS_FILE_PATH
  local A0_HATCH_SNAR_FILE_PATH
  local A0_HATCH_TS_FILE_PATH
  #
  logging "INFO" "move_a0_to_a0_hatch_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "move_a0_to_a0_hatch_cell" "COMPONENT_DIRECTORY" ${1})
  #
  A0_SNAR_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A0_TS_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  A0_HATCH_SNAR_FILE_PATH=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A0_HATCH_TS_FILE_PATH=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  #
  __remove_universal ${A0_HATCH_SNAR_FILE_PATH}
  __remove_universal ${A0_HATCH_TS_FILE_PATH}
  __copy_file ${A0_SNAR_FILE_PATH} ${A0_HATCH_SNAR_FILE_PATH}
  __copy_file ${A0_TS_FILE_PATH} ${A0_HATCH_TS_FILE_PATH}
  logging "INFO" "move_a0_to_a0_hatch_cell" "finish"
}

function move_a0_hatch_to_a1_cell() {
  #
  # :: $1 -- str -- component directory
  #
  local COMPONENT_DIRECTORY
  local A1_SNAR_FILE_PATH
  local A1_TS_FILE_PATH
  local A0_HATCH_SNAR_FILE_PATH
  local A0_HATCH_TS_FILE_PATH
  #
  logging "INFO" "move_a0_hatch_to_a1_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "move_a0_hatch_to_a1_cell" "COMPONENT_DIRECTORY" ${1})
  #
  A1_SNAR_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A1_TS_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  A0_HATCH_SNAR_FILE_PATH=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A0_HATCH_TS_FILE_PATH=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  #
  __remove_universal ${A1_SNAR_FILE_PATH}
  __remove_universal ${A1_TS_FILE_PATH}
  __copy_file ${A0_HATCH_SNAR_FILE_PATH} ${A1_SNAR_FILE_PATH}
  __copy_file ${A0_HATCH_TS_FILE_PATH} ${A1_TS_FILE_PATH}
  logging "INFO" "move_a0_hatch_to_a1_cell" "finish"
}

function move_a0_to_a1_cell() {
  #
  # :: $1 -- str -- component directory
  #
  local COMPONENT_DIRECTORY
  local A0_SNAR_FILE_PATH
  local A0_TS_FILE_PATH
  local A1_SNAR_FILE_PATH
  local A1_TS_FILE_PATH
  #
  logging "INFO" "move_a0_to_a1_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "move_a0_to_a1_cell" "COMPONENT_DIRECTORY" ${1})
  #
  A0_SNAR_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A0_TS_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  A1_SNAR_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A1_TS_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  #
  __remove_universal ${A1_SNAR_FILE_PATH}
  __remove_universal ${A1_TS_FILE_PATH}
  #

  if ( __check_file_exists ${A0_SNAR_FILE_PATH} ); then
    __copy_file ${A0_SNAR_FILE_PATH} ${A1_SNAR_FILE_PATH}
    __copy_file ${A0_TS_FILE_PATH} ${A1_TS_FILE_PATH}
  else
    logging "WARNING" "move_a0_to_a1_cell" "There is no a0 snar file"
    logging "WARNING" "move_a0_to_a1_cell" "Nothing to move a0->a1; pass"
  fi
  #
  logging "INFO" "move_a0_to_a1_cell" "finish"
}

function move_a1_to_a0_cell() {
  #
  # :: $1 -- str -- component directory
  #
  local COMPONENT_DIRECTORY
  local A0_SNAR_FILE_PATH
  local A0_TS_FILE_PATH
  local A1_SNAR_FILE_PATH
  local A1_TS_FILE_PATH
  #
  logging "INFO" "move_a1_to_a0_cell" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "move_a1_to_a0_cell" "COMPONENT_DIRECTORY" ${1})
  #
  A0_SNAR_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A0_TS_FILE_PATH=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  A1_SNAR_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_snar_file_path")
  A1_TS_FILE_PATH=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "__get_ts_file_path")
  #
  __remove_universal ${A0_SNAR_FILE_PATH}
  __remove_universal ${A0_TS_FILE_PATH}
  __copy_file ${A1_SNAR_FILE_PATH} ${A0_SNAR_FILE_PATH}
  __copy_file ${A1_TS_FILE_PATH} ${A0_TS_FILE_PATH}
  __remove_universal ${A1_SNAR_FILE_PATH}
  __remove_universal ${A1_TS_FILE_PATH}
  logging "INFO" "move_a1_to_a0_cell" "finish"
}

function move_parent_a0_to_child_a0_cell() {
  #
  # :: $1 -- str -- parents' component directory
  # :: $2 -- str -- childs' component directory
  #
  local COMPONENT_DIRECTORY_PARENT
  local COMPONENT_DIRECTORY_CHILD
  local A0_SNAR_FILE_PATH_PARENT
  local A0_TS_FILE_PATH_PARENT
  local A0_SNAR_FILE_PATH_CHILD
  local A0_TS_FILE_PATH_CHILD
  #
  logging "INFO" "move_parent_a0_to_child_a0_hatch_cell" "start"
  COMPONENT_DIRECTORY_PARENT=$(set_e && check_input "move_parent_a0_to_child_a0_hatch_cell" "COMPONENT_DIRECTORY_PARENT" ${1})
  COMPONENT_DIRECTORY_CHILD=$(set_e && check_input "move_parent_a0_to_child_a0_hatch_cell" "COMPONENT_DIRECTORY_CHILD" ${2})
  #
  A0_SNAR_FILE_PATH_PARENT=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "__get_snar_file_path")
  A0_TS_FILE_PATH_PARENT=$(set_e && a0_cell ${COMPONENT_DIRECTORY_PARENT} "__get_ts_file_path")
  A0_SNAR_FILE_PATH_CHILD=$(set_e && a0_cell ${COMPONENT_DIRECTORY_CHILD} "__get_snar_file_path")
  A0_TS_FILE_PATH_CHILD=$(set_e && a0_cell ${COMPONENT_DIRECTORY_CHILD} "__get_ts_file_path")
  #
  __remove_universal ${A0_SNAR_FILE_PATH_CHILD}
  __remove_universal ${A0_TS_FILE_PATH_CHILD}
  __copy_file ${A0_SNAR_FILE_PATH_PARENT} ${A0_SNAR_FILE_PATH_CHILD}
  __copy_file ${A0_TS_FILE_PATH_PARENT} ${A0_TS_FILE_PATH_CHILD}
  logging "INFO" "move_parent_a0_to_child_a0_hatch_cell" "finish"
}

function move_parent_a0_hatch_to_child_a0_hatch_cell() {
  #
  # :: $1 -- str -- parents' component directory
  # :: $2 -- str -- childs' component directory
  #
  local COMPONENT_DIRECTORY_PARENT
  local COMPONENT_DIRECTORY_CHILD
  local A0_HATCH_SNAR_FILE_PATH_PARENT
  local A0_HATCH_TS_FILE_PATH_PARENT
  local A0_HATCH_SNAR_FILE_PATH_CHILD
  local A0_HATCH_TS_FILE_PATH_CHILD
  #
  logging "INFO" "move_parent_a0_hatch_to_child_a0_hatch_cell" "start"
  COMPONENT_DIRECTORY_PARENT=$(set_e && check_input "move_parent_a0_hatch_to_child_a0_hatch_cell" "COMPONENT_DIRECTORY_PARENT" ${1})
  COMPONENT_DIRECTORY_CHILD=$(set_e && check_input "move_parent_a0_hatch_to_child_a0_hatch_cell" "COMPONENT_DIRECTORY_CHILD" ${2})
  #
  A0_HATCH_SNAR_FILE_PATH_PARENT=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "__get_snar_file_path")
  A0_HATCH_TS_FILE_PATH_PARENT=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_PARENT} "__get_ts_file_path")
  A0_HATCH_SNAR_FILE_PATH_CHILD=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_CHILD} "__get_snar_file_path")
  A0_HATCH_TS_FILE_PATH_CHILD=$(set_e && a0_hatch_cell ${COMPONENT_DIRECTORY_CHILD} "__get_ts_file_path")
  #
  __remove_universal ${A0_HATCH_SNAR_FILE_PATH_CHILD}
  __remove_universal ${A0_HATCH_TS_FILE_PATH_CHILD}
  __copy_file ${A0_HATCH_SNAR_FILE_PATH_PARENT} ${A0_HATCH_SNAR_FILE_PATH_CHILD}
  __copy_file ${A0_HATCH_TS_FILE_PATH_PARENT} ${A0_HATCH_TS_FILE_PATH_CHILD}
  logging "INFO" "move_parent_a0_hatch_to_child_a0_hatch_cell" "finish"
}

function boolean_check_if_a0_exists() {
  #
  # :: $1 -- str -- component directory
  #
  local COMPONENT_DIRECTORY
  local CHECK_RESULT_SNAR CHECK_RESULT_META
  logging "INFO" "boolean_check_if_a0_exists" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "boolean_check_if_a0_exists" "COMPONENT_DIRECTORY" "${1}")
  #
  CHECK_RESULT_SNAR=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "check_snar")
  CHECK_RESULT_META=$(set_e && a0_cell ${COMPONENT_DIRECTORY} "check_meta")
  if [ "${CHECK_RESULT_SNAR}" == "0" ] && [ "${CHECK_RESULT_META}" == "0" ]; then
    return 0
  else
    return 1
  fi
  logging "INFO" "boolean_check_if_a0_exists" "finish"
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi