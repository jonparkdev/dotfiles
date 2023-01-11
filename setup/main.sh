#!/usr/bin/env bash

# import initial dependencies of main
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/functions.sh"
. "$DIR/config.sh"

# Display CLI help.
help() {
  echo "This script provides options to setup configuration for a Ubuntu or Mac Machine"
  echo 
  echo "Syntax: ./main.sh [option]"
  echo
  echo "options:"
  echo "    -o   Select from the following options: `setup` or `update`"
  exit 0;
}

[[ $# -eq 0 ]] && help

# Command line options
# setup: run a full machine and developer setup
while getopts ":ho:w" arg; do
  case ${arg} in
    o) 
      [[ ${OPTARG} = "setup" ]] && export SETUP=1
      [[ ${OPTARG} = "update" ]] && export UPDATE=1
      ;;
    h) 
      # display help
      help
      exit 0
      ;;
    \?) 
      echo "Error: Invalid Option"
      exit 1
      ;;
  esac
done

###
# Setup a new environment
###
if [[ ${SETUP} ]]; then
  if [[ ${MACOS} ]]; then
    . "$DIR/setup_mac.sh"
  fi
  if [[ ${LINUX} ]]; then
    . "$DIR/setup_linux.sh"
  fi
fi

if [[ ${UPDATE} ]]; then
 . "$DIR/update.sh"
fi

exit 0