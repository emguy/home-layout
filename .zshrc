#!/usr/bin/env zsh
if [ -f '/etc/zshrc' ]; then
  source /etc/zshrc
fi

export PATH="/opt/homebrew/bin:$PATH:$HOME/go/bin"

#if [ -f '/etc/zshrc_Apple_Terminal' ]; then
#  source /etc/zshrc_Apple_Terminal
#fi

# Shell is non-interactive.  Be done now!
if [[ $- != *i* ]] ; then
  return
fi

# set LS_COLORS
if [ -f "$HOME/.dir_colors" ]; then
  eval "$(gdircolors -b $HOME/.dir_colors)"
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
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
export HISTSIZE=200000
export SAVEHIST=200000
export HISTFILE="$HOME/.zsh_history"

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
export MANPATH="$HOME/.local/share/man:$MANPATH"

export KUBE_EDITOR="nvim"
export DOCKER_CONFIG="$HOME/.docker"

export MANPAGER="/usr/bin/less -R --use-color -Ddc -Du+y"

#export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"

## use gnu binaries
export HOMEBREW_PREFIX="$(brew --prefix)"
alias ls='$HOMEBREW_PREFIX/bin/gls --color'
alias cp='$HOMEBREW_PREFIX/bin/gcp'
alias cdr='cd "$(git rev-parse --show-toplevel)"'
alias rm='$HOMEBREW_PREFIX/bin/grm'
alias sed='$HOMEBREW_PREFIX/bin/gsed'
alias find='$HOMEBREW_PREFIX/bin/gfind'
alias awk='$HOMEBREW_PREFIX/bin/gawk'
alias tar='$HOMEBREW_PREFIX/bin/gtar'
alias grep='$HOMEBREW_PREFIX/bin/ggrep --color'
alias G="lazygit"

alias vm="ssh -p 2222 emguy@localhost"

alias df="df -h"
alias du="du -h"

alias less="less -r"

alias dic="sdcv"
alias iconv="iconv -f gb18030"

alias gcc="gcc -march=native -pipe -O2"
alias g++="g++ -std=c++11 -march=native -pipe -O2"


alias vim="nvim"
alias vi="nvim"
alias rg="rg --no-ignore --no-ignore-dot"
alias nvimrc="nvim $XDG_CONFIG_HOME/nvim/init.lua"
alias argbash="docker run -v \$(pwd):/work --rm argbash"
alias argbash-init="docker run -v \$(pwd):/work --rm -e PROGRAM=argbash-init argbash"

if [ -x "$(command -v kubectl)" ]; then
  # shellcheck source=/dev/null
  source <(kubectl completion zsh)
fi

if [ -f "$HOME/.bellshell.sh" ]; then
  # shellcheck source=./.bellshell.sh
  source "$HOME/.bellshell.sh"
fi

if [ -f "$HOME/.awsshell.sh" ]; then
  # shellcheck source=./.awsshell.sh
  source "$HOME/.awsshell.sh"
fi

if [ -f "$HOME/.shell_utils.sh" ]; then
  # shellcheck source=./.shell_utils.sh
  source "$HOME/.shell_utils.sh"
fi

#[ -z "$TMUX" ] && { tmux attach &> /dev/null || exec tmux new-session -s main && exit;}

if [ -d "$HOME/conTeXt" ]; then
  export PATH=/home/emguy/conTeXt/tex/texmf-linux-64/bin:$PATH
fi

#source  $HOME/venv/bin/activate

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export PATH="$JAVA_HOME/bin:$HOMEBREW_PREFIX/bin:$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:/opt/homebrew/bin:$HOME/.local/ConTeXt/tex/texmf-linux-64/bin:/opt/node/bin:$NPM_PACKAGES/bin:/Applications/Docker.app/Contents/Resources/bin:$PATH"


# enable aws auto-completion
complete -C /opt/homebrew/bin/aws_completer aws
