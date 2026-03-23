set encoding=utf-8          " use UTF-8 internally
syntax on                   " enable syntax highlighting
filetype plugin indent on   " enable filetype detection, filetype plugins, and filetype-based indentation

" Enable 24-bit true color if the terminal supports it
if has('termguicolors') || !&term=~'linux'
  set termguicolors
endif

" ── Backups ───────────────────────────────────────────────────────────────────
set nobackup       " don't create a backup file before overwriting
set nowritebackup  " don't create a temporary backup during writes
set noswapfile     " don't create .swp swap files (rely on git instead)

" ── Search ────────────────────────────────────────────────────────────────────
set incsearch   " highlight matches as you type the search pattern
set hlsearch    " keep all matches highlighted after searching
set ignorecase  " case-insensitive search by default

" ── Indentation ───────────────────────────────────────────────────────────────
set expandtab     " insert spaces instead of tab characters
set tabstop=2     " a tab character displays as 2 spaces wide
set shiftwidth=2  " >> and << indent/outdent by 2 spaces

" Keep a long undo/command history
set history=1000

" Show diffs as vertical splits (default on macOS was horizontal)
set diffopt=filler,vertical

" Show partial commands in the bottom right while typing (e.g. 'd' before 'dw')
set showcmd

" Show cursor line and column number in the status line
set ruler

" Show line numbers relative to cursor position (easier to use with motion commands like 5j)
set relativenumber

" Allow switching away from an unsaved buffer without being forced to save first.
" Vim will warn if you quit with unsaved hidden buffers.
set hidden

" Allow backspace to delete indentation, line breaks, and text before the insert point
set backspace=indent,eol,start

" Show invisible characters: trailing spaces as ·, tabs as two spaces
set list listchars=tab:\ \ ,trail:·

" Reduce the delay after pressing Escape or O (default delay is 1 second)
set timeout timeoutlen=1000 ttimeoutlen=100

" Always show the status bar (0=never, 1=only with splits, 2=always)
set laststatus=2

" Hide the GUI toolbar (relevant when using gvim)
set guioptions-=T

" Automatically reload files that have been changed outside of vim
set autoread

" Use the system clipboard for yank/paste operations.
" On macOS 'unnamed' is used; on Linux 'unnamedplus' uses the X11 clipboard.
set clipboard=unnamedplus
let uname = system("uname -a")
if uname =~ "Darwin"
  set clipboard=unnamed
endif

" Don't show the vim intro/splash screen on startup
set shortmess+=I

" Open new horizontal splits below the current window (more natural)
set splitbelow
" Open new vertical splits to the right of the current window (more natural)
set splitright

" Visual autocomplete dropdown for command mode (e.g. :e <tab>)
set wildmenu
set wildmode=list:longest,list:full
" Exclude version control dirs, macOS metadata, IDE folders, and build output from completion
set wildignore+=*/.hg/*,*/.svn/*.,*/.DS_Store,*/.idea/*,*/.tmp/*,*/target/*

" Briefly highlight the matching bracket/paren/brace when cursor moves to one
set showmatch

" Don't visually wrap long lines at the window edge
set nowrap

" Show this symbol at the start of lines that are continuations of a wrapped line
set showbreak=←←

" Don't redraw the screen while executing macros (improves performance)
set lazyredraw

" Prevent the sh.vim syntax file from adding '.' to iskeyword,
" which would cause 'w' to skip past dots in shell scripts
let g:sh_noisk=1

" ── netrw (built-in file browser, opened with :Ex) ────────────────────────────
let g:netrw_banner      = 0   " hide the banner at the top
let g:netrw_bufsettings = 'relativenumber, number'  " show line numbers in netrw
let g:netrw_liststyle   = 1   " display as a detailed list (1=long, 3=tree)
