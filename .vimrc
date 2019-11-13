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


let mapleader = " "

syntax enable
hi comment ctermfg=lightblue

set encoding=utf-8
set fileencoding=utf8
set fileencodings=utf8
set fileformat=unix

set number
set showmatch
set virtualedit=onemore

" キーバインド

" 上下左右移動
noremap <C-h> <Left>
noremap <C-j> <Down>
noremap <C-k> <Up>
noremap <C-l> <Right>

" ウィンドウの移動
nmap <silent> <Leader>h <C-w>h
nmap <silent> <Leader>j <C-w>j
nmap <silent> <Leader>k <C-w>k
nmap <silent> <Leader>l <C-w>l

" ノーマルモードに変更
inoremap <silent> jj <ESC>

" .vimrcの再読み込み
nnoremap <Leader>; :so ~/.vimrc<Cr>

" カーソル上の単語を選択
nnoremap <silent> <Leader>t "zyiw:let @/ = '\<' . @z . '\>'<CR>:hlsearch<CR>

" ツリーのトグル
nnoremap <silent> <Leader>n :NERDTreeToggle<CR>

" ファイル保存、閉じる
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>


" easy-motion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

" 2文字検索ジャンプ
nmap <Leader>f <Plug>(easymotion-overwin-f2)
" 画面上の行ジャンプ
nmap <Leader>, <Plug>(easymotion-bd-jk)
" 画面上の単語ジャンプ
nmap <Leader>. <Plug>(easymotion-bd-w)


" 全角ペースのハイライト
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

