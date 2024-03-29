# Choose which env we are running in
[ "$(uname -s)" = "Darwin" ] && export MACOS=1
[ "$(uname -s)" = "Linux" ] && export LINUX=1 

[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh
[[ -f ~/.zsh/homebrew.zsh ]] && source ~/.zsh/homebrew.zsh
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh
[[ -f ~/.zsh/keychain.zsh ]] && source ~/.zsh/keychain.zsh
[[ -f ~/.zsh/nvm.zsh ]] && source ~/.zsh/nvm.zsh

# Load Starship
eval "$(starship init zsh)"

# Load Direnv
eval "$(direnv hook zsh)"