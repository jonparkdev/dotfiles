#!/usr/bin/env bash

### REQUIRED for setup ###
. "$DIR/setup_general.sh"

###
# Install necessary packages for configuration
###
# Install Rosetta for new M1 silicone
echo "Installing Rosetta if necessary"
install_rosetta

echo "Installing git"
brew install git

echo "Installing zsh"
brew install zsh

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
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
elif [[ ! -L ${HOME}/.gitconfig ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
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

if [[ ! -d ${HOME}/.config ]]; then
  mkdir -p ${HOME}/.config
fi

echo "starship profile"
if [[ -f ${HOME}/.config/starship.toml ]]; then
  rm ${HOME}/.config/starship.toml
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/starship.toml ${HOME}/.config/starship.toml
elif [[ ! -L ${HOME}/.config/starship.toml ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/starship.toml ${HOME}/.config/starship.toml
fi

###
# Install packages using Homebrew
###
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

brew install --cask miro

cd ${PERSONAL_GITREPOS}/${DOTFILES} || return

if [[ ! -d "/Applications/Miro.app" ]]; then
  brew install --cask miro
fi
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