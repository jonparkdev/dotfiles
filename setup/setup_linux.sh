#!/usr/bin/env bash

# Check flavour of linux distro
LINUX_TYPE=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
[[ ${LINUX_TYPE} = "Ubuntu" ]] && export UBUNTU=1

if [[ ${UBUNTU} ]]; then
  echo "Creating Directory to store software downloads"
  if ! [[ -d ${HOME}/software_downloads ]]; then
    mkdir ${HOME}/software_downloads
  fi

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
  echo "Setting ZSH as shell..."
  if [[ ! ${SHELL} = "/bin/zsh" ]]; then
    chsh -s /bin/zsh
  fi


  sudo -H apt update

  echo "Installing docker desktop"
  if [ ! -x "$(command -v docker)" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    # So we don't have to run as sudo
    sudo -H groupadd docker
    sudo usermod -aG docker ${USER}
    newgrp docker
  fi

  echo "Installing pyenv"
  curl https://pyenv.run | bash

  # Install NPM
  echo "Install nvm for node environments and set default to lts"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

  sudo -H apt autoremove -y

  if [[ ${WORKSTATION} ]]; then 
    # snap package installation
    xargs -a ./ubuntu_workstation_snap_packages.txt sudo snap install

    # Install homebrew for Linux
    if ! [ -x "$(command -v brew)" ]; then
      echo "Installing homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi
fi

###
# Link dotfiles to home directory
###

echo "Creating ${PERSONAL_GITREPOS}"
if [[ ! -d ${PERSONAL_GITREPOS} ]]; then
  mkdir ${PERSONAL_GITREPOS}
fi

echo "Copying ${DOTFILES} from Github"
if [[ ! -d ${PERSONAL_GITREPOS}/${DOTFILES} ]]; then
  cd ${HOME} || return
  # git clone --recursive git@github.com:jonparkdev/${DOTFILES}.git ${PERSONAL_GITREPOS}/${DOTFILES}
  # for regular https github used on machines that will not push changes
  git clone --recursive https://github.com/jonparkdev/${DOTFILES}.git ${PERSONAL_GITREPOS}/${DOTFILES}
else
  cd ${PERSONAL_GITREPOS}/${DOTFILES} || return
  git pull
fi

echo "ZSH configuration"
if [[ -f ${HOME}/.zshenv ]]; then
  rm ${HOME}/.zshenv
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshenv ${HOME}/.zshenv
elif [[ ! -L ${HOME}/.zshenv ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshenv ${HOME}/.zshenv
fi

if [[ -f ${HOME}/.zshrc ]]; then
  rm ${HOME}/.zshrc
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
elif [[ ! -L ${HOME}/.zshrc ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
fi

if [[ -d ${HOME}/.zsh ]]; then
  rm -rf ${HOME}/.zsh
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zsh/ ${HOME}/.zsh
elif [[ ! -L ${HOME}/.zsh ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zsh/ ${HOME}/.zsh
fi

echo ".gitconfig link"
if [[ -f ${HOME}/.gitconfig ]]; then
  rm ${HOME}/.gitconfig
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
elif [[ ! -L ${HOME}/.gitconfig ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
fi

echo "starship profile"
if [[ ! -d ${HOME}/.config ]]; then
  mkdir -p ${HOME}/.config
fi

if [[ -f ${HOME}/.config/starship.toml ]]; then
  rm ${HOME}/.config/starship.toml
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.config/starship.toml ${HOME}/.config/starship.toml
elif [[ ! -L ${HOME}/.config/starship.toml ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.config/starship.toml ${HOME}/.config/starship.toml
fi







