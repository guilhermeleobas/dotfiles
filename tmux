# remap prefix to Control + a
set -g prefix C-a
# bind 'C-a C-a' to type 'C-a'
bind C-a send-prefix
unbind C-b

# use zsh instead gnome-terminal
set-option -g default-shell /bin/zsh

# use 256 term for pretty colors
set -g default-terminal "screen-256color"

# color status bar
set -g status-bg colour235
set -g status-fg white

# highlight current window
set-window-option -g window-status-current-fg black
set-window-option -g window-status-current-bg green

# set color of active pane
set -g pane-border-fg colour235
set -g pane-border-bg black
set -g pane-active-border-fg green
set -g pane-active-border-bg black
