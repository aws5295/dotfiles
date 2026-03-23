" Auto-install vim-plug if it's missing (e.g. on a fresh machine before install.sh runs)
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" ── Editing ────────────────────────────────────────────────────────────────
Plug 'tpope/vim-surround'              " add/change/delete surrounding brackets, quotes, tags
Plug 'tpope/vim-commentary'            " gc to comment/uncomment lines
Plug 'tpope/vim-repeat'                " makes . (repeat) work with plugin commands
Plug 'wellle/targets.vim'              " additional text objects (e.g. 'in next paren')
Plug 'kana/vim-textobj-user'           " framework for creating custom text objects
Plug 'kana/vim-textobj-entire'         " ae/ie: text objects for the entire file
Plug 'tommcdo/vim-exchange'            " cx: swap two regions of text
Plug 'vim-scripts/ReplaceWithRegister' " gr: replace motion/object with register contents
Plug 'junegunn/vim-easy-align'         " ga: align text around a character (e.g. = or :)
Plug 'terryma/vim-multiple-cursors'    " Ctrl+N: multi-cursor editing like Sublime Text
Plug 'chaoren/vim-wordmotion'          " smarter word motions that understand camelCase and snake_case
Plug 'bronson/vim-visual-star-search'  " * and # work in visual mode (search for selection)
Plug 'ervandew/supertab'               " use Tab for insert completion

" ── Navigation ─────────────────────────────────────────────────────────────
Plug 'easymotion/vim-easymotion'       " s{char}{char}: jump anywhere on screen in 2 keystrokes
Plug 'jlanzarotta/bufexplorer'         " visual buffer list and switcher
Plug 'junegunn/fzf.vim'                " fzf-powered fuzzy search for files, buffers, history, etc.

" ── Appearance ─────────────────────────────────────────────────────────────
Plug 'morhetz/gruvbox'                 " retro groove color scheme
Plug 'itchyny/lightline.vim'           " lightweight configurable status line
Plug 'junegunn/rainbow_parentheses.vim' " colorize matching brackets for readability

call plug#end()

" ── Appearance settings ────────────────────────────────────────────────────
let g:lightline = {'colorscheme': 'wombat'}   " lightline color scheme

let g:gruvbox_contrast_dark = 'hard'     " use the highest contrast dark variant of gruvbox
let g:gruvbox_invert_selection = 0       " don't invert selected text colors

set background=dark
try
  colorscheme gruvbox
catch
  colorscheme default   " fall back to default if gruvbox isn't installed yet
endtry

" Override the color of trailing space markers (defined in options.vim) to a dark red
highlight SpecialKey ctermfg=124 guifg=#af3a03

" ── Plugin settings ────────────────────────────────────────────────────────
" Rainbow parentheses: colorize brackets globally, with extra activation for Lisp-family files
let g:rainbow_active = 1
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END

" Don't exit multiple-cursors mode when pressing Escape in visual or insert mode
let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0

" Add fzf to vim's runtime path so :FZF and related commands are available.
" Checks for manual install (~/.fzf) first, then Homebrew (macOS).
if isdirectory($HOME . '/.fzf')
  set rtp+=~/.fzf
elseif isdirectory('/opt/homebrew/opt/fzf')
  set rtp+=/opt/homebrew/opt/fzf
endif
