set nocompatible

filetype off
filetype plugin indent on

set ttyfast

set laststatus=2
set encoding=utf-8
set autoread
set autoindent
set backspace=indent,eol,start
set incsearch
set hlsearch

" Basic vim settings
set hidden
set visualbell
set number
set nobackup
set noswapfile
set noshowmode

" Load color
colors zenburn

" Set the terminal's title
set title

" Global tab width.
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Set to show invisibles (tabs & trailing spaces) & their highlight color
set list listchars=tab:»\ ,trail:·

" Configure spell checking
nmap <silent> <leader>p :set spell!<CR>
set spelllang=en_us

" Set leader to comma
let mapleader = ","

" Default to magic mode when using substitution
cnoremap %s/ %s/\v
cnoremap \>s/ \>s/\v

" Capture current file path into clipboard
function! CaptureFile()
  let @+ = expand('%')
endfunction
map <leader>f :call CaptureFile()<cr>

" Rename current file
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>n :call RenameFile()<cr>

" Strip whitespace on save
fun! <SID>StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfun

command -nargs=0 Stripwhitespace :call <SID>StripTrailingWhitespaces()

" Fix indentation in file
map <leader>i mmgg=G`m<CR>

" Toggle highlighting of search results
nnoremap <leader><space> :nohlsearch<cr>

" Unsmart Quotes
nnoremap guq :%s/\v[“”]/"/g<cr>

if has("autocmd")
  " StripTrailingWhitespaces
  autocmd BufWritePre * Stripwhitespace

" To spell check all git commit messages
  au BufNewFile,BufRead COMMIT_EDITMSG set spell nonumber nolist wrap linebreak

  " Set filetype tab settings
  autocmd FileType python,doctest set ai ts=4 sw=4 sts=4 et

  autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
endif

" From https://github.com/vim-syntastic/syntastic#installpathogen
" See also https://vi.stackexchange.com/questions/613/how-do-i-install-a-plugin-in-vim-vi
execute pathogen#infect()

" Pathogen load
filetype off

filetype plugin indent on
syntax on

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:pymode_python = 'python3'

" From https://realpython.com/vim-and-python-a-match-made-in-heaven/
let python_highlight_all=1
syntax on
