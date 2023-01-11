#!/usr/bin/env bash

# REQUIRED for setup
. "$DIR/setup_general.sh"

# Check flavour of linux distro
LINUX_TYPE=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
[[ ${LINUX_TYPE} = "Ubuntu" ]] && export UBUNTU=1

if [[ ${UBUNTU} ]]; then
  UBUNTU_VERSION=$(lsb_release -rs)
  [[ ${UBUNTU_VERSION} = "18.04" ]] && export BIONIC=1
  [[ ${UBUNTU_VERSION} = "20.04" ]] && export FOCAL=1
  [[ ${UBUNTU_VERSION} = "22.04" ]] && export JAMMY=1
  [[ ${UBUNTU_VERSION} = "6" ]] && export FOCAL=1 # elementary os

  # Hardware enablement updates
  if [[ ${FOCAL} ]]; then
    sudo -H apt install --install-recommends linux-generic-hwe-20.04 -y
  elif [[ ${JAMMY} ]]; then
    sudo -H apt install --install-recommends linux-generic-hwe-22.04 -y
  fi

  # Install common packages (including zsh)
  xargs -a ./ubuntu_common_packages.txt sudo apt install -y

  sudo -H apt update

  # snap package installation
  xargs -a ./ubuntu_workstation_snap_packages.txt sudo snap install

  echo "Installing pyenv"
  curl https://pyenv.run | bash

  echo "Installing docker desktop"
  if [ ! -x "$(command -v docker)" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    # So we don't have to run as sudo
    sudo -H groupadd docker
    sudo usermod -aG docker ${USER}
    newgrp docker
  fi

  sudo -H apt autoremove -y
fi

echo "Setting ZSH as shell..."
if [[ ! ${SHELL} = "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

###
# dotfile configuration
###
echo "Linking ${DOTFILES} to their home"

echo ".gitconfig link"
if [[ -f ${HOME}/.gitconfig ]]; then
  rm ${HOME}/.gitconfig
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
elif [[ ! -L ${HOME}/.gitconfig ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
fi

