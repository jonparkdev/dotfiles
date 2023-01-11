# Load Homebrew
if [[ MACOS ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ LINUX ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi