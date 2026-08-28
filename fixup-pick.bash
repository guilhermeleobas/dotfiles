# fixup commit picker (bash).
# Type `fixup ` and press TAB to fuzzy-pick a commit from the current branch;
# the selected sha is inserted into the line. ctrl-/ toggles a `git show` preview.
# Lists commits not yet on any upstream/* ref (at most 30).
#
# Source this from ~/.bashrc (scripts.sh does it).

_fixup_complete() {
  local line
  line=$(git log --format='%h%x09%s%x09%ar' -30 HEAD --not --remotes=upstream 2>/dev/null |
         fzf --height 60% --reverse --delimiter $'\t' --with-nth 1,2,3 \
             --preview 'git show --stat --color=always {1}' --preview-window hidden \
             --bind 'ctrl-/:toggle-preview' \
             --prompt 'fixup commit> ')
  [[ -n $line ]] && COMPREPLY=("${line%%$'\t'*}")
}

complete -F _fixup_complete fixup
