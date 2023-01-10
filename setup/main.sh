#!/usr/bin/env bash

# import initial dependencies of main
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/functions.sh"
. "$DIR/config.sh"

# function be called if incorrect use of STDIN
usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[[ $# -eq 0 ]] && usage

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
      usage
      exit 0
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