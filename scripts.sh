#!/bin/zsh

PREFIX=${HOME}/git
__AUTO_ACTIVATE_ENV=1

build() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    llvm)
      env_vars llvm
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
      env_vars cpython
      make distclean
      make clean
      ./configure --with-pydebug --without-mimalloc --enable-loadable-sqlite-extensions --with-ensurepip=install --prefix=$CONDA_PREFIX
      # ./configure --with-pydebug --without-mimalloc --enable-loadable-sqlite-extensions --with-openssl=$CONDA_PREFIX --with-ensurepip=install --prefix=$CONDA_PREFIX
      make -s -j20
      ./python -m ensurepip
      ./python -m pip install setuptools pyyaml typing_extensions packaging
      # install setuptools, pyyaml, typing_extensions, packaging
      ;;

    numba)
      env_vars numba
      echo "python setup.py build_ext --inplace -j10"
      if [[ $(uname -s) =~ "Darwin" ]]; then
        export NUMBA_DISABLE_OPENMP=1
      fi
      python setup.py build_ext --inplace -j10
      ;;

    llvmlite)
      env_vars llvmlite
      python setup.py build
      ;;

    numpy)
      env_vars numpy
      spin build
      # python setup.py build_ext --inplace -j10
      ;;

    pytorch*)
      env_vars ${environment}
      # pip install -e . -v --no-build-isolation
      spin develop
      if [ "${environment}" = "pytorch-cuda" ]; then
        make triton
      fi

      ;;

    *)
      echo -n "build: unknown $1"
      ;;
  esac
}

clone() {
  case $1 in
    dotfiles|numba|ghstack-tui)
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

    pytorch|tutorials|vision|audio)
      echo "cloning $1..."
      git clone git@github.com:pytorch/$1.git --single-branch ${PREFIX}/$1
      env --chdir=${PREFIX}/$1 git remote add upstream git@github.com:pytorch/$1.git
      ;;

    pytorch*)
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

create() {
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

  local flag=""

  echo "create env: ${environment}..."
  remove "${environment}"

  case "${environment}" in
    cpython|numba)
      (cd ${PREFIX}/dotfiles/pixi/${environment} && pixi install && pixi workspace register --force)
      ;;

    pytorch*)
      (cd ${PREFIX}/dotfiles/pixi/pytorch && pixi install -e ${environment} && pixi workspace register --force)
      ;;

    *)
      local env_dir="${PREFIX}/dotfiles/pixi/${environment}"
      if [[ ! -d "${env_dir}" ]]; then
        mkdir -p "${env_dir}"
        (cd "${env_dir}" && pixi init .)
      fi
      (cd "${env_dir}" && pixi install && pixi workspace register --force)
      ;;
  esac

}

env() {
  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  if [[ "${__AUTO_ACTIVATE_ENV}" == "1" ]]; then
    case ${environment} in
      cpython|numba)
        eval "$(pixi shell-hook --workspace ${environment})"
        ;;

      pytorch*)
        eval "$(pixi shell-hook --workspace pytorch -e ${environment})"
        ;;

      *)
        echo -n "env: unknown ${environment}"
        ;;
    esac

    echo "activated env ${environment}"
    env_vars ${environment}

    if [[ $? -ne 0 ]]; then
      echo "failing activate env $1"
    fi
  fi
}

env_vars() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  echo "Setting env vars for '${environment}'"

  case ${environment} in
    numba)
      export NUMBA_CAPTURED_ERRORS="new_style"
      ;;

    pytorch*)
      # remember to create a symlink from /usr/lib/cuda to /usr/local/cuda
      # sudo ln -s /usr/lib/cuda /usr/local/cuda
      # export USE_CUDA=$([ "${environment}" = "pytorch-cuda" ] && echo 1 || echo 0)
      [[ -n $USE_CUDA ]] || export USE_CUDA=0

      export CUDA_HOME=/usr/local/cuda

      export CC=cc
      export CXX=c++
      export CFLAGS="${CFLAGS} ${CFLAGS_DBG}"
      export CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS"
      export CXXFLAGS="${CXXFLAGS} ${CXXFLAGS_DBG}"
      if [[ "$(uname)" == "Linux" ]]; then
        export CFLAGS="${CFLAGS} -L${CONDA_PREFIX}/lib"
        export CXXFLAGS="${CXXFLAGS} -L${CONDA_PREFIX}/lib"
        export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${CUDA_HOME}/lib64"
        export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${CUDA_HOME}/extras/CUPTI/lib64"
        export LDFLAGS="${LDFLAGS} -L${CUDA_HOME}/lib64"
      fi
      ;;

    cpython)
      # Needed for ssl
      # export CFLAGS="${CFLAGS} -L${CONDA_PREFIX}/lib"
      # export CXXFLAGS="${CXXFLAGS} -L${CONDA_PREFIX}/lib"
      # export CFLAGS="${CFLAGS} -Werror"
      alias compile='cmake --build build --target install --config RelWithDebInfo -j 20'
      alias python='python3'
      export CC="ccache gcc"
      export CPPFLAGS="-I$CONDA_PREFIX/include"
      export LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib"
      export LIBRARY_PATH="$CONDA_PREFIX/lib"
      export LD_LIBRARY_PATH="$CONDA_PREFIX/lib"
      export DYLD_LIBRARY_PATH="$CONDA_PREFIX/lib"
      export CMAKE_C_LINKER=lld
      export CMAKE_CXX_LINKER=lld
      ;;

    vision|audio)
      export Torch_DIR="${PREFIX}/pytorch"
      ;;

    *)
      echo "No env_vars rule for '${environment}'"
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

install() {
  case $1 in
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

    tpm)
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      ;;

    pixi)
      curl -fsSL https://pixi.sh/install.sh | sh
      ;;

    rg)
      pixi g install ripgrep
      ;;

    gh)
      pixi g install gh
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

pytorch-update(){
  git submodule sync
  git submodule update --init --recursive
}

pytorch-test-download(){
  echo $0 $1
  filename=$1
  # Copy original file to /tmp
  cp "test/cpython/v3_13/${filename}.py" /tmp

  # Download latest version from CPython repo
  wget -O "test/cpython/v3_13/${filename}.py" "https://raw.githubusercontent.com/python/cpython/refs/tags/v3.13.5/Lib/test/${filename}.py"

  # Stage the updated file
  git add "test/cpython/v3_13/${filename}.py"

  cp "/tmp/${filename}.py" "test/cpython/v3_13/${filename}.py"

  # Create a diff between original and updated versions
  git diff "test/cpython/v3_13/${filename}.py" > "test/cpython/v3_13/${filename}.diff"

  git add "test/cpython/v3_13/${filename}.py"
  git add "test/cpython/v3_13/${filename}.diff"
}

pytorch-test-remove(){
  PYTORCH_TEST_WITH_DYNAMO=1 python test/cpython/v3_13/$1.py 2>&1 | grep "ERROR: test" | sed -E 's/.*__main__\.(.*)\)/\1/' | xargs -I{} rm -f test/dynamo_expected_failures/CPython313-$1-{}
}

pytorch-test-add(){
  PYTORCH_TEST_WITH_DYNAMO=1 python test/cpython/v3_13/$1.py 2>&1 | grep "ERROR: test" | sed -E 's/.*__main__\.(.*)\)/\1/' | xargs -I{} touch test/dynamo_expected_failures/CPython313-$1-{}
  git add test/dynamo_expected_failures/*
}

pytorch-test-all(){
  for f in $(ls test/cpython/v3_13/test_*.py); do
    PYTORCH_TEST_WITH_DYNAMO=1 python $f
  done;
}

pytorch-check-merge(){
  git fetch upstream
  local target="${1:-upstream/main}"
  local remote="${target%%/*}" branch="${target#*/}"
  local start
  start="$(git rev-parse --abbrev-ref HEAD)"
  [ "$start" = "HEAD" ] && start="$(git rev-parse HEAD)"

  git fetch "$remote" "$branch" || return 2
  git checkout --quiet -b __mergeable_test__ "$start" || return 2

  local rc
  if git rebase "$target"; then
      echo "MERGEABLE"; rc=0
  else
      git rebase --abort >/dev/null 2>&1
      echo "CONFLICT"; rc=1
  fi

  git checkout --quiet "$start"
  git branch -D __mergeable_test__ >/dev/null 2>&1
  return $rc
}

remove() {
  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case ${environment} in
    cpython|numba)
      pixi clean --workspace ${environment}
      ;;
    pytorch*)
      pixi clean --workspace pytorch --environment ${environment}
      ;;
    *)
      echo "remove: unknown ${environment}"
      ;;
    esac
}

reload() {
  exec ${SHELL}
}

### git operations

abort() {
  git rebase --abort
  git --no-pager log -1 --oneline
}

undo() {
  git reset --soft HEAD~1
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

reword() {
  local input="$1"
  GIT_SEQUENCE_EDITOR="perl -0pi -e 's/^pick/reword/'" git rebase -i HEAD~"${input}"
}

alias amend="git commit --amend --no-edit"
alias continue="git rebase --continue"

edit() {
  if [[ $# -eq 1 ]]; then
    local input="$1"

    if [[ "$input" =~ ^[0-9]+$ ]]; then
      GIT_SEQUENCE_EDITOR="perl -0pi -e 's/^pick/edit/'" \
        git rebase -i HEAD~"$input"
    else
      "$input" "${PREFIX}/dotfiles/scripts.sh"
    fi
  else
    code "${PREFIX}/dotfiles/scripts.sh"
  fi
}

pytorch-fix-local() {
  local input="${1:?Usage: pytorch-fix-local <pr_url>}"

  # checkout the ghstack PR branch in the shared copy
  cd "${HOME}/git/pytorch313-cp"
  ghstack checkout "$input"
  claude "please look at the CI for PR $input and fix the issues. After fixing, run 'lintrunner -a' and 'ghstack' to push the changes. To run any test, use pixi with workspace 'pytorch' and environment 'pytorch313-cp'"
}

pytorch-fix-remote() {
  local input="${1:?Usage: pytorch-fix-remote <pr_url> [pytorch_dir]}"
  local pytorch_dir="${2:-${HOME}/git/pytorch313}"
  local pr
  pr=$(echo "$input" | grep -oE '[0-9]+$')
  if [[ -z "$pr" ]]; then
    echo "pytorch-fix-remote: could not extract PR number from: $input" >&2
    return 1
  fi

  local ws
  ws=$(cmux new-workspace --name "claude-$pr" --window window:1 | awk '{print $2}')
  cmux send --workspace "$ws" "ssh qgpu3\n"
  cmux send --workspace "$ws" "pytorch-fix-local $input\n"
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
  local local_commit=$(git rev-parse main)
  local remote_commit=$(git rev-parse origin/main)

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
  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # goto
  [ -f ${PREFIX}/goto/goto.sh ] && source ${PREFIX}/goto/goto.sh

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

  # goto
  [ -f ${PREFIX}/goto/goto.sh ] && source ${PREFIX}/goto/goto.sh

  # fzf
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

export MAMBA_NO_BANNER=1

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
