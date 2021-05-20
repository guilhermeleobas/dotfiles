
source ${HOME}/.zgen/zgen.zsh
if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh themes/steeef
  zgen load zsh-users/zsh-syntax-highlighting
  # zgen load zsh-users/zsh-autosuggestions
  # zgen load denysdovhan/spaceship-prompt spaceship
  zgen save
fi

# execute immediately
unsetopt HIST_VERIFY

alias vim="nvim"

export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

#
# Defines transfer alias and provides easy command line file and folder sharing.
#
# Authors:
#   Remco Verhoef <remco@dutchcoders.io>
#

curl --version 2>&1 > /dev/null
if [ $? -ne 0 ]; then
  echo "Could not find curl."
  return 1
fi

alias ccat="pygmentize -f terminal256 -O style=monokai -g"

source ~/goto.sh

alias conn_qgpu3='ssh -L 6274:localhost:6227 -L 6275:localhost:6275 -p 22 -i ~/Dropbox/ssh/omnisci guilhermel@gpu.quansight.dev'
alias conn_qgpu2='ssh -L 6274:localhost:6227 -L 6275:localhost:6275 -p 2222 -i ~/Dropbox/ssh/omnisci guilhermel@gpu.quansight.dev'
alias conn_qgpu1='ssh -l 6274:localhost:6227 -L 6275:localhost:6275 -p 2221 -i ~/Dropbox/ssh/omnisci guilhermel@gpu.quansight.dev'

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# reset terminal
alias reset_term="tput reset"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ${HOME}/gdrive/dotfiles/scripts.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/guilhermeleobas/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/guilhermeleobas/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/guilhermeleobas/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/guilhermeleobas/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

