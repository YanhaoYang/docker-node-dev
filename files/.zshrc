export ZSH=/home/node/.oh-my-zsh

ZSH_THEME="fishy"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions alias-tips)

source $ZSH/oh-my-zsh.sh

bindkey -v

export LANG=en_US.UTF-8
export EDITOR='vim'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
