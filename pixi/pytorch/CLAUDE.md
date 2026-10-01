# Running PyTorch with pixi

This workspace (`pixi/pytorch/pixi.toml`) defines the pixi environments used to build and
test PyTorch checkouts under `~/git/`. It does not contain PyTorch's source — the source
lives in separate checkouts (e.g. `~/git/pytorch313`, `~/git/pytorch313-copy`), and pixi
tasks operate on `$INIT_CWD` (the directory you invoke `pixi run` from), not this directory.

## Environments

Defined in `[environments]`, one per Python version (+ optional CUDA):

| Environment       | Python | Notes                                  |
|-------------------|--------|-----------------------------------------|
| `pytorch310`      | 3.10   |                                          |
| `pytorch311`      | 3.11   |                                          |
| `pytorch312`      | 3.12   |                                          |
| `pytorch313`      | 3.13   |                                          |
| `pytorch313-cp`   | 3.13   | extra checkout/worktree of the 3.13 env |
| `pytorch313-copy` | 3.13   | extra checkout/worktree of the 3.13 env |
| `pytorch314`      | 3.14   |                                          |
| `pytorch`         | 3.13   | alias, same as `pytorch313`             |
| `pytorch-cuda`    | 3.13   | CUDA 11.8 build (linux-64 only)         |

All environments share `[feature.base]` deps/tasks/env vars; CPU builds default to
`USE_CUDA=0` and disable distributed/NCCL/MKLDNN/etc. (see `[feature.base.activation.env]`).

Environment name == the directory name of the checkout it's meant to be used from
(`~/git/pytorch313` <-> env `pytorch313`, `~/git/pytorch313-copy` <-> env `pytorch313-copy`,
etc). `wenv`/`build` (see below) rely on this to auto-detect which env to use from `pwd`.

## One-time setup for a checkout

```sh
clone pytorch313          # git clone pytorch/pytorch -> ~/git/pytorch313 (any "pytorch*" name works)
create pytorch313         # pixi install -e pytorch313 && pixi workspace register --force
```

`create` runs from `pixi/pytorch/`, installs just that one environment, and registers the
workspace so pixi tasks can be invoked from inside the checkout directory itself (no
`--manifest-path` needed).

To remove/reset an environment: `remove pytorch313` (`pixi clean --workspace pytorch
--environment pytorch313`).

## Everyday use

```sh
cd ~/git/pytorch313
wenv                       # no arg -> infers env name "pytorch313" from $(basename $PWD)
```

`wenv` (defined in `scripts.sh`) runs `pixi shell-hook --workspace pytorch -e pytorch313`
and `eval`s it, activating that pixi environment's shell (conda-like `activate`, but for
pixi). You can also pass the name explicitly: `wenv pytorch313`. It also sets
project-specific env vars (`env_vars pytorch313`): `CUDA_HOME`, `CC`/`CXX`, sanitizer flags
on Linux, `USE_CUDA` (0 unless already set).

Once activated, standard pytorch dev commands work directly (`python`, `pytest`, etc.) —
you don't need `pixi run` after `wenv`.

### Building

```sh
build pytorch313           # from anywhere; or just `build` from inside the checkout dir
```

This runs `spin develop` (not the pixi `build` task below) with the env vars from
`env_vars` already applied. For `pytorch-cuda` it additionally runs `make triton`.

### Without activating a shell

Every environment also exposes pixi tasks (`[feature.base.tasks]`) you can run directly,
as long as the workspace was registered (`create` above) and you're inside the checkout dir:

```sh
pixi run -e pytorch313 build            # pip install -e . -v --no-build-isolation
pixi run -e pytorch313 python           # python
pixi run -e pytorch313 list             # ls test/cpython/v3_13/test_*.py
pixi run -e pytorch313 cpython test_foo # python test/cpython/v3_13/test_foo.py (PYTORCH_TEST_WITH_DYNAMO=1)
pixi run -e pytorch313 test-all         # pytest test/cpython/v3_13/test_*.py   (PYTORCH_TEST_WITH_DYNAMO=1)
```

Per the user's global pixi convention: `pixi run -w <workspace> <command>` — here
`<workspace>` is the *environment* name (`-e`), e.g. `pixi run -e pytorch313 <cmd>`.

## Multiple checkouts / worktrees of the same Python version

Use one of the pre-declared extra environments (`pytorch313-cp`, `pytorch313-copy`) for a
second `pytorch313`-like checkout — `create pytorch313-copy`, then `cd
~/git/pytorch313-copy && wenv`.

For an arbitrary number of cheap, frozen, identical instances of an already-registered
environment (handy for many worktrees), use `pixi-instance` instead (`scripts.sh` /
`pixi-instance.sh`):

```sh
pixi-instance create <name> -w pytorch313   # copies pixi.toml/pixi.lock, installs --frozen
pixi-instance run <name> -- <command...>
pixi-instance shell <name>
pixi-instance list
pixi-instance remove <name>
```

`pixi-instance` installs from the shared pixi cache (hard-linked), so creating an instance
is cheap even though it's a fully separate environment directory under
`${PIXI_HOME:-~/.pixi}/instances/<name>`.
