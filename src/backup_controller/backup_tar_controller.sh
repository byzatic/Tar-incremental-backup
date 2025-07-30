#!/bin/bash -e
#
#
#

function incremental_backup_controller() {
  #
  # :: $1 -- str -- component directory
  # :: $2 -- str -- backup source directory abs path
  # :: $3 -- str -- current ts
  #
  local COMPONENT_DIRECTORY SOURCE_DIRECTORY OUTPUT_DIRECTORY A1_SNAR_FILE UNIX_TIMESTAMP A_CELL_USE
  local ARCHIVE_FILENAME
  #
  logging "INFO" "incremental_backup_controller" "start"
  COMPONENT_DIRECTORY=$(set_e && check_input "incremental_backup_controller" "COMPONENT_DIRECTORY" ${1})
  SOURCE_DIRECTORY=$(set_e && check_input "incremental_backup_controller" "SOURCE_DIRECTORY" ${2})
  UNIX_TIMESTAMP=$(set_e && check_input "incremental_backup_controller" "UNIX_TIMESTAMP" ${3})
  A_CELL_USE=$(set_e && check_input "incremental_backup_controller" "A_CELL_USE" ${4})
  OUTPUT_DIRECTORY=${COMPONENT_DIRECTORY}
  A1_SNAR_FILE=$(set_e && a1_cell ${COMPONENT_DIRECTORY} "read_snar_path")


  case ${A_CELL_USE} in
    "A0")
      if [ "$(a0_cell ${COMPONENT_DIRECTORY} "check_meta")" == "1" ]; then
        a0_cell "${COMPONENT_DIRECTORY}" "init_meta"
        a0_cell "${COMPONENT_DIRECTORY}" "write_meta" "infinity"
      fi
      move_a0_to_a1_cell ${COMPONENT_DIRECTORY}
      a1_cell "${COMPONENT_DIRECTORY}" "init_meta"
      a1_cell "${COMPONENT_DIRECTORY}" "write_meta" "${UNIX_TIMESTAMP}"
      ARCHIVE_FILENAME=$(set_e && generate_archive_name "${UNIX_TIMESTAMP}" "${COMPONENT_DIRECTORY}" "${A_CELL_USE}")
      ;;
    "A0_HATCH")
      move_a0_hatch_to_a1_cell ${COMPONENT_DIRECTORY}
      a1_cell "${COMPONENT_DIRECTORY}" "init_meta"
      a1_cell "${COMPONENT_DIRECTORY}" "write_meta" "${UNIX_TIMESTAMP}"
      ARCHIVE_FILENAME=$(set_e && generate_archive_name "${UNIX_TIMESTAMP}" "${COMPONENT_DIRECTORY}" "${A_CELL_USE}")
      ;;
    *)
      logging "CRITICAL" "incremental_backup_controller" "no such cell for behavior key A_CELL_USE= ${A_CELL_USE}"
      system_exit 1
      ;;
  esac

  __incremental_backup_tar ${A1_SNAR_FILE} ${SOURCE_DIRECTORY} ${OUTPUT_DIRECTORY} ${ARCHIVE_FILENAME}

  move_a1_to_a0_cell ${COMPONENT_DIRECTORY}

  logging "INFO" "incremental_backup_controller" "finish"
}

function generate_archive_name() {
  #
  # :: $1 -- str -- current ts
  # :: $2 -- str -- component directory
  #
  local UNIX_TIMESTAMP COMPONENT_DIRECTORY FILE_NAME
  local A0_TS A1_TS
  local YYMMWWDD GET_YY GET_MM GET_TEMP_WW GET_WW GET_DD
  local ISODATE
  local A_CELL_USE
  #
  UNIX_TIMESTAMP=$(set_e && check_input "generate_archive_name" "UNIX_TIMESTAMP" "${1}")
  COMPONENT_DIRECTORY=$(set_e && check_input "generate_archive_name" "COMPONENT_DIRECTORY" "${2}")
  A_CELL_USE=$(set_e && check_input "generate_archive_name" "A_CELL_USE" "${3}")

  case ${A_CELL_USE} in
    "A0")
      A0_TS=$(set_e && a0_cell "${COMPONENT_DIRECTORY}" "read_meta")
      logging "INFO" "generate_archive_name" "A0_TS= ${A0_TS}"
      ;;
    "A0_HATCH")
      A0_TS=$(set_e && a0_hatch_cell "${COMPONENT_DIRECTORY}" "read_meta")
      logging "INFO" "generate_archive_name" "A0_TS= ${A0_TS}"
      ;;
    *)
      logging "CRITICAL" "generate_archive_name" "no such cell for behavior key A_CELL_USE= ${A_CELL_USE}"
      system_exit 1
      ;;
  esac
  A1_TS=$(set_e && a1_cell "${COMPONENT_DIRECTORY}" "read_meta")
  logging "DEBUG" "generate_archive_name" "A1_TS= ${A1_TS}"

  YYMMWWDD=$(set_e && get_YYMMWWDD "${UNIX_TIMESTAMP}")
  logging "DEBUG" "generate_archive_name" "YYMMWWDD= ${YYMMWWDD}"

  # For UTC time (zero offset, historically known as "Zulu time") you can use
  # (note the -u, to get UTC time, and note that the 'Z' is not preceded by a '%'
  # (or a colon) – it is a literal 'Z'):
  ISODATE=$(set_e && date +"%Y-%m-%dT%H:%M:%SZ" -d "@${UNIX_TIMESTAMP}")
  logging "DEBUG" "generate_archive_name" "ISODATE= ${ISODATE}"

  FILE_NAME="archive_${YYMMWWDD}_${A0_TS}_${A1_TS}_${ISODATE}"
  logging "INFO" "generate_archive_name" "FILE_NAME= ${FILE_NAME}"

  logging "INFO" "generate_archive_name" "finish"

  freturn ${FILE_NAME}
}

function get_YYMMWWDD() {
  #
  # :: $1 -- str -- current ts
  #
  local UNIX_TIMESTAMP
  local YYMMWWDD GET_YY GET_MM GET_WW GET_DD
  logging "INFO" "get_YYMMWWDD" "start"
  UNIX_TIMESTAMP=$(set_e && check_input "get_YYMMWWDD" "UNIX_TIMESTAMP" "${1}")
  GET_YY=$(set_e && date +%Y -d "@${UNIX_TIMESTAMP}")
  GET_MM=$(set_e && date +%-m -d "@${UNIX_TIMESTAMP}")
  GET_WW=$((($(set_e && date +%-d -d "@${UNIX_TIMESTAMP}")-1)/7+1))
  GET_DD=$(set_e && date +%-u -d "@${UNIX_TIMESTAMP}")
  YYMMWWDD="${GET_YY}.${GET_MM}.${GET_WW}.${GET_DD}"
  logging "DEBUG" "get_YYMMWWDD" "YYMMWWDD= ${YYMMWWDD}"
  logging "INFO" "get_YYMMWWDD" "finish"
  freturn ${YYMMWWDD}
}

function main() {
  exit 0
}

if [ "${1}" != "--source-only" ]; then
  main "${@}"
fi