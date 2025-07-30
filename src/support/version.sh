#!/bin/bash -e
#
#
#

function get_version() {
  local VERSION="1.2.0"
  logging "DEBUG" "${FUNCNAME}" "return version string: ${VERSION}"
  freturn "${VERSION}"
}