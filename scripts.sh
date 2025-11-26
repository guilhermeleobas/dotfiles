PREFIX=${HOME}/git

[[ -n $CONDA_EXE ]] || CONDA_EXE=micromamba
[[ -n $VAST_CONTAINERLABEL ]] && PREFIX=/workspace/git

reload() {
  exec ${SHELL}
}

vast() {
  echo "source /workspace/git/dotfiles/scripts.sh" >> ~/.bashrc
  install vim-plug
  cp $PREFIX/dotfiles/nvim ~/.vimrc
  cp $PREFIX/dotfiles/tmux.conf ~/.tmux.conf
  vim +PlugInstall +qa
  git config --global user.name "Guilherme Leobas"
  git config --global user.email "guilhermeleobas@gmail.com"
}

clone() {
  case $1 in
    dotfiles|numba|numba-rvsdg)
      echo "cloning $1..."
      git clone git@github.com:guilhermeleobas/$1.git ${PREFIX}/$1/
      ;;

    llvmlite)
      echo "cloning $1..."
      git clone git@github.com:numba/$1.git ${PREFIX}/$1
      ;;

    numpy)
      echo "cloning numpy..."
      git clone git@github.com:numpy/numpy.git ${PREFIX}/numpy
      ;;

    flash-attention)
      echo "cloning $1..."
      git clone git@github.com:guilhermeleobas/$1.git ${PREFIX}/$1
      env --chdir={PREFIX}/$1 git remote add upstream git@github.com:Dao-AILab/flash-attention.git
      ;;

    pytorch|tutorials|vision|audio)
      echo "cloning $1..."
      git clone git@github.com:pytorch/$1.git ${PREFIX}/$1
      env --chdir=${PREFIX}/$1 git remote add upstream git@github.com:pytorch/$1.git
      ;;

    pytorch310|pytorch311|pytorch312|pytorch313|pytorch314|pytorch314t)
      echo "cloning $1..."
      git clone git@github.com:pytorch/pytorch.git --single-branch ${PREFIX}/$1
      ;;

    cpython)
      echo "cloning cpython..."
      git clone git@github.com:guilhermeleobas/cpython.git ${PREFIX}/cpython
      ;;

    sandbox)
      echo "cloning sandbox..."
      git clone git@github.com:Quansight/pearu-sandbox.git ${PREFIX}/Quansight/pearu-sandbox
      ;;

    *)
      echo -n "clone(): unknown $1"
      ;;
  esac
}

install() {
  case $1 in
    micromamba)
      "${SHELL}" <(curl -L micro.mamba.pm/install.sh)
      ;;

    vim-plug)
      curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      ;;

    nvim-plug)
      sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      ;;

    fzf)
      git clone git@github.com:junegunn/fzf.git ~/.fzf
      ~/.fzf/install
      ;;

    goto)
      git clone git@github.com:iridakos/goto.git ${PREFIX}/goto
      source ${PREFIX}/goto/goto.sh
      reload_goto
      ;;

    miniconda)
      bash <(curl -L conda.sh)
      ;;

    tpm)
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      ;;

    pixi)
      $CONDA_EXE install -c conda-forge pixi
      ;;

    ag)
      $CONDA_EXE install -c conda-forge the_silver_searcher
      ;;

    gh)
      $CONDA_EXE install -c conda-forge gh
      ;;

    theme)
      git clone git@github.com:guilhermeleobas/prompt.git ${PREFIX}/prompt
      make -C ${PREFIX}/prompt install
      ;;

    zgen)
      git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
      ;;

    *)
      echo -n "install: unknown $1"
      ;;
  esac
}

find_env() {
  environment=""
  local d=$(basename $(pwd))
  case ${d} in
    llvm-project)
      environment=llvm
      ;;
    *)
      # use the folder name as conda environment name
      environment=$d
      ;;
  esac
}

env() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case ${environment} in
    numba)
      $CONDA_EXE deactivate
      $CONDA_EXE activate numba
      export NUMBA_CAPTURED_ERRORS="new_style"
      ;;

    flash-attention)
      export FLASH_ATTENTION_DISABLE_BACKWARD=FALSE
      export FLASH_ATTENTION_DISABLE_SPLIT=TRUE
      export FLASH_ATTENTION_DISABLE_SOFTCAP=TRUE
      export FLASH_ATTENTION_DISABLE_LOCAL=TRUE
      export FLASH_ATTENTION_DISABLE_CLUSTER=TRUE
      export FLASH_ATTENTION_DISABLE_VARLEN=TRUE
      export FLASH_ATTENTION_DISABLE_PACKGQA=TRUE
      export FLASH_ATTENTION_DISABLE_PAGEDKV=TRUE
      export FLASH_ATTENTION_DISABLE_APPENDKV=TRUE
      export FLASH_ATTENTION_DISABLE_FP8=TRUE
      export FLASH_ATTENTION_DISABLE_FP16=FALSE
      export FLASH_ATTENTION_DISABLE_FP32=TRUE
      export FLASH_ATTENTION_DISABLE_HDIM96=FALSE
      export FLASH_ATTENTION_DISABLE_HDIM128=FALSE
      export FLASH_ATTENTION_DISABLE_HDIM192=FALSE
      export FLASH_ATTENTION_DISABLE_HDIM256=FALSE
      # export CUDA_HOME=/usr/local/cuda

      $CONDA_EXE activate flash-attention
      ;;

    pytorch|pytorch310|pytorch311|pytorch312|pytorch313|pytorch314|pytorch314t|pytorch-cuda)
      echo "activating env: ${environment}"

      export PYTHONBREAKPOINT=pdbp.set_trace

      # remember to create a symlink from /usr/lib/cuda to /usr/local/cuda
      # sudo ln -s /usr/lib/cuda /usr/local/cuda
      export USE_CUDA=$([ "${environment}" = "pytorch-cuda" ] && echo 1 || echo 0)
      export USE_GOLD=1
      export USE_KINETO=0
      export BUILD_CAFFE2=0
      export USE_XNNPACK=0
      export USE_QNNPACK=0
      export USE_MIOPEN=0
      export USE_NNPACK=0
      export USE_MKLDNN=0
      export BUILD_TEST=0
      export BUILD_CAFFE2_OPS=0
      export CUDA_HOME=/usr/local/cuda
      export CMAKE_BUILD_TYPE=RelWithDebInfo
      export MAX_JOBS=20
      export USE_DISTRIBUTED=1
      export USE_NCCL=0
      export USE_CUDNN=0
      export CC=cc
      export CXX=c++
      export CFLAGS="${CFLAGS} -L${CONDA_PREFIX}/lib"
      export CFLAGS="${CFLAGS} ${CFLAGS_DBG}"
      export CXXFLAGS="${CXXFLAGS} -L${CONDA_PREFIX}/lib"
      export CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS"
      export CXXFLAGS="${CXXFLAGS} ${CXXFLAGS_DBG}"
      export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${CUDA_HOME}/lib64"
      export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${CUDA_HOME}/extras/CUPTI/lib64"
      export LDFLAGS="${LDFLAGS} -L${CUDA_HOME}/lib64"
      $CONDA_EXE activate ${environment}
      ;;

    vision|audio)
      export Torch_DIR="${PREFIX}/pytorch"
      $CONDA_EXE activate pytorch
      ;;

    *)
      echo "activating env: ${environment}"
      $CONDA_EXE deactivate
      $CONDA_EXE activate ${environment}

      if [[ $? -ne 0 ]]; then
        echo "activating default env..."
        $CONDA_EXE activate ${CONDA_DEFAULT_ENV}
      fi

      ;;
  esac
}

pytorch-update(){
  git submodule sync
  git submodule update --init --recursive
}

build() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    llvm)
      env llvm
      cd ${PREFIX}/llvm-project/build
      cmake ../llvm/ \
        -DCMAKE_INSTALL_PREFIX="${CONDA_PREFIX}" \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt" \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_CCACHE_BUILD=ON \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INSTALL_UTILS=OFF \
        -DLLVM_UTILS_INSTALL_DIR=libexec/llvm \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DHAVE_LIBEDIT=OFF
      ;;

    cpython)
      env cpython
      ./configure --with-pydebug --with-openssl=$CONDA_PREFIX --with-ensurepip=install --prefix=$CONDA_PREFIX
      make -s -j10
      ;;

    numba)
      env numba
      echo "python setup.py build_ext --inplace -j10"
      if [[ $(uname -s) =~ "Darwin" ]]; then
        export NUMBA_DISABLE_OPENMP=1
      fi
      python setup.py build_ext --inplace -j10
      ;;

    llvmlite)
      env llvmlite
      python setup.py build
      ;;

    numpy)
      env numpy
      spin build
      # python setup.py build_ext --inplace -j10
      ;;

    flash-attention)
      env flash-attention
      python setup.py install
      ;;

    pytorch|pytorch310|pytorch311|pytorch312|pytorch313|pytorch314|pytorch314t|pytorch-cuda|vision|audio)
      env ${environment}
      python setup.py develop
      if [ "${environment}" = "pytorch-cuda" ]; then
        make triton
      fi

      ;;

    *)
      echo -n "build: unknown $1"
      ;;
  esac
}

remove() {
  conda deactivate
  conda activate base
  find_env
  conda remove --name ${environment} --all -y
}

create() {
  $CONDA_EXE deactivate
  if [[ $(hostname) =~ qgpu ]]; then
    $CONDA_EXE activate default
  else
    $CONDA_EXE activate base
  fi

  local flag=""

  if [[ $# -eq 0 ]]; then
    find_env
  else
    case "$1" in
      --name | -n)
        flag=$1
        environment=$2
        ;;

      *)
        environment=$1
        ;;

    esac
  fi

  echo "create env: ${environment}..."
  $CONDA_EXE remove --name ${environment} --all -y

  case $environment in
    numba)
      $CONDA_EXE create -n numba python=3.11 llvmlite=0.46 pdbpp flake8 numpy cffi pytest -c numba/label/dev -c rapidsai
      ;;

    numpy)
      $CONDA_EXE create --file=${PREFIX}/numpy/environment.yml -n numpy
      ;;

    llvmlite)
      $CONDA_EXE create -n llvmlite
      $CONDA_EXE install -n llvmlite python=3.9 compilers cmake make llvmdev=14 -c numba -c conda-forge -y
      ;;

    llvm)
      $CONDA_EXE create -n llvm cmake ccache compilers make -c conda-forge -y
      ;;

    flash-attention)
      $CONDA_EXE create -n flash-attention python=3.12 -c conda-forge -y
      env flash-attention
      pip install torch packaging transformers accelerate
      ;;

    pytorch|pytorch310|pytorch311|pytorch312|pytorch313|pytorch314|pytorch314t|pytorch-cuda)
      $CONDA_EXE env create --file=${PREFIX}/dotfiles/conda-envs/$environment-dev.yaml -n $environment -y
      ;;

    cpython)
      $CONDA_EXE create --file=${PREFIX}/dotfiles/conda-envs/cpython.yaml -n cpython -y
      ;;

    *)
      case "$flag" in
        -n | --name)
          $CONDA_EXE create --name ${environment}
          ;;

        *)
          echo -n "env: unknown ${environment}"
          ;;
      esac

      ;;
  esac

  if [[ $? -eq 0 ]]; then
    env ${environment}
  fi

}

abort() {
  git rebase --abort
  git log -1 --oneline
}

rebase() {
  git rebase -i HEAD~"$1"
}

show() {
  if [[ $# -eq 0 ]]; then
    unset TORCH_LOGS
  else
    export TORCH_LOGS="$1"
  fi
}

edit() {
  if [[ $# -eq 1 ]]; then
    local input="$1"
    case $input in
      ([0-9])
        GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/edit/'" git rebase -i HEAD~"${input}"
        ;;
      *)
        $1 ${PREFIX}/dotfiles/scripts.sh
        ;;
    esac
  else
    code ${PREFIX}/dotfiles/scripts.sh
  fi
}

pull_dotfiles() {
  goto dotfiles
  git pull
  cd -
}

push_dotfiles() {
  goto dotfiles
  git add -A
  git commit -m "`date`"
  git push -f
  cd -
}

reload_goto() {
  goto -c

  for d in ${PREFIX}/*; do
    local b=$(basename $d)
    goto -r $b $d
  done
}

sync_dotfiles() {
  # Run 'git status' command
  goto dotfiles

  local status_output
  status_output=$(git status --porcelain)

  # fetch origin and compare local/remote commit
  git fetch origin
  local local_commit=$(git rev-parse master)
  local remote_commit=$(git rev-parse origin/master)

  # Check if there are files to be committed
  if [[ -n "$status_output" || "${local_commit}" != "${remote_commit}" ]]; then
    git status
    echo "dotfiles requires sync"
    echo -n "Do you want to sync it now? (Y/n) "
    read -r input
    if [[ "${input}" == "Y" || "${input}" == "y" ]]; then
      echo "Syncronizing..."
      if [[ "$status_output" ]]; then
        git stash
      fi

      pull_dotfiles

      if [[ "$status_output" ]]; then
        git stash pop
        push_dotfiles
      fi

    fi
  fi

  cd - > /dev/null
}

if [[ $(hostname) =~ qgpu ]]; then

  # Use 'guilhermeleobas/prompt' which is symlinked to '~/.prompt'.
  # . ~/.prompt/prompt.bash

  # Add git completion to the prompt (comes from 'skeswa/prompt').
  # . ~/.prompt/git-completion.bash

  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # goto
  [ -f ${PREFIX}/goto/goto.sh ] && source ${PREFIX}/goto/goto.sh

  CONDA_EXE=micromamba
  # CONDA_EXE=~/.local/bin/micromamba
  # use "default" conda env on qgpu machines
  # $CONDA_EXE activate default
fi

if [[ $(hostname) =~ guilhermeleobas-server || $(hostname) =~ Guilherme-MacBook || $(hostname) =~ MacBookPro.lan ]]; then
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

  # git lg
  git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

  # reset terminal
  alias reset_term="tput reset"

  # alias conda
  alias conda="micromamba"
  alias mamba="micromamba"

  # goto
  [ -f ${PREFIX}/goto/goto.sh ] && source ${PREFIX}/goto/goto.sh

  # fzf
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

export MAMBA_NO_BANNER=1

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
