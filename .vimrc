" deinの設定
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif


if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let g:rc_dir    = expand('~/.vim/rc')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on

if dein#check_install()
  call dein#install()
endif


syntax enable
hi comment ctermfg=lightblue
set encoding=utf-8
set fileencoding=utf8
set fileencodings=utf8
set fileformat=unix

set number
set showmatch
set virtualedit=onemore

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
inoremap <silent> <C-h> <esc><C-w>h
inoremap <silent> <C-j> <esc><C-w>j
inoremap <silent> <C-k> <esc><C-w>k
inoremap <silent> <C-l> <esc><C-w>l

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:hlsearch<CR>

nnoremap <Space>. :new ~/.vimrc<Cr>
nnoremap <Space>; :so ~/.vimrc<Cr>

" inoremap <silent> <space>@ <ESC>:w<Cr>i

inoremap <silent> jj <ESC>
inoremap <silent> ｊｊ <ESC>

nnoremap <Space>n :NERDTreeToggle<CR>

nnoremap <Space>q :q<CR>
nnoremap <Space>w :w<CR>



" 全角スペースのハイライト
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
  augroup END
  call ZenkakuSpace()
endif

nmap j <Plug>(accelerated_jk_gj)
nmap k <Plug>(accelerated_jk_gk)

autocmd VimEnter * NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif





colorscheme desert

" set mouse=a

" set paste

set noswapfile
set list

set shiftround

set infercase

set hidden

set incsearch
set hlsearch

set expandtab
set tabstop=2
set shiftwidth=2

vnoremap v $h

" for lightline.vim
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['readonly', 'filename', 'modified', 'anzu']
      \   ]
      \ },
      \ 'component_function': {
      \   'anzu': 'anzu#search_status'
      \ }
      \ }

