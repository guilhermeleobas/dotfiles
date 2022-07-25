
source ${HOME}/.zgen/zgen.zsh
if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh themes/steeef
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions
  # zgen load denysdovhan/spaceship-prompt spaceship
  zgen save
fi

# execute immediately
unsetopt HIST_VERIFY

alias vim="nvim"

export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

alias ccat="pygmentize -f terminal256 -O style=monokai -g"

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# reset terminal
alias reset_term="tput reset"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ${HOME}/git/dotfiles/scripts.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/guilhermeleobas/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/guilhermeleobas/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/guilhermeleobas/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/guilhermeleobas/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE="/home/guilhermeleobas/bin/micromamba";
export MAMBA_ROOT_PREFIX="/home/guilhermeleobas/micromamba";
__mamba_setup="$('/home/guilhermeleobas/bin/micromamba' shell hook --shell zsh --prefix '/home/guilhermeleobas/micromamba' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    if [ -f "/home/guilhermeleobas/micromamba/etc/profile.d/micromamba.sh" ]; then
        . "/home/guilhermeleobas/micromamba/etc/profile.d/micromamba.sh"
    else
        export  PATH="/home/guilhermeleobas/micromamba/bin:$PATH"  # extra space after export prevents interference from conda init
    fi
fi
unset __mamba_setup
# <<< mamba initialize <<<
