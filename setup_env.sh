#!/usr/bin/env bash

# Directory locations
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

# function be called if incorrect use of STDIN
usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[[ $# -eq 0 ]] && usage

# Command line options
# setup: run a full machine and developer setup
while getopts ":ht:w" arg; do
  case ${arg} in
    t) 
      [[ ${OPTARG} = "setup" ]] && export SETUP=1
      [[ ${OPTARG} = "update" ]] && export UPDATE=1
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
  [[ ${LINUX_TYPE} = "Ubuntu" ]] && export UBUNTU=1
fi

if [[ ${UBUNTU} ]]; then
  UBUNTU_VERSION=$(lsb_release -rs)
  [[ ${UBUNTU_VERSION} = "18.04" ]] && export BIONIC=1
  [[ ${UBUNTU_VERSION} = "20.04" ]] && export FOCAL=1
  [[ ${UBUNTU_VERSION} = "22.04" ]] && export JAMMY=1
  [[ ${UBUNTU_VERSION} = "6" ]] && export FOCAL=1 # elementary os
fi

# Set virtualenv path to variable
if [[ ${LINUX} ]]; then
  if [[ -f ${HOME}/.local/bin/virtualenv ]]; then
    VIRTUALENV_LOC="${HOME}/.local/bin"
  elif [[ -f "/usr/local/bin/virtualenv" ]]; then
    VIRTUALENV_LOC="/usr/local/bin"
  fi
  VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
fi

# Install Rosetta for new M1 silicone
if [[ ${MACOS} ]]; then
  echo "Installing Rosetta if necessary"
  install_rosetta
fi

# Directory to store software downloads
if ! [[ -d ${HOME}/software_downloads ]]; then
  mkdir ${HOME}/software_downloads
fi

### 
# Begin setup of base system
###
if [[ ${UBUNTU} ]]; then
  if [[ ${FOCAL} ]]; then
    sudo -H apt install --install-recommends linux-generic-hwe-20.04 -y
  elif [[ ${JAMMY} ]]; then
    sudo -H apt install --install-recommends linux-generic-hwe-22.04 -y
  fi

  xargs -a ./ubuntu_common_packages.txt sudo apt install -y
fi

# Install homebrew for Linux and Mac
if [[ ${MACOS} || ${LINUX} ]]; then
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing homebrew..."
    if [[ ${MACOS} ]]; then
      xcode-select --install
      # Accept Xcode license
      sudo xcodebuild -license accept
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

echo "Installing git"
if [[ ${MACOS} ]]; then
  brew install git
fi

if [[ ${UBUNTU} ]]; then
  sudo -H add-apt-repository ppa:git-core/ppa -y
  sudo -H apt update
  sudo -H apt dist-upgrade -y
  sudo -H apt install git -y
fi

echo "Installing zsh"
if [[ ${MACOS} ]]; then
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew install zsh
fi

if [[ ${UBUNTU} ]]; then
  sudo -H apt update
  sudo -H apt install zsh -y
  sudo -H apt install zsh-doc -y
fi

echo "Setting ZSH as shell..."
if [[ ! ${SHELL} = "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

echo "Installing Oh My ZSH..."
if [[ ! -d ${HOME}/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Configure system directories and link dotfiles
echo "Creating home bin"
if [[ ! -d ${HOME}/bin ]]; then
  mkdir ${HOME}/bin
fi

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

echo "Linking ${DOTFILES} to their home"
if [[ ${ MACOS } ]]; then
  if [[ -f ${HOME}/.gitconfig ]]; then
    rm ${HOME}/.gitconfig
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
  elif [[ ! -L ${HOME}/.gitconfig ]]; then
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
  fi
fi

if [[ ${LINUX} ]]; then
  if [[ -f ${HOME}/.gitconfig ]]; then
    rm ${HOME}/.gitconfig
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
  elif [[ ! -L ${HOME}/.gitconfig ]]; then
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_linux ${HOME}/.gitconfig
  fi
fi

if [[ -f ${HOME}/.zshrc ]]; then
  rm ${HOME}/.zshrc
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
elif [[ ! -L ${HOME}/.zshrc ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.zshrc ${HOME}/.zshrc
fi

if [[ ${MACOS} || ${LINUX} ]]; then
  if [[ ! -d ${HOME}/.config ]]; then
    mkdir -p ${HOME}/.config
  fi
fi

###
# Install packages necessary for development
###
echo "Install nvm for node environments and set default to lts"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source .zshrc
nvm install lts/*
nvm alias default lts/*

echo "Install yarn"
npm install --global yarn
sudo npm install -g yarn

if [[ ${UBUNTU} ]]; then
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

if [[ ${MACOS} ]]; then
  echo "Creating $BREWFILE_LOC"
  if [[ ! -d ${BREWFILE_LOC} ]]; then
    mkdir ${BREWFILE_LOC}
  fi

  if [[ ! -L ${BREWFILE_LOC}/Brewfile ]]; then
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/Brewfile $BREWFILE_LOC/Brewfile
  else
    rm $BREWFILE_LOC/Brewfile
    ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/Brewfile $BREWFILE_LOC/Brewfile
  fi

  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  echo "Updating homebrew..."
  brew update
  echo "Upgrading brew's"
  brew upgrade
  echo "Upgrading brew casks"
  brew upgrade --cask

  echo "Installing other brew stuff..."

  #https://github.com/Homebrew/homebrew-bundle
  brew tap homebrew/bundle
  brew tap homebrew/cask
  cd ${BREWFILE_LOC} && brew bundle
  brew tap teamookla/speedtest
  brew install speedtest
  brew install --cask chef/chef/inspec
  brew install --cask dotnet
  brew install go-task/tap/go-task
  brew tap snyk/tap
  brew install snyk
  brew tap cloudflare/cloudflare
  brew install --cask cloudflare/cloudflare/cf-terraforming
  brew install --cask miro

  cd ${PERSONAL_GITREPOS}/${DOTFILES} || return

  if [[ ! -d "/Applications/Docker.app" ]]; then
    brew install --cask docker
  fi
  if [[ ! -d "/Applications/Firefox.app" ]]; then
    brew install --cask firefox
  fi
  if [[ ! -d "/Applications/Google\ Chrome.app" ]]; then
    brew install --cask google-chrome
  fi
  if [[ ! -d "/Applications/Postman.app" ]]; then
    brew install --cask postman
  fi
  if [[ ! -d "/Applications/Slack.app" ]]; then
    brew install --cask slack
  fi
  if [[ ! -d "/Applications/VirtualBox.app" ]]; then
    brew install --cask virtualbox
  fi
  if [[ ! -d "/Applications/Vagrant.app" ]]; then
    brew install --cask vagrant
  fi
  if [[ ! -d "/Applications/Visual\ Studio\ Code.app" ]]; then
    brew install --cask visual-studio-code
  fi
  if [[ ! -d "/Applications/VLC.app" ]]; then
    brew install --cask vlc
  fi
  if [[ ! -d "/Applications/zoom.us.app" ]]; then
    brew install --cask zoom
  fi

  echo "Cleaning up brew"
  brew cleanup
fi

###
# update is run more often to keep the device up to date with patches
###
if [[ ${UPDATE} ]]; then
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
fi

exit 0