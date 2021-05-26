
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

reload() {
  source ${HOME}/.bashrc
}

clone() {
  case $1 in
    rbc)
      echo "cloning rbc..."
      git clone git@github.com:guilhermeleobas/rbc.git ${HOME}/git/rbc
      ;;

    numba)
      echo "cloning numba..."
      git clone git@github.com:guilhermeleobas/numba.git ${HOME}/git/numba
      ;;

    llvmlite)
      echo "cloning llvmlite..."
      git clone git@github.com:numba/llvmlite.git ${HOME}/git/llvmlite
      ;;

    omniscidb)
      echo "cloning omniscidb..."
      git clone git@github.com:omnisci/omniscidb-internal.git ${HOME}/git/omniscidb-internal
      ;;
    
    sandbox)
      echo "cloning sandbox..."
      git clone git@github.com:Quansight/pearu-sandbox.git ${HOME}/Quansight/pearu-sandbox
      ;;
    
    taco)
      echo "cloning Quansight-labs:taco..."
      git clone git@github.com:Quansight-Labs/taco.git ${HOME}/git/taco
      ;;
      
    goto)
      echo "cloning goto..."
      git clone git@github.com:iridakos/goto.git ${HOME}/git/goto
      ;;
      
    theme)
      echo "cloning theme..."
      git clone git@github.com:guilhermeleobas/prompt.git ${HOME}/git/prompt
      make -C ${HOME}/git/prompt install
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
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
        ${HOME}/git/omniscidb-internal/
      ;;

    omnisci-cuda)
      cmake -Wno-dev $CMAKE_OPTIONS_CUDA \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DENABLE_TESTS=off \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
        ${HOME}/git/omniscidb-internal/
      ;;
    
    taco)
      cmake -DLLVM=ON ${HOME}/git/taco
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
      ;;

    numba)
      echo "recreate env: numba..."
      echo "missing definitions"
      ;;

    omnisci-nocuda)
      echo "recreate env: nocuda..."
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      ;;

    omnisci-cuda)
      echo "activating env: omniscidb cuda"
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cuda-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      ;;
    
    *)
      echo -n "env: unknown $1"
      ;;
  esac
}

register_goto() {
  if [[  $(hostname) =~ "qgpu" ]]; then
    goto -r pytorch ~/git/Quansight/pytorch
    goto -r rbc ~/git/rbc
    goto -r omnisci ~/git/omniscidb-internal
    goto -r omnisci-nocuda ~/git/build-nocuda
    goto -r omnisci-cuda ~/git/build-cuda
    goto -r numba ~/git/numba
    goto -r pearu-sandbox ${HOME}/git/Quansight/pearu-sandbox
  fi

  if [[ $(hostname) =~ "Guilherme" ]]; then
    goto -r rbc ${HOME}/Documents/GitHub/rbc
    goto -r numba ${HOME}/Documents/GitHub/numba
  fi
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
