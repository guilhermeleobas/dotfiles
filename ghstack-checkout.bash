# ghstack checkout PR picker (bash).
# Type `ghstack checkout ` and press TAB to fuzzy-pick one of your open
# ghstack PRs on upstream; the selected PR's URL is inserted into the line.
# ctrl-/ inside fzf toggles a `gh pr view` preview.
# Override the repo with GHSTACK_PICK_REPO (default: pytorch/pytorch).
#
# Source this from ~/.bashrc.

_ghstack_checkout_complete() {
  # Only kick in for `ghstack checkout ...`; fall back to filenames elsewhere
  # (via `-o default` below, which applies when COMPREPLY stays empty).
  [[ ${COMP_WORDS[1]} == checkout ]] || return 0

  local repo=${GHSTACK_PICK_REPO:-pytorch/pytorch}
  # Stack membership comes from the "Stack from ghstack" list in each PR
  # body: lines like `* __->__ #191541` / `* #191540`, topmost PR first.
  local jq_group='
    def stackof: [ (.body // "") | gsub("\r";"") | split("\n")[]
                   | select(test("^\\* (__->__ )?#\\d+\\s*$"))
                   | capture("#(?<n>\\d+)").n | tonumber ];
    [ .[] | select(.headRefName | test("^gh/.*/head$"))
          | {number, title, url, s: stackof}
          | if (.s|length)==0 then .s = [.number] else . end ]
    | group_by(.s[0]) | sort_by(0 - (.[0].s | max))[]
    | (sort_by(. as $p | $p.s | index($p.number) // 0)) as $g
    | ($g | length) as $n
    | range($n) as $j
    | $g[$j]
    | (if $n==1 then "─" elif $j==0 then "╭" elif $j==$n-1 then "╰" else "├" end) as $m
    | "\($m) #\(.number)\t\(.title)\t\(.url)"
  '
  local line
  line=$(gh pr list -R "$repo" --author "@me" --limit 100 \
           --json number,title,url,headRefName,body \
           --jq "$jq_group" \
         | fzf --height 60% --reverse --delimiter $'\t' --with-nth 1,2 \
               --preview "gh pr view {3}" --preview-window hidden \
               --bind 'ctrl-/:toggle-preview' \
               --prompt 'ghstack PR> ')
  [[ -n $line ]] && COMPREPLY=("${line##*$'\t'}")
}

complete -o default -F _ghstack_checkout_complete ghstack
