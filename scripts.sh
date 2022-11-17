PREFIX=${HOME}/git


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
    mamba env create -n omniscidb-env "omniscidb=$1*=*_$2" -c conda-forge -y
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
    mamba env create -n heavydb-env "heavydb=$1*=*_$2" -c conda-forge -y
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

    rbc-feedstock|heavydb-ext-feedstock)
      echo "cloning $1..."
      git clone git@github.com:guilhermeleobas/$1.git ${PREFIX}/$1/
      ;;

    ibis-heavyai)
      echo "cloning ibis-heavyai..."
      git clone git@github.com:heavyai/ibis-heavyai.git ${PREFIX}/ibis-heavyai
      ;;

    ibis)
      echo "cloning ibis..."
      git clone git@github.com:ibis-project/ibis.git ${PREFIX}/ibis
      ;;

    numba)
      echo "cloning numba..."
      git clone git@github.com:guilhermeleobas/numba.git ${PREFIX}/numba
      ;;

    numpy)
      echo "cloning numpy..."
      git clone git@github.com:numpy/numpy.git ${PREFIX}/numpy
      ;;
      
    cpython)
      echo "cloning cpython..."
      git clone git@github.com:python/cpython.git --single-branch ${PREFIX}/cpython
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
      source ~/git/goto/goto.sh
      register_goto
      ;;

    miniconda)
      bash <(curl -L conda.sh)
      ;;

    tpm)
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      ;;

    ag)
      mamba install -c conda-forge the_silver_searcher
      ;;

    gh)
      mamba install -c conda-forge gh
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
    rbc|numba|llvmlite|taco|numpy|pytorch|ibis-heavyai)
      environment=$d
      ;;
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
      taco|rbc|numba|numpy|llvmlite|llvm|ibis-heavyai|base)
        echo "activating env: ${environment}"
        conda deactivate
        conda activate ${environment}
        ;;

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
    heavydb-cpu-dev)
      env heavydb-cpu-dev
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
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
  bin/heavysql --passwd HyperInteractive < ../query.sql
}

query_benchmark() {
  for i in $(seq 1 10); do
    echo "select avg(cardinality(content_tokens)) from (select strtok_to_array$1(content_text, ' ?.!:') as content_tokens from hacker_news_comments limit ${i}00000);" > /tmp/file.sql
    echo "query..."
    cat /tmp/file.sql
    hyperfine "bin/omnisql --passwd HyperInteractive < /tmp/file.sql"
  done
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
      mamba env create --file=${PREFIX}/rbc/environment.yml -n rbc
      ;;

    numba)
      mamba create -n numba python=3.9 llvmlite=0.40 numpy cffi pytest -c numba/label/dev
      ;;

    numpy)
      mamba env create --file=${PREFIX}/numpy/environment.yml -n numpy
      ;;

    ibis-heavyai)
      mamba env create --file=${PREFIX}/ibis-heavyai/environment.yaml -n ibis-heavyai
      ;;

    llvmlite)
      mamba env create -n llvmlite python=3.9 -c conda-forge -y
      mamba install -n llvmlite llvmdev -c numba -y
      mamba install -n llvmlite compilers cmake make -c conda-forge -y
      ;;

    llvm)
      mamba env create -n llvm cmake ccache compilers make -c conda-forge -y
      ;;

    heavydb-cpu-dev)
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/heavydb-cpu-dev.yaml -n heavydb-cpu-dev
      # mamba install -n heavydb-cpu-dev fmt arrow=5.0=cpu -c conda-forge -y
      ;;

    heavydb-cuda-dev)
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/heavydb-dev.yaml -n heavydb-cuda-dev
      ;;

    taco)
      mamba env create --file=${PREFIX}/taco/.conda/environment.yml -n taco
      ;;

    *)
      echo -n "env: unknown ${environment}"
      ;;
  esac
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

register_goto() {
  goto -c
  goto -r pytorch ${PREFIX}/Quansight/pytorch
  goto -r rbc ${PREFIX}/rbc
  goto -r heavydb ${PREFIX}/heavydb-internal
  goto -r heavydb-nocuda ${PREFIX}/heavydb-nocuda
  goto -r heavydb-cuda ${PREFIX}/heavydb-cuda
  goto -r numba ${PREFIX}/numba
  goto -r llvmlite ${PREFIX}/llvmlite
  goto -r numpy ${PREFIX}/numpy
  goto -r pearu-sandbox ${PREFIX}/Quansight/pearu-sandbox
  goto -r taco ${PREFIX}/taco
  goto -r dotfiles ${PREFIX}/dotfiles
  goto -r llvm ${PREFIX}/llvm-project
  goto -r cpython ${PREFIX}/cpython
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
