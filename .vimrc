""" Settings
set nocompatible      " Set compatibility to Vim only.
set modelines=0       " Disable modelines
set encoding=utf-8
let mapleader = ","   " Set leader key

""" Searching
set ignorecase        " Case insensitive
set smartcase         " Use case if any caps are used
set hlsearch          " Highlight search
set incsearch         " Show match as search proceeds

""" Indenting
set tabstop=2         " Set tab width to 2
set shiftwidth=2      " Set indent to 2
set expandtab		      " Replace tabs with spaces
set autoindent        " Enable auto indent
set smartindent       " Enable smart indent

""" Formatting
set number            " Enable line numbers
set relativenumber    " Enable relative line numbers
set textwidth=79      " Width of screen
set colorcolumn=+1    " Vertical ruler
set cursorline        " Highlight current lint
syntax on             " Enable syntax highlighting
set nowrap            " Disable line wrapping
set scrolloff=3       " Minimum lines around cursor displayed
set listchars=tab:▸\ ,trail:•   " Configure Visualize whitespace
set list              " Enable whitespace visualtization
