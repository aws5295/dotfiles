" Change the cursor shape depending on the current vim mode.
" Uses iTerm2 escape sequences (works inside and outside of tmux).
"
" Cursor shapes:
"   N=2 (block)      → normal mode
"   N=6 (beam/pipe)  → insert mode
"   N=4 (underline)  → replace mode
"
" When inside tmux, escape sequences must be wrapped in a tmux passthrough:
"   \ePtmux;\e<sequence>\e\\

if has('gui_running')
  if empty($TMUX)
    " Not inside tmux — send escape sequences directly to the terminal
    let &t_SI = "\<Esc>[6 q"   " SI = start insert mode  → beam cursor
    let &t_EI = "\<Esc>[2 q"   " EI = end insert mode    → block cursor
    let &t_SR = "\<Esc>[4 q"   " SR = start replace mode → underline cursor
  else
    " Inside tmux — wrap sequences in tmux's DCS passthrough
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>[6 q\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>[2 q\<Esc>\\"
    let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>[4 q\<Esc>\\"
  endif
endif
