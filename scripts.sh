
if [[ $(hostname) =~ "qgpu" ]]; then
  PREFIX=${HOME}/git
else
  PREFIX=${HOME}/Documents/GitHub
fi

omnisci-conda-run(){
  echo "running omniscidb..."
  rm -rf data
  mkdir data
  mamba run -n omniscidb-env omnisci_initdb data -f
  mamba run -n omniscidb-env omnisci_server --version
  mamba run --live-stream --no-capture-output -n omniscidb-env omnisci_server --enable-runtime-udf --enable-table-functions
}

omnisci-conda-install(){
  conda deactivate
  conda activate default
  conda remove --name omniscidb-env --all -y
  mamba create -n omniscidb-env omniscidb=5.7*=*_cpu -c conda-forge -y
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

reload() {
  if [[ $(hostname) =~ "qgpu" ]]; then
    source ${HOME}/.bashrc
  else
    source ${HOME}/.zshrc
  fi
}

install() {
  echo "installing $1\n"
  case $1 in
    ag)
      conda install silverseacher-ag -c conda-forge
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
      
    theme)
      git clone git@github.com:guilhermeleobas/prompt.git ${PREFIX}/prompt
      make -C ${PREFIX}/prompt install
      ;;
    *)
      echo -n "install(): unknown $1"
      ;;
  esac
}

clone() {
  case $1 in
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
      git clone git@github.com:Quansight/pearu-sandbox.git ${HOME}/Quansight/pearu-sandbox
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

    omnisci-nocuda)
      echo "activating env: omniscidb nocuda"
      export USE_ENV=omniscidb-cpu-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
      ;;

    omnisci-cuda)
      echo "activating env: omniscidb cuda"
      export USE_ENV=omniscidb-cuda-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
      ;;
    
    taco)
      echo "activating env: taco"
      conda activate taco
      ;;
    
    *)
      echo -n "env(): unknown $1\n"
      ;;
  esac
}

build() {
  echo $1
  case $1 in
    omnisci-nocuda)
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DENABLE_TESTS=off \
        ${PREFIX}/omniscidb-internal/
      ;;

    omnisci-cuda)
      cmake -Wno-dev $CMAKE_OPTIONS_CUDA \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DENABLE_TESTS=off \
        ${PREFIX}/omniscidb-internal/
      ;;
    
    taco)
      cmake -DLLVM=ON ${PREFIX}/taco
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
      mamba env create --file=${PREFIX}/rbc/.conda/environment.yml -n rbc
      ;;

    numba)
      echo "recreate env: numba..."
      conda deactivate
      conda activate default
      conda remove --name numba --all -y
      mamba create -n numba python=3.8 llvmlite numpy scipy jinja2 cffi
      ;;

    omnisci-nocuda)
      echo "recreate env: nocuda..."
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      ;;

    omnisci-cuda)
      echo "recreate env: omniscidb cuda"
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cuda-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      ;;
    
    taco)
      echo "recreate env: taco"
      conda deactivate
      conda activate default
      conda remove --name taco --all -y
      mamba env create --file=${PREFIX}/taco/.conda/environment.yml -n taco
      ;;
    
    *)
      echo -n "env: unknown $1"
      ;;
  esac
}

register_goto() {
  goto -r pytorch ${PREFIX}/Quansight/pytorch
  goto -r rbc ${PREFIX}/rbc
  goto -r omnisci ${PREFIX}/omniscidb-internal
  goto -r omnisci-nocuda ${PREFIX}/build-nocuda
  goto -r omnisci-cuda ${PREFIX}/build-cuda
  goto -r numba ${PREFIX}/numba
  goto -r pearu-sandbox ${PREFIX}/Quansight/pearu-sandbox
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
fi

export MAMBA_NO_BANNER=1

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
