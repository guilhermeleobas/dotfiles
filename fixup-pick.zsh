# fixup commit picker.
# Type `fixup ` and press TAB to fuzzy-pick a commit from the current branch;
# the selected sha is inserted into the line. ctrl-/ toggles a `git show` preview.
# Lists commits not yet on any upstream/* ref (at most 30).

_fixup_pick() {
  if [[ $LBUFFER == fixup\ * || $LBUFFER == fixup ]]; then
    # commits not yet on any upstream/* ref = your local stack (capped at 30)
    local range=(-30 HEAD --not --remotes=upstream)
    local line
    line=$(git log --format='%h%x09%s%x09%ar' "${range[@]}" 2>/dev/null |
           fzf --height 60% --reverse --delimiter '\t' --with-nth 1,2,3 \
               --preview 'git show --stat --color=always {1}' --preview-window hidden \
               --bind 'ctrl-/:toggle-preview' \
               --prompt 'fixup commit> ')
    if [[ -n $line ]]; then
      [[ $LBUFFER == *' ' ]] || LBUFFER+=' '
      LBUFFER+="${line%%$'\t'*}"
    fi
    zle redisplay
  else
    zle "$_fixup_pick_fallback"
  fi
}

# Chain onto whatever TAB was bound to (e.g. the ghstack picker) so normal
# completion still works everywhere else.
_fixup_pick_fallback=${$(bindkey '^I')[(w)2]}
[[ $_fixup_pick_fallback == _fixup_pick || -z $_fixup_pick_fallback ]] \
  && _fixup_pick_fallback=expand-or-complete

zle -N _fixup_pick
bindkey '^I' _fixup_pick
