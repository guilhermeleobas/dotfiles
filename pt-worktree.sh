#!/usr/bin/env bash
# Create (or set up) a PyTorch git worktree that builds fast.
#
#   pt-worktree.sh NAME [BASE]       new worktree at $MAIN.worktrees/NAME on branch NAME,
#                                    from BASE (default upstream/viable/strict)
#   pt-worktree.sh --setup [PATH]    set up an existing worktree (e.g. one created by the
#                                    Claude desktop app); PATH defaults to $PWD
#   --no-build                       stop before `pip install -e .`
# PT_BUILD_ENV="A=1 B=0" exports vars inside the pixi env (overrides its activation).
#
# Setup = init submodules from main's local objects (no network clone), per-worktree
# .venv layered on the pixi env (isolates the shared editable-install pointer), and an
# in-tree build/ so ccache's base_dir (~/git) normalizes paths across worktrees.

set -euo pipefail

MAIN=${PT_MAIN:-$HOME/git/pytorch313}
PIXI_WS=pytorch
PIXI_ENV=${PT_PIXI_ENV:-pytorch313}
GIT=/usr/bin/git

build=1
setup_only=0
args=()
for a in "$@"; do
  case $a in
    --no-build) build=0 ;;
    --setup) setup_only=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) args+=("$a") ;;
  esac
done

if (( setup_only )); then
  wt=$(cd "${args[0]:-$PWD}" && pwd)
else
  name=${args[0]:?usage: pt-worktree.sh NAME [BASE] | --setup [PATH]}
  base=${args[1]:-upstream/viable/strict}
  wt=$MAIN.worktrees/$name
  [[ $base == upstream/* ]] && $GIT -C "$MAIN" fetch upstream "${base#upstream/}"
  $GIT -C "$MAIN" worktree add -b "$name" "$wt" "$base"
fi

# Mirror main's submodule tree: recurse only where main has the nested module, so
# nested repos main doesn't carry (huge ROCm ones) are not cloned. pyproject.toml's
# license-files globs reach into nested submodules (cutlass, cpuinfo, ...).
init_submodules() {
  local dir=$1 refgit=$2 key path name ref args
  [[ -f $dir/.gitmodules ]] || return 0
  while read -r key path; do
    name=${key#submodule.}; name=${name%.path}
    ref=$refgit/modules/$name
    args=()
    [[ -d $ref ]] && args=(--reference "$ref")
    $GIT -C "$dir" submodule update --init "${args[@]}" -- "$path"
    [[ -d $ref ]] && init_submodules "$dir/$path" "$ref"
  done < <($GIT -C "$dir" config -f .gitmodules --get-regexp '^submodule\..*\.path$')
}

init_submodules "$wt" "$MAIN/.git"

pixi_run() { pixi run -w "$PIXI_WS" -e "$PIXI_ENV" "$@"; }

[[ -d $wt/.venv ]] || (cd "$wt" && pixi_run python -m venv --system-site-packages .venv)

if (( build )); then
  cd "$wt"
  PT_BUILD_ENV=${PT_BUILD_ENV:-} pixi_run bash -c 'source .venv/bin/activate && { [[ -z $PT_BUILD_ENV ]] || export $PT_BUILD_ENV; } && pip install -e . -v --no-build-isolation' 2>&1 | tee build.log
  pixi_run ccache -s | sed -n "1,6p"
fi

echo "worktree ready: $wt"
