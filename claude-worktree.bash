# cwt - jump between Claude Code worktrees (<repo>/.claude/worktrees/<name>)
# Usage: cwt            -> fzf picker
#        cwt <TAB>      -> fzf dropdown (plain bash list if fzf missing)
#        cwt repo/name  -> cd directly
#        cwt -l         -> list
CWT_ROOTS="${CWT_ROOTS:-$HOME/git}"

_cwt_list() {  # prints "repo/name<TAB>path"
    local root d repo
    for root in $CWT_ROOTS; do
        for d in "$root"/*/.claude/worktrees/*/; do
            [ -d "$d" ] || continue
            d=${d%/}; repo=${d%/.claude/worktrees/*}
            printf '%s/%s\t%s\n' "${repo##*/}" "${d##*/}" "$d"
        done
    done
}

_cwt_pick() {  # $1 = initial query
    _cwt_list | fzf --height 40% --reverse --select-1 --query "$1" \
        --delimiter '\t' --with-nth 1 --prompt 'worktree> ' \
        --preview 'git -C {2} log --color=always --oneline -8' --preview-window right:60% \
        </dev/tty | cut -f2
}

cwt() {
    local target
    case "$1" in
        -l|--list) _cwt_list | cut -f1; return ;;
        "") command -v fzf >/dev/null || { echo "cwt: fzf not found; pass a name" >&2; return 1; }
            target=$(_cwt_pick "") ;;
        *)  target=$(_cwt_list | awk -F'\t' -v q="$1" '$1==q || $1 ~ ("/" q "$") {print $2; exit}')
            [ -n "$target" ] || target=$(_cwt_pick "$1") ;;
    esac
    [ -n "$target" ] && cd "$target"
}

_cwt_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    if command -v fzf >/dev/null; then
        local pick
        pick=$(_cwt_list | fzf --height 40% --reverse --select-1 --query "$cur" \
            --delimiter '\t' --with-nth 1 --prompt 'worktree> ' </dev/tty | cut -f1)
        [ -n "$pick" ] && COMPREPLY=("$pick")
    else
        COMPREPLY=($(_cwt_list | cut -f1 | grep -F -- "$cur"))
    fi
}
complete -F _cwt_complete cwt
