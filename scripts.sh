if [[ $(hostname) =~ "qgpu" ]]; then
  PREFIX=${HOME}/git
elif [[ $(hostname) =~ "guilherme-server" ]]; then
  PREFIX=${HOME}/git
else
  PREFIX=${HOME}/git
fi

omnisci-conda-run(){
  conda deactivate
  conda activate omniscidb-env
  echo "running omniscidb..."
  rm -rf data
  mkdir data
  mamba run -n omniscidb-env omnisci_initdb data -f
  mamba run -n omniscidb-env omnisci_server --version
  mamba run -n omniscidb-env omnisci_server --enable-runtime-udf --enable-table-functions
}

omnisci-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    conda deactivate
    conda activate base
    conda remove --name omniscidb-env --all -y
    mamba create -n omniscidb-env "omniscidb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: omnisci-conda-install version cpu|gpu'
  fi
}

pytorch-update(){
  git submodule sync
  git submodule update --init --recursive
}

pytorch-pyi(){
  python -m tools.pyi.gen_pyi
}

reload() {
  if [[ $(hostname) =~ "qgpu" ]]; then
    source ${HOME}/.bashrc
  elif [[ $(hostname) =~ "guilherme-server" ]]; then
    source ${HOME}/.zshrc
  else
    source ${HOME}/.zshrc
  fi
}

clone() {
  case $1 in
    dotfiles)
      echo "cloning dotfiles..."
      git clone git@github.com:guilhermeleobas/dotfiles.git ${PREFIX}/dotfiles
      ;;

    rbc)
      echo "cloning rbc..."
      git clone git@github.com:guilhermeleobas/rbc.git ${PREFIX}/rbc
      ;;

    numba)
      echo "cloning numba..."
      git clone git@github.com:guilhermeleobas/numba.git ${PREFIX}/numba
      ;;

    numpy)
      echo "cloning numpy..."
      git clone git@github.com:numpy/numpy.git ${PREFIX}/numpy
      ;;

    llvmlite)
      echo "cloning llvmlite..."
      git clone git@github.com:numba/llvmlite.git ${PREFIX}/llvmlite
      ;;

    omniscidb)
      echo "cloning omniscidb..."
      git clone git@github.com:omnisci/omniscidb-internal.git ${PREFIX}/omniscidb-internal
      ;;

    sandbox)
      echo "cloning sandbox..."
      git clone git@github.com:Quansight/pearu-sandbox.git ${HOME}/git/Quansight/pearu-sandbox
      ;;

    taco)
      echo "cloning Quansight-labs:taco..."
      git clone git@github.com:Quansight-Labs/taco.git ${PREFIX}/taco
      ;;

    fzf)
      git clone git@github.com:junegunn/fzf.git ~/.fzf
      ~/.fzf/install
      ;;

    goto)
      git clone git@github.com:iridakos/goto.git ${PREFIX}/goto
      source ~/git/goto/goto.sh
      register_goto
      ;;

    tpm)
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      ;;

    ag)
      mamba install silverseacher-ag -c conda-forge
      ;;

    theme)
      git clone git@github.com:guilhermeleobas/prompt.git ${PREFIX}/prompt
      make -C ${PREFIX}/prompt install
      ;;

    *)
      echo -n "clone(): unknown $1"
      ;;
  esac
}

find_env() {
  environment=""
  local d=$(basename $(pwd))
  case ${d} in
    rbc)
      environment=$d
      ;;
    numba)
      environment=$d
      ;;
    llvmlite)
      environment=$d
      ;;
    taco)
      environment=$d
      ;;
    numpy)
      environment=$d
      ;;
    pytorch)
      environment=$d
      ;;
    build-nocuda)
      environment=omniscidb-cpu-dev
      ;;
    build-cuda)
      environment=omniscidb-cuda-dev
      ;;
    *)
      echo "find_env(): unknown $d"
      ;;
  esac
}

env() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  if [[ "${environment}" != "${CONDA_DEFAULT_ENV}" ]]; then
    case ${environment} in
      taco|rbc|numba|numpy|llvmlite)
        echo "activating env: ${environment}"
        conda deactivate
        conda activate ${environment}
        ;;

      omniscidb-cpu-dev)
        echo "activating env: omniscidb nocuda"
        export USE_ENV=omniscidb-cpu-dev
        . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
        ;;

      omniscidb-cuda-dev)
        echo "activating env: omniscidb cuda"
        export CUDA_HOME=/usr/local/cuda/
        export USE_ENV=omniscidb-cuda-dev
        . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
        ;;

      pytorch)
        echo "activating env: pytorch"
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
        ;;

      *)
        echo -n "env(): unknown ${environment}\n"
        ;;
    esac
  fi
}

build() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    omniscidb-cpu-dev)
      env omniscidb-cpu-dev
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_CUDA=off \
        -DENABLE_FOLLY=off \
        -DENABLE_AWS_S3=off \
        -DENABLE_GEOS=off \
        -DENABLE_JAVA_REMOTE_DEBUG=off \
        -DENABLE_PROFILER=off \
        -DBENCHMARK_ENABLE_EXCEPTIONS=off \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DENABLE_FSI_ODBC=off \
        -DENABLE_TESTS=off \
        -DUSE_ALTERNATE_LINKER=lld \
        ${PREFIX}/omniscidb-internal/
      ;;

    omniscidb-cuda-dev)
      env omniscidb-cuda-dev
      cmake -Wno-dev $CMAKE_OPTIONS_CUDA \
        -DCMAKE_BUILD_TYPE=Release \
	      -DENABLE_CUDA=on \
        -DENABLE_FOLLY=off \
        -DENABLE_AWS_S3=off \
        -DENABLE_GEOS=off \
        -DENABLE_JAVA_REMOTE_DEBUG=off \
        -DENABLE_PROFILER=off \
        -DBENCHMARK_ENABLE_EXCEPTIONS=off \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DENABLE_FSI_ODBC=off \
        -DENABLE_TESTS=off \
        -DUSE_ALTERNATE_LINKER=lld \
        ${PREFIX}/omniscidb-internal/
      ;;

    pytorch)
      env pytorch
      python setup.py develop -j10
      ;;

    taco)
      env taco
      cmake -DLLVM=ON ${PREFIX}/taco \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
        ${PREFIX}/taco
      ;;
      
    rbc)
      env rbc
      python setup.py develop
      ;;

    numba)
      env numba
      python setup.py build_ext --inplace
      ;;

    llvmlite)
      env llvmlite
      python setup.py build
      ;;

    numpy)
      env numpy
      python setup.py build_ext --inplace -j10
      ;;

    *)
      echo -n "build: unknown $1"
      ;;
  esac
}

query() {
  bin/omnisql --passwd HyperInteractive < ../query.sql
}

run() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    omniscidb-cpu-dev)
      echo "running omniscidb..."
      echo "bin/omnisci_server --enable-dev-table-functions --enable-runtime-udf --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING"
      env omniscidb-cpu-dev
      bin/omnisci_server --enable-dev-table-functions --enable-runtime-udf --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING
      ;;

    omniscidb-cuda-dev)
      echo "running omniscidb..."
      echo "bin/omnisci_server --enable-dev-table-functions --enable-runtime-udf --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING"
      env omniscidb-cuda-dev
      bin/omnisci_server --enable-dev-table-functions --enable-runtime-udf --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING
      ;;

    *)
      echo -n "run: unknown $environment"
      ;;
  esac
}

test() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    numba)
      echo "running numba tests..."
      echo "python -m numba.runtests -f -b -v -g -m 15 -- numba.tests"
      env numba
      python -m numba.runtests -b -v -g -m 15 -- numba.tests
      ;;

    omniscidb-cpu-dev)
      echo "running omniscidb cpu tests..."
      echo "Tests/TableFunctionTests"
      env omniscidb-cpu-dev
      Tests/TableFunctionTests
      ;;

    *)
      echo -n "test: unknown $environment"
  esac
}

create() {
  conda deactivate
  if [[ $(hostname) =~ qgpu ]]; then
    conda activate default
  else
    conda activate base
  fi

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    rbc)
      echo "create env: rbc..."
      conda remove --name rbc --all -y
      mamba env create --file=${PREFIX}/rbc/.conda/environment.yml -n rbc
      ;;

    numba)
      echo "create env: numba..."
      conda remove --name numba --all -y
      mamba create -n numba python=3.8 llvmlite numpy cffi
      ;;

    numpy)
      echo "create env: numpy..."
      conda remove --name numpy --all -y
      mamba env create --file=${PREFIX}/numpy/environment.yml -n numpy
      ;;

    llvmlite)
      echo "create env: llvmlite..."
      conda remove --name llvmlite --all -y
      mamba create -n llvmlite python=3.9 -c conda-forge -y
      mamba install -n llvmlite llvmdev -c numba -y
      mamba install -n llvmlite compilers cmake make -c conda-forge -y
      ;;

    omniscidb-cpu-dev)
      echo "create env: nocuda..."
      conda remove --name omniscidb-cpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      ;;

    omniscidb-cuda-dev)
      echo "create env: omniscidb cuda"
      conda remove --name omniscidb-cuda-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      ;;

    taco)
      echo "recreate env: taco"
      conda remove --name taco --all -y
      mamba env create --file=${PREFIX}/taco/.conda/environment.yml -n taco
      ;;

    *)
      echo -n "env: unknown $1"
      ;;
  esac
}

edit() {
  vim ~/git/dotfiles/scripts.sh
}

register_goto() {
  goto -r pytorch ${PREFIX}/Quansight/pytorch
  goto -r rbc ${PREFIX}/rbc
  goto -r omniscidb ${PREFIX}/omniscidb-internal
  goto -r omnisci-nocuda ${PREFIX}/build-nocuda
  goto -r omnisci-cuda ${PREFIX}/build-cuda
  goto -r numba ${PREFIX}/numba
  goto -r llvmlite ${PREFIX}/llvmlite
  goto -r numpy ${PREFIX}/numpy
  goto -r pearu-sandbox ${PREFIX}/Quansight/pearu-sandbox
  goto -r taco ${PREFIX}/taco
  goto -r dotfiles ${PREFIX}/dotfiles
}

if [[ $(hostname) =~ qgpu ]]; then

  # Use 'guilhermeleobas/prompt' which is symlinked to '~/.prompt'.
  . ~/.prompt/prompt.bash

  # Add git completion to the prompt (comes from 'skeswa/prompt').
  . ~/.prompt/git-completion.bash

  # fzf
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # goto
  [ -f ~/git/goto/goto.sh ] && source ~/git/goto/goto.sh

  # use "default" conda env on qgpu machines
  conda activate default
else
  # goto
  [ -f ~/git/goto/goto.sh ] && source ~/git/goto/goto.sh
fi

export MAMBA_NO_BANNER=1

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
