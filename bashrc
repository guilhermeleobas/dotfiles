# Use 'guilhermeleobas/prompt' which is symlinked to '~/.prompt'.
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
      
    goto)
      echo "cloning goto..."
      git clone git@github.com:iridakos/goto.git ${HOME}/git/
      ;;
      
    theme)
      echo "cloning theme..."
      git clone git@github.com:guilhermeleobas/prompt.git ${HOME}/git/
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
      echo "activating env: omniscidb nocuda"
      export USE_ENV=omniscidb-cuda-dev
      . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
      ;;
    
    *)
      echo -n "env(): unknown $1"
      ;;
  esac
}

build() {
  echo $1
  case $1 in
    omnisci-nocuda)
      cmake -Wno-dev $CMAKE_OPTIONS_NOCUDA \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DENABLE_TESTS=on \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=gold" \
        ${HOME}/git/omniscidb-internal/
      ;;

    omnisci-cuda)
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

    omnisci-nocuda)
      echo "recreate env: nocuda..."
      conda deactivate
      conda activate default
      conda remove --name omniscidb-cpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-cpu-dev.yaml -n omniscidb-cpu-dev
      nocuda-env
      env nocuda
      ;;

    omnisci-cuda)
      echo "activating env: omniscidb nocuda"
      conda deactivate
      conda activate default
      conda remove --name omniscidb-gpu-dev --all -y
      mamba env create --file=~/git/Quansight/pearu-sandbox/conda-envs/omniscidb-dev.yaml -n omniscidb-cuda-dev
      env cuda
      ;;
    
    *)
      echo -n "env: unknown $1"
      ;;
  esac
}

register_goto() {
  goto -r pytorch ~/git/Quansight/pytorch
  goto -r rbc ~/git/rbc
  goto -r omnisci ~/git/omniscidb-internal
  goto -r omnisci-nocuda ~/git/build-nocuda
  goto -r omnisci-cuda ~/git/build-cuda
  goto -r numba ~/git/numba
  goto -r pearu-sandbox ${HOME}/git/Quansight/pearu-sandbox
}

source ~/git/goto/goto.sh

conda activate default

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
