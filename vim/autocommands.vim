" ── Folding ──────────────────────────────────────────────────────────────────
" Use marker-based folding ({{{ and }}} delimit folds) for all files.
" foldlevelstart=0 means all folds are closed when a file is first opened.
autocmd BufRead * setlocal foldmethod=marker
  set foldlevelstart=0

" ── Cursor position ───────────────────────────────────────────────────────────
" When reopening a file, jump back to where the cursor was when the file was last closed
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" ── Comment continuation ──────────────────────────────────────────────────────
" Disable automatic comment continuation when pressing o/O or Enter on a comment line
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" ── matchit ───────────────────────────────────────────────────────────────────
" matchit extends the % key to jump between matching HTML/XML tags (not just brackets)
runtime macros/matchit.vim
autocmd BufReadPre,FileReadPre *.md,*.jsp MatchDebug

" ── Quickfix window ───────────────────────────────────────────────────────────
" Restore Enter to its default behavior in the quickfix window
" (normally Enter is remapped to :w in keybinds.vim)
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" Restore Enter mapping when leaving the command-line window (opened with q:)
silent! autocmd CmdwinEnter * nunmap <cr>
silent! autocmd CmdwinLeave * nnoremap <cr> :w<cr>

" Define a :Wrap command to enable soft word-wrapping (without inserting line breaks)
command! -nargs=* Wrap set wrap linebreak nolist

" ── Filetype overrides ────────────────────────────────────────────────────────
" Treat .md files as Markdown (vim defaults to treating them as Modula-2)
autocmd Bufread,BufNewFile *.md set filetype=markdown
" Treat .bowerrc files as JSON
autocmd Bufread,BufNewFile *.bowerrc set filetype=json

" Markdown-specific settings: soft wrap at window edge, no hard line breaks
autocmd Filetype markdown setlocal wrap linebreak nolist textwidth=0 wrapmargin=0 conceallevel=0 fdm=expr

" Per-filetype indentation overrides (default is 2 spaces from options.vim)
autocmd FileType sh,ruby,yaml,zsh,vim setlocal shiftwidth=2 tabstop=2 expandtab
autocmd FileType java setlocal shiftwidth=4 tabstop=4 expandtab  " Java uses 4-space indentation

" Enable spell checking and wrap git commit messages at 80 characters
autocmd Filetype gitcommit setlocal spell textwidth=80
