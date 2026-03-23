" Fix for broken colors when running vim inside tmux with 256-color mode.
"
" Background Color Erase (BCE) causes color scheme backgrounds to render
" incorrectly inside tmux because tmux intercepts the erase sequences.
" Disabling BCE (set t_ut=) forces vim to redraw backgrounds explicitly.
" See: http://snk.tuxfamily.org/log/vim-256color-bce.html
if &term =~ '256color'
  set t_ut=
endif
