#!/usr/bin/env bash

# Install Rosetta for new M1 silicone
echo "Installing Rosetta if necessary"
install_rosetta

# Install homebrew for MAC
if ! [ -x "$(command -v brew)" ]; then
  echo "Installing homebrew..."
  xcode-select --install
  # Accept Xcode license
  sudo xcodebuild -license accept
fi

echo "Installing git"
brew install git

echo "Installing zsh"
brew install zsh

echo "Setting ZSH as shell..."
if [[ ! ${SHELL} = "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

echo "Install nvm for node environments and set default to lts"
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"


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
elif [[ ! -L ${HOME}/.zshrc ]]; then
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

echo ".gitconfig"
if [[ -f ${HOME}/.gitconfig ]]; then
  rm ${HOME}/.gitconfig
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
elif [[ ! -L ${HOME}/.gitconfig ]]; then
  ln -s ${PERSONAL_GITREPOS}/${DOTFILES}/.gitconfig_mac ${HOME}/.gitconfig
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