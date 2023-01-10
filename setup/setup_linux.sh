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
  curl -fsSL http://download.docker.com/linux/ubuntu/gpg | sudo -H apt-key add -
  sudo -H add-apt-repository \
  "deb [arch=amd64] http://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
  sudo -H apt update
  sudo -H apt install docker-ce -y
  sudo -H apt install docker-ce-cli -y
  sudo -H apt install containerd.io -y
  # So we don't have to run as sudo
  sudo -H groupadd docker
  sudo usermod -aG docker ${USER}
  newgrp docker 


  echo "Installing docker-compose Ubuntu"
  if [[ ! -f ${HOME}/software_downloads/docker-compose_${DOCKER_COMPOSE_VER} ]]; then
    wget -O ${HOME}/software_downloads/docker-compose_${DOCKER_COMPOSE_VER} ${DOCKER_COMPOSE_URL}
    sudo cp -a ${HOME}/software_downloads/docker-compose_${DOCKER_COMPOSE_VER} /usr/local/bin/
    sudo mv /usr/local/bin/docker-compose_${DOCKER_COMPOSE_VER} /usr/local/bin/docker-compose
    sudo chmod 755 /usr/local/bin/docker-compose
    sudo chown root:root /usr/local/bin/docker-compose
  fi

  sudo -H apt autoremove -y
fi

echo "Setting ZSH as shell..."
if [[ ! ${SHELL} = "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

echo "Installing Oh My ZSH..."
if [[ ! -d ${HOME}/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

###
# dotfile configuration
###

echo "Linking ${DOTFILES} to their home"
if [[ -f ${HOME}/.gitconfig ]]; then
  rm ${HOME}/.gitconfig
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
elif [[ ! -L ${HOME}/.gitconfig ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
fi

if [[ -f ${HOME}/.zshrc ]]; then
  rm ${HOME}/.zshrc
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
elif [[ ! -L ${HOME}/.zshrc ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
fi

if [[ ! -d ${HOME}/.config ]]; then
  mkdir -p ${HOME}/.config
fi


