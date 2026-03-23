" easymotion/vim-easymotion — jump anywhere on screen with minimal keystrokes.
" Trigger a motion, then type the highlighted label character(s) to jump there.

" s{char}{char}: jump to any location on screen by typing two characters
nmap s <Plug>(easymotion-overwin-f)

" ,L: jump to any line (bidirectional)
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" ,l/,h: jump forward/backward within the current line
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>h <Plug>(easymotion-linebackward)

" ,j/,k: jump to a line below/above the cursor
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" Keep the cursor in the same column when jumping up/down with ,j and ,k
let g:EasyMotion_startofline = 0

" Match target characters case-insensitively
let g:EasyMotion_smartcase = 1
