#!/usr/bin/env bash

function get_platform_version_strings() {
  local platform=$1
  local file_path=$2

  case "$platform" in
    android)
      if [[ -f "${file_path}" ]]; then
        grep versionName "${file_path}" | tr \" "\n" | grep -e "\."
      else
        echo "UNDEFINED"
      fi
      ;;

    ios)
      if [[ -f "${file_path}" ]]; then
        grep -m 1 s.version "${file_path}" | tr \' "\n" | tail -2 | head -1
      else
        echo "UNDEFINED"
      fi
      ;;

    react)
      if [[ -f "${file_path}" ]]; then
        grep version "${file_path}" | tr \" "\n" | grep -e "\."
      else
        echo "UNDEFINED"
      fi
      ;;
  esac
}