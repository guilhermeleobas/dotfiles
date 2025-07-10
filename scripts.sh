PREFIX=${HOME}/git

heavy-conda-run(){
  micromamba deactivate
  micromamba activate heavydb-env
  echo "running heavydb..."
  rm -rf storage
  mkdir storage
  micromamba run -n heavydb-env initheavy storage -f
  version=$(micromamba run -n heavydb-env heavydb --version)
  echo ${version}
  micromamba run -n heavydb-env heavydb --enable-runtime-udf --enable-table-functions --enable-dev-table-functions --enable-udf-registration-for-all-users  --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING --log-severity=DEBUG4
}

heavy-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    micromamba deactivate
    micromamba activate base
    micromamba remove --name heavydb-env --all -y
    micromamba create -n heavydb-env "heavydb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: heavy-conda-install version cpu|cuda'
  fi
}

omnisci-conda-run(){
  micromamba deactivate
  micromamba activate omniscidb-env
  echo "running omniscidb..."
  rm -rf data
  mkdir data
  micromamba run -n omniscidb-env omnisci_initdb data -f
  version=$(micromamba run -n omniscidb-env omnisci_server --version)
  echo ${version}
  EXTRA_FLAGS=""
  if [[ ${version} =~ "5.10" ]]; then
    EXTRA_FLAGS="--enable-dev-table-functions"
  fi
  micromamba run -n omniscidb-env omnisci_server --enable-runtime-udf --enable-table-functions ${EXTRA_FLAGS}
}

omnisci-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    micromamba deactivate
    micromamba activate base
    micromamba remove --name omniscidb-env --all -y
    micromamba env create -n omniscidb-env "omniscidb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: omnisci-conda-install version cpu|cuda'
  fi
}

heavydb-conda-run(){
  conda deactivate
  conda activate heavydb-env
  echo "running heavydb..."
  rm -rf storage
  mkdir storage
  micromamba run -n heavydb-env initheavy storage -f
  version=$(micromamba run -n heavydb-env heavydb --version)
  echo ${version}
  micromamba run -n omniscidb-env heavydb --enable-runtime-udf --enable-table-functions --enable-dev-table-functions
}

heavydb-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    micromamba deactivate
    micromamba activate base
    micromamba remove --name heavydb-env --all -y
    micromamba env create -n heavydb-env "heavydb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: heavydb-conda-install version cpu|cuda'
  fi
}

reload() {
  # if [[ $(hostname) =~ "qgpu" ]]; then
  #   source ${HOME}/.bashrc
  # else
  #   source ${HOME}/.zshrc
  # fi
  exec ${SHELL}
}

clone() {
  case $1 in
    dotfiles|rbc|rbc-feedstock|heavydb-ext-feedstock|heavyai-feedstock|numba|numba-rvsdg)
      echo "cloning $1..."
      git clone git@github.com:guilhermeleobas/$1.git ${PREFIX}/$1/
      ;;

    ibis-heavyai|heavyai|heavydb|heavydb-internal|sqlalchemy-heavyai)
      echo "cloning $1..."
      git clone git@github.com:heavyai/$1.git ${PREFIX}/$1
      ;;

    cudf)
      echo "cloning $1..."
      git clone git@github.com:rapidsai/$1.git ${PREFIX}/$1
      ;;

    sqlalchemy)
      echo "cloning sqlalchemy..."
      git clone git@github.com:sqlalchemy/sqlalchemy.git --single-branch ${PREFIX}/sqlalchemy
      ;;

    ibis)
      echo "cloning ibis..."
      git clone git@github.com:ibis-project/ibis.git ${PREFIX}/ibis
      ;;

    mold)
      echo "cloning mold..."
      git clone git@github.com:rui314/mold ${PREFIX}/mold
      ;;

    llvmlite|numba-extras|numba-scipy)
      echo "cloning $1..."
      git clone git@github.com:numba/$1.git ${PREFIX}/$1
      ;;

    numpy)
      echo "cloning numpy..."
      git clone git@github.com:numpy/numpy.git ${PREFIX}/numpy
      ;;

    pytorch|tutorials|vision|audio)
      echo "cloning $1..."
      git clone git@github.com:pytorch/$1.git ${PREFIX}/$1
      env --chdir=${PREFIX}/$1 git remote add upstream git@github.com:pytorch/$1.git
      ;;

    pytorch39|pytorch310|pytorch311|pytorch312|pytorch313)
      echo "cloning $1..."
      git clone git@github.com:pytorch/pytorch.git --single-branch ${PREFIX}/$1
      ;;

    cpython)
      echo "cloning cpython..."
      git clone git@github.com:python/cpython.git --single-branch ${PREFIX}/cpython
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
      # curl micro.mamba.pm/install.sh | zsh
      # ./bin/micromamba shell init -s zsh -p ~/micromamba
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
      register_goto
      ;;

    miniconda)
      bash <(curl -L conda.sh)
      ;;

    tpm)
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      ;;

    ag)
      micromamba install -c conda-forge the_silver_searcher
      ;;

    gh)
      micromamba install -c conda-forge gh
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
    heavydb-nocuda)
      environment=heavydb-cpu-dev
      ;;
    heavydb-cuda)
      environment=heavydb-cuda-dev
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
    heavydb-cpu-dev)
      echo "activating env: heavydb nocuda"
      export USE_ENV=heavydb-cpu-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-heavydb-internal-dev.sh
      ;;

    heavydb-cuda-dev)
      echo "activating env: heavydb cuda"
      export CUDA_HOME=/usr/local/cuda/
      export USE_ENV=heavydb-cuda-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-heavydb-internal-dev.sh
      ;;

    numba)
      micromamba deactivate
      micromamba activate numba
      export NUMBA_CAPTURED_ERRORS="new_style"
      ;;

    cudf)
      micromamba deactivate
      export CUDA_HOME=/usr/local/cuda
      micromamba activate cudf
      ;;

    pytorch|pytorch39|pytorch310|pytorch311|pytorch312|pytorch313|pytorch-cuda)
      echo "activating env: ${environment}"

      if [ "${environment}" = "pytorch313" ]; then
        export PYTHONBREAKPOINT=pdbp.set_trace
      fi

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
      export BUILD_CAFFE2_OPS=0
      export USE_GOLD_LINKER=1
      export CUDA_HOME=/usr/local/cuda
      # export USE_PRECOMPILED_HEADERS=1
      # export USE_PER_OPERATOR_HEADERS=1

      export CMAKE_BUILD_TYPE=RelWithDebInfo
      export MAX_JOBS=15
      export USE_DISTRIBUTED=0
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
      micromamba activate ${environment}
      ;;
  
    vision|audio)
      export Torch_DIR="${PREFIX}/pytorch"
      micromamba activate pytorch
      ;;

    *)
      echo "activating env: ${environment}"
      micromamba deactivate
      micromamba activate ${environment}

      if [[ $? -ne 0 ]]; then
        echo "activating default env..."
        micromamba activate ${CONDA_DEFAULT_ENV}
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
    heavydb-cpu-dev)
      env heavydb-cpu-dev
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
        -GNinja \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_WARNINGS_AS_ERRORS=off \
        -DENABLE_CUDA=off \
        -DENABLE_FOLLY=off \
        -DENABLE_AWS_S3=off \
        -DENABLE_GEOS=off \
        -DENABLE_JAVA_REMOTE_DEBUG=off \
        -DENABLE_PROFILER=off \
        -DBENCHMARK_ENABLE_EXCEPTIONS=off \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DENABLE_FSI_ODBC=off \
        -DENABLE_RENDERING=off \
        -DENABLE_SYSTEM_TFS=off \
        -DENABLE_ML_ONEDAL_TFS=off \
        -DENABLE_ML_MLPACK_TFS=off \
        -DENABLE_POINT_CLOUD_TFS=off \
        -DENABLE_PDAL=off \
        -DENABLE_RF_PROP_TFS=off \
        -DENABLE_TESTS=off \
        -DENABLE_ASAN=off \
        -DUSE_ALTERNATE_LINKER=lld \
        ${PREFIX}/heavydb-internal/
      ;;

    heavydb-cuda-dev)
      env heavydb-cuda-dev
      cmake -Wno-dev $CMAKE_OPTIONS_CUDA \
        -GNinja \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_WARNINGS_AS_ERRORS=off \
        -DENABLE_FOLLY=off \
        -DENABLE_AWS_S3=off \
        -DENABLE_GEOS=off \
        -DENABLE_JAVA_REMOTE_DEBUG=off \
        -DENABLE_PROFILER=off \
        -DBENCHMARK_ENABLE_EXCEPTIONS=off \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DENABLE_FSI_ODBC=off \
        -DENABLE_RENDERING=off \
        -DENABLE_SYSTEM_TFS=off \
        -DENABLE_ML_ONEDAL_TFS=off \
        -DENABLE_ML_MLPACK_TFS=off \
        -DENABLE_POINT_CLOUD_TFS=off \
        -DENABLE_PDAL=off \
        -DENABLE_RF_PROP_TFS=off \
        -DENABLE_TESTS=off \
        -DENABLE_ASAN=off \
        -DUSE_ALTERNATE_LINKER=lld \
        ${PREFIX}/heavydb-internal/
      ;;

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

    cython)
      env cython
      python setup.py build_ext --inplace -j10
      ;;

    cpython)
      env cpython
      ./configure --with-pydebug --with-openssl=$CONDA_PREFIX
      make -s -j10
      ;;

    rbc)
      env rbc
      python setup.py develop
      ;;

    mold)
      env mold
      cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ${PREFIX}/mold
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

    pytorch|pytorch39|pytorch310|pytorch311|pytorch312|pytorch313|pytorch-cuda|vision|audio)
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

query() {
  if [[ "${CONDA_DEFAULT_ENV}" =~ "heavydb-cuda-dev" ]]; then
    ${PREFIX}/heavydb-cuda/bin/heavysql --passwd HyperInteractive < ${PREFIX}/query.sql
  else
    ${PREFIX}/heavydb-nocuda/bin/heavysql --passwd HyperInteractive < ${PREFIX}/query.sql
  fi
}

sql() {
  env
  bin/heavysql --passwd HyperInteractive
}

run() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    heavydb-cpu-dev)
      echo "running heavydb..."
      echo "bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING"
      env heavydb-cpu-dev
      bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING
      ;;

    heavydb-cuda-dev)
      echo "running heavydb..."
      echo "bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING --log-severity=DEBUG4"
      env heavydb-cuda-dev
      bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING --log-severity=DEBUG4
      ;;

    *)
      echo -n "run: unknown $environment"
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
  micromamba deactivate
  if [[ $(hostname) =~ qgpu ]]; then
    micromamba activate default
  else
    micromamba activate base
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
  micromamba remove --name ${environment} --all -y

  case $environment in
    rbc)
      micromamba env create --file=${PREFIX}/rbc/environment.yml -n rbc -y
      ;;

    cython)
      micromamba env create --file=${PREFIX}/cython/environment.yml -n cython -y
      env cython
      pip install Cython==3.0.0a11
      ;;

    mold)
      micromamba create -n mold clang clangxx cmake make tbb -c conda-forge -y
      ;;

    numba)
      micromamba create -n numba python=3.11 llvmlite=0.44 pdbpp flake8 numpy cffi pytest -c numba/label/dev -c rapidsai
      ;;

    numba-rvsdg)
      micromamba create -n numba-rvsdg python=3.11 python-graphviz mypy pre-commit pytest pdbpp -c conda-forge -y
      ;;

    cudf)
      export CUDA_HOME=/usr/local/cuda/
      micromamba env create --file=${PREFIX}/cudf/conda/environments/all_cuda-118_arch-x86_64.yaml -n cudf
      ;;

    numpy)
      micromamba env create --file=${PREFIX}/numpy/environment.yml -n numpy
      ;;

    ibis-heavyai)
      micromamba env create --file=${PREFIX}/ibis-heavyai/environment.yaml -n ibis-heavyai
      ;;

    heavyai)
      micromamba env create --file=${PREFIX}/heavyai/ci/environment_gpu.yml -n heavyai
      ;;

    sqlalchemy-heavyai)
      micromamba env create --file=${PREFIX}/sqlalchemy-heavyai/environment.yaml -n sqlalchemy-heavyai
      ;;

    llvmlite)
      micromamba create -n llvmlite
      micromamba install -n llvmlite python=3.9 compilers cmake make llvmdev=14 -c numba -c conda-forge -y
      ;;

    llvm)
      micromamba env create -n llvm cmake ccache compilers make -c conda-forge -y
      ;;

    heavydb-cpu-dev)
      micromamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/heavydb-cpu-dev.yaml -n heavydb-cpu-dev -y
      ;;

    heavydb-cuda-dev)
      micromamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/heavydb-dev.yaml -n heavydb-cuda-dev -y
      ;;

    pytorch|pytorch39|pytorch310|pytorch311|pytorch312|pytorch313|pytorch-cuda)
      micromamba env create --file=${PREFIX}/dotfiles/conda-envs/$environment-dev.yaml -n $environment -y
      ;;

    cpython)
      micromamba env create --file=${PREFIX}/dotfiles/conda-envs/cpython.yaml -n cpython -y
      ;;

    *)
      case "$flag" in
        -n | --name)
          micromamba create --name ${environment}
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

rebase() {
  git rebase -i HEAD~"$1"
}

stash() {
  git stash --keep-index
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
    $1 ~/git/dotfiles/scripts.sh
  else
    code ~/git/dotfiles/scripts.sh
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

run_flake8() {
  git diff HEAD^ | flake8 --diff
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
  . ~/.prompt/prompt.bash

  # Add git completion to the prompt (comes from 'skeswa/prompt').
  . ~/.prompt/git-completion.bash

  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # goto
  [ -f ${PREFIX}/goto/goto.sh ] && source ${PREFIX}/goto/goto.sh

  # check if dotfiles is in sync with github
  # sync_dotfiles

  # use "default" conda env on qgpu machines
  conda activate default
else
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

  # check if dotfiles is in sync with github
  # sync_dotfiles

  # fzf
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

export MAMBA_NO_BANNER=1

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
