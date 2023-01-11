#!/usr/bin/bash

# Install homebrew for both MAC and Linux
if ! [ -x "$(command -v brew)" ]; then
  echo "Installing homebrew..."
  if [[ ${MACOS} ]]; then
    xcode-select --install
    # Accept Xcode license
    sudo xcodebuild -license accept
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  source .zshrc
fi

# Install NPM
echo "Install nvm for node environments and set default to lts"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source .zshrc
nvm install lts/*
nvm alias default lts/*

###
# Configure system directories and link dotfiles
###
echo "Creating Directory to store software downloads"
if ! [[ -d ${HOME}/software_downloads ]]; then
  mkdir ${HOME}/software_downloads
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

echo "ZSH configuration"
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





 