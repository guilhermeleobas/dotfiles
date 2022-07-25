PREFIX=${HOME}/git


if ! [[ -x "$(command -v conda)" ]]; then
  alias conda=micromamba
  alias mamba=micromamba
fi


heavy-conda-run(){
  conda deactivate
  conda activate heavydb-env
  echo "running heavydb..."
  rm -rf storage
  mkdir storage
  mamba run -n heavydb-env initheavy storage -f
  version=$(mamba run -n heavydb-env heavydb --version)
  echo ${version}
  mamba run -n heavydb-env heavydb --enable-runtime-udf --enable-table-functions --enable-dev-table-functions --enable-udf-registration-for-all-users
}

heavy-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    conda deactivate
    conda activate base
    conda remove --name heavydb-env --all -y
    mamba create -n heavydb-env "heavydb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: heavy-conda-install version cpu|cuda'
  fi
}

omnisci-conda-run(){
  conda deactivate
  conda activate omniscidb-env
  echo "running omniscidb..."
  rm -rf data
  mkdir data
  mamba run -n omniscidb-env omnisci_initdb data -f
  version=$(mamba run -n omniscidb-env omnisci_server --version)
  echo ${version}
  EXTRA_FLAGS=""
  if [[ ${version} =~ "5.10" ]]; then
    EXTRA_FLAGS="--enable-dev-table-functions"
  fi
  mamba run -n omniscidb-env omnisci_server --enable-runtime-udf --enable-table-functions ${EXTRA_FLAGS}
}

omnisci-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    conda deactivate
    conda activate base
    conda remove --name omniscidb-env --all -y
    mamba create -n omniscidb-env "omniscidb=$1*=*_$2" -c conda-forge -y
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
  mamba run -n heavydb-env initheavy storage -f
  version=$(mamba run -n heavydb-env heavydb --version)
  echo ${version}
  mamba run -n omniscidb-env heavydb --enable-runtime-udf --enable-table-functions --enable-dev-table-functions
}

heavydb-conda-install(){
  if [[ $# -eq 2 ]]; then
    echo $0 $1 $2
    conda deactivate
    conda activate base
    conda remove --name heavydb-env --all -y
    mamba create -n heavydb-env "heavydb=$1*=*_$2" -c conda-forge -y
  else
    echo 'usage: heavydb-conda-install version cpu|cuda'
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
      pushd ${PREFIX}/rbc
      git remote add upstream git@github.com:xnd-project/rbc.git
      popd
      ;;

    rbc-feedstock|omniscidb-feedstock)
      echo "cloning $1..."
      git clone git@github.com:guilhermeleobas/$1.git ${PREFIX}/$1/
      ;;

    ibis-omniscidb)
      echo "cloning ibis-omniscidb..."
      git clone git@github.com:omnisci/ibis-omniscidb.git ${PREFIX}/ibis-omniscidb
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

    heavydb-oss)
      echo "cloning heavydb oss..."
      git clone git@github.com:heavyai/heavydb.git ${PREFIX}/heavydb
      ;;

    heavydb)
      echo "cloning heavydb..."
      git clone git@github.com:heavyai/heavydb-internal.git ${PREFIX}/heavydb-internal
      ;;

    sandbox)
      echo "cloning sandbox..."
      git clone git@github.com:Quansight/pearu-sandbox.git ${HOME}/git/Quansight/pearu-sandbox
      ;;

    taco)
      echo "cloning Quansight-labs:taco..."
      git clone git@github.com:Quansight-Labs/taco.git ${PREFIX}/taco
      ;;

    *)
      echo -n "clone(): unknown $1"
      ;;
  esac
}

install() {
  case $1 in
    micromamba)
      curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
      ./bin/micromamba shell init -s zsh -p ~/micromamba
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
    rbc|numba|llvmlite|taco|numpy|pytorch|ibis-omniscidb)
      environment=$d
      ;;
    llvm-project)
      environment=llvm
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
      taco|rbc|numba|numpy|llvmlite|llvm|ibis-omniscidb)
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
        -DCMAKE_BUILD_TYPE=DEBUG \
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
        -DENABLE_TESTS=off \
        -DUSE_ALTERNATE_LINKER="lld" \
        ${PREFIX}/heavydb-internal/
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
        -DENABLE_RENDERING=off \
        -DENABLE_TESTS=off \
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
      echo "python setup.py build_ext --inplace -j10"
      python setup.py build_ext --inplace -j10
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

sql() {
  goto omnisci-nocuda
  env
  bin/omnisql --passwd HyperInteractive
}

run() {

  if [[ $# -eq 0 ]]; then
    find_env
  else
    environment=$1
  fi

  case $environment in
    omniscidb-cpu-dev)
      echo "running heavydb..."
      echo "bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING"
      env omniscidb-cpu-dev
      bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING
      ;;

    omniscidb-cuda-dev)
      echo "running heavydb..."
      echo "bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING"
      env omniscidb-cuda-dev
      bin/heavydb --enable-dev-table-functions --enable-udf-registration-for-all-users --enable-runtime-udfs --enable-table-functions --enable-debug-timer --log-channels PTX,IR --log-severity-clog=WARNING
      ;;

    *)
      echo -n "run: unknown $environment"
      ;;
  esac
}

run_tests() {

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

    rbc)
      echo "running rbc tests..."
      echo "pytest --tb=short rbc/tests"
      env rbc
      pytest --tb=short rbc/tests/
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

  echo "create env: ${environment}..."
  conda remove --name ${environment} --all -y

  case $environment in
    rbc)
      mamba create --file=${PREFIX}/rbc/environment.yml -n rbc
      ;;

    numba)
      mamba create -n numba python=3.9 llvmlite=0.40 numpy cffi pdbpp pytest -c numba/label/dev
      ;;

    numpy)
      mamba create --file=${PREFIX}/numpy/environment.yml -n numpy
      ;;

    ibis-omniscidb)
      mamba env create --file=${PREFIX}/ibis-omniscidb/environment-dev.yaml -n ibis-omniscidb
      ;;

    llvmlite)
      mamba create -n llvmlite python=3.9 -c conda-forge -y
      mamba install -n llvmlite llvmdev -c numba -y
      mamba install -n llvmlite compilers cmake make -c conda-forge -y
      ;;

    llvm)
      mamba create -n llvm cmake ccache compilers make -c conda-forge -y
      ;;

    omniscidb-cpu-dev)
      mamba create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      mamba install -n omniscidb-cpu-dev fmt -c conda-forge -y
      ;;

    omniscidb-cuda-dev)
      mamba create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      ;;

    taco)
      mamba create --file=${PREFIX}/taco/.conda/environment.yml -n taco
      ;;

    *)
      echo -n "env: unknown ${environment}"
      ;;
  esac
}

edit() {
  code ~/git/dotfiles/scripts.sh
}

flake8_diff() {
  git diff HEAD^ | flake8 --diff
}

register_goto() {
  goto -r pytorch ${PREFIX}/Quansight/pytorch
  goto -r rbc ${PREFIX}/rbc
  goto -r heavydb ${PREFIX}/heavydb-internal
  goto -r heavydb-nocuda ${PREFIX}/build-nocuda
  goto -r heavydb-cuda ${PREFIX}/build-cuda
  goto -r numba ${PREFIX}/numba
  goto -r llvmlite ${PREFIX}/llvmlite
  goto -r numpy ${PREFIX}/numpy
  goto -r pearu-sandbox ${PREFIX}/Quansight/pearu-sandbox
  goto -r taco ${PREFIX}/taco
  goto -r dotfiles ${PREFIX}/dotfiles
  goto -r llvm ${PREFIX}/llvm-project
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
