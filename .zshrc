#!/usr/bin/env zsh

if [ -f '/etc/zshrc' ]; then
  source /etc/zshrc
fi

if [ -f '/etc/zshrc_Apple_Terminal' ]; then
  source /etc/zshrc_Apple_Terminal
fi

# Shell is non-interactive.  Be done now!
if [[ $- != *i* ]] ; then
  return
fi

bindkey ^v forward-word
bindkey ^y backward-word
bindkey ^u backward-kill-line

# zsh prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b) '
setopt PROMPT_SUBST
PROMPT='%F{226}%n@zsh%f %F{69}%~%f %F{112}${vcs_info_msg_0_}%f%F{69}$%f '

# zsh history configurations
setopt HIST_FIND_NO_DUPS # skip duplicated commmand
setopt HIST_IGNORE_DUPS
export HISTFILE="~/.zsh_history"
export HISTSIZE=5000000 # HISTSIZE is the number of cached commands
export HISTFILESIZE=5000000 # how many commands can be stored in the . bash_history file
#setopt EXTENDED_HISTORY # records the timestamp in HISTFILE
#export HISTTIMEFORMAT="[%F %T]"

# auto-completion
autoload -Uz compinit && compinit

export TERM="xterm-256color"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export CFLAGS="-march=native -pipe -O2"
export LDFLAGS="-L/home/emguy/.local/lib/"
export CXXFLAGS="${CFLAGS}"
export LESSCOLOR="yes"

export XDG_CONFIG_HOME="$HOME/.config" # lazygit

export NPM_PACKAGES="$HOME/.npm-global"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:/opt/homebrew/bin:$HOME/.local/ConTeXt/tex/texmf-linux-64/bin:/opt/node/bin:$NPM_PACKAGES/bin:/Applications/Docker.app/Contents/Resources/bin:$PATH"
export MANPATH="$HOME/.local/share/man:$MANPATH"

export KUBE_EDITOR="nvim"
export DOCKER_CONFIG="$HOME/.docker"

## use gnu binaries
BREW_PREFIX="$(brew --prefix)"
alias ls='$BREW_PREFIX/bin/gls --color'
alias cp='$BREW_PREFIX/bin/gcp'
alias rm='$BREW_PREFIX/bin/grm'
alias sed='$BREW_PREFIX/bin/gsed'
alias find='$BREW_PREFIX/bin/gfind'
alias awk='$BREW_PREFIX/bin/gawk'
alias tar='$BREW_PREFIX/bin/gtar'
alias grep='$BREW_PREFIX/bin/ggrep --color'

alias df="df -h"
alias du="du -h"

alias less="less -r"

alias dic="sdcv"
alias iconv="iconv -f gb18030"

alias gcc="gcc -march=native -pipe -O2"
alias g++="g++ -std=c++11 -march=native -pipe -O2"


alias vim="nvim"
alias vi="nvim"
alias argbash="docker run -v \$(pwd):/work --rm argbash"
alias argbash-init="docker run -v \$(pwd):/work --rm -e PROGRAM=argbash-init argbash"

if [ -x "$(command -v kubectl)" ]; then
  # shellcheck source=/dev/null
  source <(kubectl completion zsh)
fi

if [ -f "$HOME/.bellshell.sh" ]; then
  # shellcheck source=./.babellshell.sh
  source "$HOME/.bellshell.sh"
fi

#[ -z "$TMUX" ] && { tmux attach &> /dev/null || exec tmux new-session -s main && exit;}

if [ -d "$HOME/conTeXt" ]; then
  export PATH=/home/emguy/conTeXt/tex/texmf-linux-64/bin:$PATH
fi

#source  $HOME/venv/bin/activate

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
