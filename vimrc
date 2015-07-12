execute pathogen#infect()

set number
syntax on
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab smarttab 
set autoindent cindent
"set smartindent
set clipboard=unnamed
set mouse=a
set ruler
"colorscheme af
:colorscheme bensday

inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

" quick reload .vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" no more arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" CTRL-Tab is next tab
noremap <C-Tab> :<C-U>tabnext<CR>
inoremap <C-Tab> <C-\><C-N>:tabnext<CR>
cnoremap <C-Tab> <C-C>:tabnext<CR>
" CTRL-SHIFT-Tab is previous tab
noremap <C-S-Tab> :<C-U>tabprevious<CR>
inoremap <C-S-Tab> <C-\><C-N>:tabprevious<CR>
cnoremap <C-S-Tab> <C-C>:tabprevious<CR>
