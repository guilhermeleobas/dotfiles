
omnisci-nocuda() {
  export USE_ENV=omniscidb-cpu-dev
  . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
}

omnisci-cuda() {
  export USE_ENV=omniscidb-cuda-dev
  . ~/git/Quansight/pearu-sandbox/working-envs/activate-omniscidb-internal-dev.sh
}

pytorch() {
  export USE_CUDA=1
  export USE_DISTRIBUTED=0
  export USE_MKLDNN=1
  export USE_FBGEMM=1
  export USE_NNPACK=1
  export USE_QNNPACK=1
  export USE_XNNPACK=1
  export USE_NCCL=1
  export MAX_JOBS=24
  . ~/git/Quansight/pearu-sandbox/working-envs/activate-pytorch-dev.sh
  # Enable ccache
  export CCACHE_COMPRESS=true
  export CMAKE_C_COMPILER_LAUNCHER=ccache
  export CMAKE_CXX_COMPILER_LAUNCHER=ccache
  export CMAKE_CUDA_COMPILER_LAUNCHER=ccache
  export LD=$(which lld)
}

update() {
  # if you are updating an existing checkout
  git submodule sync
  git submodule update --init --recursive
}

pyi() {
  python -m tools.pyi.gen_pyi
}

# Use 'skeswa/prompt' which is symlinked to '~/.prompt'.
. ~/.prompt/prompt.bash

# Add git completion to the prompt (comes from 'skeswa/prompt').
. ~/.prompt/git-completion.bash

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source ~/goto/goto.sh
