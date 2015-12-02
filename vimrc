execut pathogen#infect()
  
set number
syntax on
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab smarttab 
"set autoindent cindent
set smartindent
set clipboard=unnamed
set mouse=a
set ruler


inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

" quick reload .vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set backspace=indent,eol,start

let g:ycm_autoclose_preview_window_after_completion=1

" highlight while searching for a pattern
set hlsearch

set cursorline

"colorscheme desert
colorscheme molokai
"colorscheme material
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
