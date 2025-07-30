#!/bin/bash -e
#
#
#

#Defining a directory structure controller (initialisation) function
function __ds_controller() {
  #
  # :: $1 -- str -- global working directory e.g. /la/la/TEST/WORKDIR
  #
  local WORKING_DIRECTORY
  WORKING_DIRECTORY=$(set_e && check_input "__ds_controller" "WORKING_DIRECTORY" ${1})
  logging "INFO" "__ds_controller" "start"
  local DIRECTORY_STRUCTURE=("YEARS" "MONTHS" "WEEKS" "DAYS")
  for DIRECTORY_STRUCTURE_ELEMENT in "${DIRECTORY_STRUCTURE[@]}"
  do
    __make_directory "${WORKING_DIRECTORY}/${DIRECTORY_STRUCTURE_ELEMENT}"
  done
    logging "INFO" "__ds_controller" "finish"
}

#Defining reinitialisation function
function directories_reinitialisation() {
  #
  # :: $1 -- str -- local working directory e.g. /la/la/TEST/WORKDIR/YEARS to remove
  # :: $2 -- str -- global working directory e.g. /la/la/TEST/WORKDIR
  #
  local WORKING_DIRECTORY_ELEMENT
  local WORKING_DIRECTORY
  WORKING_DIRECTORY_ELEMENT=$(set_e && check_input "directories_reinitialisation" "WORKING_DIRECTORY_ELEMENT" ${1})
  WORKING_DIRECTORY=$(set_e && check_input "directories_reinitialisation" "WORKING_DIRECTORY" ${2})
  logging "INFO" "directories_reinitialisation" "start"
  __remove_universal ${WORKING_DIRECTORY_ELEMENT}
  __ds_controller ${WORKING_DIRECTORY}
  logging "INFO" "directories_reinitialisation" "finish"
}

#Defining initialisation function
function directories_initialisation() {
  #
  # :: $1 -- str -- global working directory e.g. /la/la/TEST/WORKDIR
  #
  local WORKING_DIRECTORY
  WORKING_DIRECTORY=$(set_e && check_input "directories_initialisation" "WORKING_DIRECTORY" ${1})
  logging "INFO" "directories_initialisation" "start"
  __ds_controller ${WORKING_DIRECTORY}
  logging "INFO" "directories_initialisation" "finish"
}

#Defining a Directory Structure Creation Function
function __create_directory() {
  # directory structure creation
  #
  # :: $1 -- str -- workdir
  # :: $2 -- str -- directory name
  #
  local WORKING_DIRECTORY
  local WORKING_DIRECTORY_ELEMENT
  WORKING_DIRECTORY=$(set_e && check_input "__create_directory" "WORKING_DIRECTORY_ELEMENT" ${1})
  WORKING_DIRECTORY_ELEMENT=$(set_e && check_input "__create_directory" "WORKING_DIRECTORY_ELEMENT" ${2})
  __make_directory "${WORKING_DIRECTORY}/${WORKING_DIRECTORY_ELEMENT}"
}

#Defining a __create_directory cover
function __create_directory_structure() {
  __create_directory ${1} ${2}
}

function main() {
    exit 0
}

if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
