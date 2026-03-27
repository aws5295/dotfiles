" ── Core bindings ────────────────────────────────────────────────────────────

nnoremap gl G          " gl: jump to last line (mirrors 'gg' for first line)
vnoremap gl G
onoremap gl G

nnoremap <silent>- :noh<cr>   " -: clear search highlighting
xnoremap <silent>- :noh<cr>

nnoremap <cr> :w<cr>   " Enter: save file (in normal mode)

nnoremap g; g_         " g;: jump to last non-blank character of line
vnoremap g; g_
onoremap g; g_

nnoremap Q q           " Q: record macro (frees up q for quitting)
nnoremap q ZQ          " q: quit without saving

nnoremap ( {           " (: jump to previous paragraph (more natural than {)
xnoremap ( {
nnoremap ) }           " ): jump to next paragraph
xnoremap ) }

xnoremap io iw         " io/ao: 'inner/around object' as aliases for inner/around word
xnoremap ao aw
onoremap io iw
onoremap ao aw

omap ir i[             " ir/ar: 'inner/around rectangle' as aliases for inner/around bracket [...]
omap ar a[
xmap ir i[
xmap ar a[

omap ic i{             " ic/ac: 'inner/around curly' as aliases for inner/around brace {...}
omap ac a{
xmap ic i{
xmap ac a{

nmap , <Leader>        " use , as the leader key
omap , <Leader>
xmap , <Leader>

inoremap jk <Esc>      " jk: exit insert mode (faster than reaching for Escape)

" ── Window operations ─────────────────────────────────────────────────────────

nmap <leader>y <C-W>v  " ,y: open a new vertical split
nmap <leader>x <C-W>s  " ,x: open a new horizontal split
nmap <leader>h <C-W>h  " ,h/j/k/l: move focus between splits
nmap <leader>j <C-W>j
nmap <leader>k <C-W>k
nmap <leader>l <C-W>l

nmap <space>j <C-F>    " Space+j: page down
nmap <space>k <C-B>    " Space+k: page up

" ── junegunn/vim-easy-align ───────────────────────────────────────────────────
" ga: start easy-align (e.g. gaip= to align paragraph on '=')
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

" ── junegunn/fzf.vim ─────────────────────────────────────────────────────────
nnoremap <leader>g :GitFiles<cr>   " ,g: fuzzy search git-tracked files
nnoremap <leader>i :Buffers<cr>    " ,i: fuzzy switch between open buffers
nnoremap <leader>. :Files<cr>      " ,.: fuzzy search all files in cwd
nnoremap gh :History<cr>           " gh: fuzzy search recently opened files

" Show all available fzf mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" fzf-powered insert mode completions
imap <c-x><c-k> <plug>(fzf-complete-word)    " Ctrl+X Ctrl+K: complete word from dictionary
imap <c-x><c-f> <plug>(fzf-complete-path)    " Ctrl+X Ctrl+F: complete file path
imap <c-x><c-j> <plug>(fzf-complete-file-ag) " Ctrl+X Ctrl+J: complete file path via ag
imap <c-x><c-l> <plug>(fzf-complete-line)    " Ctrl+X Ctrl+L: complete entire line

" ── nin-scratch ───────────────────────────────────────────────────────────────
nnoremap gs :NinScratch<CR>   " gs: open a scratch buffer

" ── terryma/vim-multiple-cursors ──────────────────────────────────────────────
" K: create multiple cursors at all matches of the last search pattern
nnoremap <silent> K :MultipleCursorsFind <C-R>/<CR>
vnoremap <silent> K :MultipleCursorsFind <C-R>/<CR>

" ── jlanzarotta/bufexplorer ───────────────────────────────────────────────────
nnoremap mi :BufExplorer<cr>  " mi: open the buffer explorer

" ── ranger.vim ───────────────────────────────────────────────────────────────
nnoremap <BS> :Ranger<cr>     " Backspace: open ranger file manager in the current dir
