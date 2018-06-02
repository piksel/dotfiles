# vim: set ft=conf

set default-terminal tmux
setw -g xterm-keys on
status-left "#[fg=colour15,bg=colour55,nobold]  #h #[fg=colour55,bg=colour234,nobold] "
status-left-length 20
status-left-style bg=black
status-position top
status-right "#(eval ~/.dotfiles/bin/tmux-airline.sh `tmux display -p "#{client_width}"`)"
status-right-length 150
status-right-style default
status-style fg=colour231,bg=colour234
status-utf8 on
window-status-current-format "#[bg=colour234,fg=colour235]#[fg=colour7,bg=colour235]  #I. #W  #[bg=colour234,fg=colour235,nobold]"
window-status-current-style default
window-status-format "#[bg=colour234,fg=colour236]#[fg=colour244,bg=colour236]  #I. #W  #[fg=colour236,bg=colour234,nobold]"
window-status-last-style default
window-status-separator " "
window-status-style fg=colour249,bg=colour233
