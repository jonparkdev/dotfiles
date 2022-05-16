#!/usr/bin/env bash

# software versions to be installed
GIT_VER="2.36.0"
GIT_URL="https://mirrors.edge.kernel.org/pub/software/scm/git"
ZSH_VER="5.8"
TERRAFORM_VER="1.0.2"
DOCKER_COMPOSE_VER="2.3.3"
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)"

# directory locations
GITREPOS="${HOME}/git-repos"
PERSONAL_GITREPOS="${GITREPOS}/personal"
DOTFILES="dotfiles"
BREWFILE_LOC="${HOME}/brew"
HOSTNAME=$(hostname -s)

# Function to test for new M1 silicone
install_rosetta() {
  # Determine OS version
  # Save current IFS state

  OLDIFS=$IFS

  IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

  # restore IFS to previous state

  IFS=$OLDIFS

  # Check to see if the Mac is reporting itself as running macOS 11

  if [[ ${osvers_major} -ge 11 ]]; then

    # Check to see if the Mac needs Rosetta installed by testing the processor

    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")

    if [[ -n "$processor" ]]; then
      echo "$processor processor installed. No need to install Rosetta."
    else

      # Check for Rosetta "oahd" process. If not found,
      # perform a non-interactive install of Rosetta.

      if /usr/bin/pgrep oahd >/dev/null 2>&1; then
          echo "Rosetta is already installed and running. Nothing to do."
      else
          /usr/sbin/softwareupdate --install-rosetta --agree-to-license

          if [[ $? -eq 0 ]]; then
            echo "Rosetta has been successfully installed."
          else
            echo "Rosetta installation failed!"
            exitcode=1
          fi
      fi
    fi
    else
      echo "Mac is running macOS $osvers_major.$osvers_minor.$osvers_dot_version."
      echo "No need to install Rosetta on this version of macOS."
  fi
}

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[[ $# -eq 0 ]] && usage

## Command line options
# setup: run a full machine and developer setup
while getopts ":ht" arg; do
  case ${arg} in
    t) 
      [[ ${OPTARG} = "setup" ]] && export SETUP=1
      ;;
    h | *) # display help
      usage
      exit 0
      ;;
  esac
done

# Determine which env this script is running on 
[[ $(uname -s) = "Darwin" ]] && export MACOS=1
[[ $(uname -s) = "Linux" ]] && export LINUX=1

if [[ ${LINUX} ]]; then
  LINUX_TYPE=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
  echo "${LINUX_TYPE}"
fi


exit 0