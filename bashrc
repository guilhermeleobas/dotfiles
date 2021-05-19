# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
# case $- in
#    *i*) ;;
#      *) return;;
# esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Use 'skeswa/prompt' which is symlinked to '~/.prompt'.
. ~/.prompt/prompt.bash

# Add git completion to the prompt (comes from 'skeswa/prompt').
. ~/.prompt/git-completion.bash


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export MAMBA_NO_BANNER=1


omnisci-conda-run(){
  echo "running omniscidb..."
  rm -rf data
  mkdir data
  mamba run -n omniscidb-env omnisci_initdb data -f
  mamba run -n omniscidb-env omnisci_server --version
  mamba run -n omniscidb-env omnisci_server --enable-runtime-udf --enable-table-functions
}

omnisci-conda-install(){
  conda deactivate
  conda activate default
  conda remove --name omniscidb-env --all -y
  mamba create -n omniscidb-env omniscidb=5.5*=*_cpu -c conda-forge -y
}

pytorch() {

  export USE_CUDA=0
  export USE_DISTRIBUTED=0
  export USE_MKLDNN=0
  export USE_FBGEMM=0
  export USE_NNPACK=0
  export USE_QNNPACK=0
  export USE_XNNPACK=0
  export USE_NCCL=0
  export MAX_JOBS=24

  . ~/git/Quansight/pearu-sandbox/working-envs/activate-pytorch-dev.sh

  # Enable ccache
  # export CCACHE_COMPRESS=true
  # export CMAKE_C_COMPILER_LAUNCHER=ccache
  # export CMAKE_CXX_COMPILER_LAUNCHER=ccache
  # export CMAKE_CUDA_COMPILER_LAUNCHER=ccache

  export LD=$(which lld)
}

pytorch-update(){
  git submodule sync
  git submodule update --init --recursive
}

pytorch-pyi(){
  python -m tools.pyi.gen_pyi
}

clone() {
  case $1 in
    rbc)
      echo "cloning rbc..."
      git clone git@github.com:guilhermeleobas/rbc.git ${HOME}/git
      ;;

    numba)
      echo "cloning numba..."
      git clone git@github.com:guilhermeleobas/numba.git ${HOME}/git
      ;;

    omniscidb)
      echo "cloning omniscidb..."
      git clone git@github.com:omnisci/omniscidb-internal.git ${HOME}/git
      ;;
    
    sandbox)
      echo "cloning sandbox..."
      git clone git@github.com:Quansight/pearu-sandbox.git ${HOME}/Quansight/
      ;;

    *)
      echo -n "unknown"
      ;;
  esac
}

env() {
  case $1 in
    rbc)
      echo "activating env: rbc"
      conda deactivate
      conda activate rbc
      ;;

    numba)
      echo "activating env: numba"
      conda deactivate
      conda activate numba
      ;;

    nocuda)
      echo "activating env: omniscidb nocuda"
      export USE_ENV=omniscidb-cpu-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
      ;;

    cuda)
      echo "activating env: omniscidb nocuda"
      export USE_ENV=omniscidb-cuda-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
      ;;
    
    *)
      echo -n "env: unknown"
      ;;
  esac
}

build() {
  echo $1
  case $1 in
    nocuda)
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DENABLE_TESTS=on \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
        ${HOME}/git/omniscidb-internal/
      ;;

    cuda)
        cmake -Wno-dev $CMAKE_OPTIONS_CUDA \
          -DCMAKE_BUILD_TYPE=Debug \
          -DENABLE_TESTS=on \
          -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
          ~/git/omniscidb-internal/
      ;;
    
    *)
      echo -n "cmake: unknown $1"
      ;;
  esac
}

recreate() {
  case $1 in
    rbc)
      echo "recreate env: rbc..."
      conda deactivate
      conda activate default
      conda remove --name rbc --all -y
      mamba env create --file=${HOME}/git/rbc/.conda/environment.yml -n rbc
      env rbc
      ;;

    numba)
      echo "recreate env: numba..."
      echo "missing definitions"
      ;;

    nocuda)
      echo "recreate env: nocuda..."
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      nocuda-env
      env nocuda
      ;;

    cuda)
      echo "activating env: omniscidb nocuda"
      conda deactivate
      conda activate default
      conda remove --name omniscidb-gpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      env cuda
      ;;
    
    *)
      echo -n "env: unknown"
      ;;
  esac
}

register_goto() {
  goto -r pytorch ~/git/Quansight/pytorch
  goto -r rbc ~/git/rbc
  goto -r omnisci ~/git/omniscidb-internal
  goto -r build-nocuda ~/git/build-nocuda
  goto -r build-cuda ~/git/build-cuda
  goto -r numba ~/git/numba
}

source ~/goto/goto.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate default

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
