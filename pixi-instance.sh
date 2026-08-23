# pixi-instance — multiple materialized instances of one pixi environment.
# Each instance copies a workspace's pixi.toml + pixi.lock into its own dir and
# installs there (--frozen, hard-linked from the shared cache, so it's cheap and
# identical). Useful for git worktrees: one env clone per checkout.
#
#   pixi-instance create <name> (-w <registered-workspace> | -m <manifest-path>)
#   pixi-instance run    <name> [pixi run args...] -- <command...>
#   pixi-instance shell  <name> [pixi shell args...]
#   pixi-instance list
#   pixi-instance remove <name>
pixi-instance() {
  local instances_dir="${PIXI_HOME:-$HOME/.pixi}/instances"

  _pin_die() { echo "pixi-instance: $*" >&2; return 1; }

  _pin_manifest_of() {
    local dir="$instances_dir/$1" f
    [[ -d "$dir" ]] || { _pin_die "no instance '$1' (see: pixi-instance list)"; return 1; }
    for f in pixi.toml pyproject.toml; do
      [[ -f "$dir/$f" ]] && { echo "$dir/$f"; return 0; }
    done
    _pin_die "instance '$1' has no manifest"
  }

  local cmd="${1:-}"; shift 2>/dev/null || true
  case "$cmd" in
    create)
      local name="${1:?usage: pixi-instance create <name> (-w <workspace> | -m <manifest-path>)}"
      shift
      local src="" manifest="" f
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -w|--workspace)
            src="$(pixi workspace register list --json |
              python3 -c "import json,sys; print(json.load(sys.stdin)[sys.argv[1]])" "$2" 2>/dev/null)" ||
              { _pin_die "workspace '$2' not in registry (pixi workspace register list)"; return 1; }
            shift 2 ;;
          -m|--manifest-path)
            src="$(cd "$(dirname "$2")" && pwd)"; shift 2 ;;
          *) _pin_die "unknown option: $1"; return 1 ;;
        esac
      done
      [[ -n "$src" ]] || { _pin_die "need -w <workspace> or -m <manifest-path>"; return 1; }
      for f in pixi.toml pyproject.toml; do
        [[ -f "$src/$f" ]] && manifest="$f" && break
      done
      [[ -n "$manifest" ]] || { _pin_die "no pixi.toml/pyproject.toml in $src"; return 1; }
      local dir="$instances_dir/$name"
      [[ -e "$dir" ]] && { _pin_die "instance '$name' already exists ($dir)"; return 1; }
      mkdir -p "$dir"
      cp "$src/$manifest" "$dir/"
      [[ -f "$src/pixi.lock" ]] && cp "$src/pixi.lock" "$dir/"
      echo "$src" > "$dir/.source"
      # --frozen: install exactly the copied lockfile, never re-solve
      pixi install --manifest-path "$dir/$manifest" --frozen &&
        echo "instance '$name' ready: pixi-instance run $name -- <cmd>"
      ;;
    run)
      local m; m="$(_pin_manifest_of "${1:?name required}")" || return 1
      shift; pixi run --manifest-path "$m" "$@"
      ;;
    shell)
      local m; m="$(_pin_manifest_of "${1:?name required}")" || return 1
      shift; pixi shell --manifest-path "$m" "$@"
      ;;
    list|ls)
      local d
      [[ -d "$instances_dir" ]] || return 0
      # command ls instead of a glob: zsh errors on unmatched globs
      command ls -1 "$instances_dir" 2>/dev/null | while read -r d; do
        [[ -d "$instances_dir/$d" ]] || continue
        printf "%s\t(from %s)\n" "$d" "$(cat "$instances_dir/$d/.source" 2>/dev/null || echo '?')"
      done
      ;;
    remove|rm)
      local dir="$instances_dir/${1:?name required}"
      [[ -d "$dir" ]] || { _pin_die "no instance '$1'"; return 1; }
      rm -rf "$dir" && echo "removed instance '$1'"
      ;;
    *)
      sed -n '/^# pixi-instance —/,/^#   pixi-instance remove/p' "${PREFIX}/dotfiles/pixi-instance.sh" | sed 's/^# \{0,1\}//'
      return 1
      ;;
  esac
}
