#!/usr/bin/env bash

if [[ ${MACOS} || ${LINUX} ]]; then
  echo "Updating homebrew..."
  brew update
  echo "Upgrading brew's"
  brew upgrade
  echo "Upgrading brew casks"
  brew upgrade --cask --greedy
  echo "Cleaning up brew"
  brew cleanup
  echo "Updating app store apps softwareupdate"
  sudo -H softwareupdate --install --all --verbose
fi
if [[ ${UBUNTU} ]]; then
  sudo -H apt update
  sudo -H apt dist-upgrade -y
  sudo -H apt autoremove -y
  sudo snap refresh
fi
