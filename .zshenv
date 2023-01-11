# Choose which env we are running in
[ "$(uname -s)" = "Darwin" ] && export MACOS=1
[ "$(uname -s)" = "Linux" ] && export LINUX=1 

# NVM directory
export NVM_DIR="$HOME/.nvm"
