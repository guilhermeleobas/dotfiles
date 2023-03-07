
source ${HOME}/.zgen/zgen.zsh
if ! zgen saved; then
  zgen oh-my-zsh
  # if [[ $(hostname) =~ "server" ]]; then
  #   zgen oh-my-zsh themes/awesomepanda
  # else
  #   zgen oh-my-zsh themes/steeef
  # fi
  zgen oh-my-zsh themes/steeef
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions
  # zgen load denysdovhan/spaceship-prompt spaceship
  zgen save
fi

if [[ $(hostname) =~ "MacBook-Pro" ]]; then
PROMPT=$'
%{$purple%}%n${PR_RST} at %{$limegreen%}%m${PR_RST} in %{$limegreen%}%~${PR_RST} $vcs_info_msg_0_$(virtualenv_info)
$ '
fi


# execute immediately
unsetopt HIST_VERIFY

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# reset terminal
alias reset_term="tput reset"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ${HOME}/git/dotfiles/scripts.sh

# export PATH="${HOME}/git/dotfiles:$PATH"

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

