#!/usr/bin/env bash

# Directory locations
GITREPOS="${HOME}/git-repos"
PERSONAL_GITREPOS="${GITREPOS}/personal"
DOTFILES="dotfiles"
BREWFILE_LOC="${HOME}/brew"
HOSTNAME=$(hostname -s)

# Determine which env this script is running on 
[[ $(uname -s) = "Darwin" ]] && export MACOS=1
[[ $(uname -s) = "Linux" ]] && export LINUX=1