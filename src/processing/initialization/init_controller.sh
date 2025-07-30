#!/bin/bash -e
#
#
#

function get_init_file_path() {
  #
  # :: $1 -- str -- work directory
  #
  local WORKING_DIRECTORY
  local INIT_FILE_PATH
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${1}")
  #
  INIT_FILE_PATH="${WORKING_DIRECTORY}/.init"
  freturn "${INIT_FILE_PATH}"
}

function init_controller() {
  #
  # :: $1 -- str -- work directory
  # :: $2 -- int -- backup sources directory
  # :: $3 -- int -- current timestamp
  # :: $4 -- int -- component name e.g. YEARS / MONTHS / WEEKS / DAYS
  #
  local WORKING_DIRECTORY SOURCE_DIRECTORY UNIX_TIMESTAMP COMPONENT_NAME
  #
  local INIT_FILE_PATH CONTROLLER_RESULT UNDEFINED_WORKING_DIRECTORY_STATE_MESSAGE CONTROLLER_OUT first second
  #
  WORKING_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "WORKING_DIRECTORY" "${1}")
  SOURCE_DIRECTORY=$(set_e && check_input "${FUNCNAME}" "SOURCE_DIRECTORY" "${2}")
  UNIX_TIMESTAMP=$(set_e && check_input "${FUNCNAME}" "UNIX_TIMESTAMP" "${3}")
  COMPONENT_NAME=$(set_e && check_input "${FUNCNAME}" "COMPONENT_NAME" "${4}")
  #
  INIT_FILE_PATH=$(set_e && get_init_file_path "${WORKING_DIRECTORY}")
  logging "DEBUG" "${FUNCNAME}" "start init_controller"

  IFS='|' read -r first second <<< "$(set_e && check_init_path_state ${INIT_FILE_PATH})"
  logging "DEBUG" "${FUNCNAME}" "check_init_path_state -> first=${first} second=${second}"
  if [ "${first}" == "True" ]; then
    CONTROLLER_RESULT="cmd:not_initialised"
  elif [ "${first}" == "False" ] && [ "${second}" == "Na" ]; then
    CONTROLLER_RESULT="cmd:initialised"
  elif [ "${first}" == "False" ] && ! [ "${second}" == "Na" ]; then
    CONTROLLER_RESULT="cmd:undefined_working_directory_state"
    UNDEFINED_WORKING_DIRECTORY_STATE_MESSAGE="${second}"
  fi

  case ${CONTROLLER_RESULT} in
    "cmd:initialised")
      logging "DEBUG" "${FUNCNAME}" "backup already initialised"
      logging "DEBUG" "${FUNCNAME}" "finish init_controller"
      CONTROLLER_OUT="cmd:initialisation_pass"
      ;;
    "cmd:not_initialised")
      logging "DEBUG" "${FUNCNAME}" "backup not initialised"
      initialisation ${WORKING_DIRECTORY} "${COMPONENT_NAME}" ${SOURCE_DIRECTORY} ${UNIX_TIMESTAMP}
      __create_file ${INIT_FILE_PATH}
      logging "DEBUG" "${FUNCNAME}" "finish init_controller"
      CONTROLLER_OUT="cmd:initialisation_complete"
      ;;
    "cmd:undefined_working_directory_state")
      logging "CRITICAL" "${FUNCNAME}" "${UNDEFINED_WORKING_DIRECTORY_STATE_MESSAGE}"
      system_exit 1
      ;;
    *)
      logging "CRITICAL" "${FUNCNAME}" "Initialisation controller has entered an uncertain state"
      system_exit 1
      ;;
  esac

  freturn "${CONTROLLER_OUT}"
}


function check_init_path_state() {
  #
  # :: $1 -- int -- initialization file path
  #
  local INIT_FILE_PATH
  local WORKING_DIRECTORY
  local INIT_FILE_NAME
  #
  INIT_FILE_PATH=$(set_e && check_input "${FUNCNAME}" "INIT_FILE_PATH" "${1}")
  WORKING_DIRECTORY="${INIT_FILE_PATH%/*}"
  INIT_FILE_NAME="${INIT_FILE_PATH##*/}"
  #
  logging "DEBUG" "${FUNCNAME}" "start"

  if (__check_file_exists "${INIT_FILE_PATH}"); then
    freturn "False|Na"
  elif (! __check_file_exists "${INIT_FILE_PATH}") && (__is_directory_empty "${WORKING_DIRECTORY}" "${INIT_FILE_NAME}"); then
    freturn "True|Na"
  elif (! __check_file_exists "${INIT_FILE_PATH}") && (! __is_directory_empty "${WORKING_DIRECTORY}" "${INIT_FILE_NAME}"); then
    freturn "False|Initialisation file not exists, but directory is not empty"
  else
    is_directory_empty=$(set_e && __is_directory_empty "${WORKING_DIRECTORY}" "${INIT_FILE_NAME}")
    check_file_exists=$(set_e && __check_file_exists "${INIT_FILE_PATH}")
    logging "DEBUG" "${FUNCNAME}" "Something goes wrong; is_directory_empty=${is_directory_empty} check_file_exists=${check_file_exists}"
    system_exit 1
  fi
  logging "DEBUG" "${FUNCNAME}" "finish"
}

function __is_directory_empty() {
    local dir_path="$1"
    shift  # Убираем первый аргумент (путь к директории), остальные — файлы для исключения
    local exclusions=("$@")  # Список файлов/папок для исключения

    if (! __check_directory_exists "${dir_path}"); then
        logging "CRITICAL" "${FUNCNAME}" "Ошибка: '$dir_path' не является директорией."
        system_exit 1
    fi

    # Получаем список всех файлов и папок, кроме указанных в exclusions
    local files=()
    for item in $( ls -A $dir_path ); do
      logging "DEBUG" "${FUNCNAME}" "found item=<$item>"
        [[ "$item" == "$dir_path/." || "$item" == "$dir_path/.." ]] && continue  # Пропускаем . и ..

        local exclude=false
        for excl in "${exclusions[@]}"; do
            if [[ "$item" == "$dir_path/$excl" ]]; then
                exclude=true
                break
            fi
        done

        [[ "$exclude" == true ]] && continue
        files+=("$item")  # Добавляем файл/папку, если он не в списке исключений
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        logging "DEBUG" "${FUNCNAME}" "Директория '$dir_path' пуста (с учётом исключений)."
        return 0
    else
        logging "DEBUG" "${FUNCNAME}" "Директория '$dir_path' не пуста (с учётом исключений)."
        logging "DEBUG" "${FUNCNAME}" "Директория '$dir_path' - ${#files[@]}"
        return 1
    fi
}


if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi