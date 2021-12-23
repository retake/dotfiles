" Gァイル設定
set encoding=utf-8
set fileencoding=utf8
set fileencodings=utf8
set fileformat=unix

" beep音を消す
set belloff=all

" 保存されていないファイルがあっても別ファイルを開ける
set hidden

" 外部でファイルが変更された時に読み直す
set autoread

" swapファイルを使わない
set noswapfile

syntax enable

" 色設定
colorscheme desert
hi comment ctermfg=lightblue
set cursorline

" 行番号を設定
set number

" ステータス行を常に表示
set laststatus=2

" スペルチェック機能
"set spell
"set spelllang=en,cjk

" 対応するカッコに移動
set showmatch
set matchtime=1

" 最低表示サイズ
set scrolloff=8
set sidescrolloff=16

" 長すぎる行を表示
set display=lastline

" 補完ポップアップの高さを設定
set pumheight=10

" カーソルの行末移動
set virtualedit=onemore

" 矩形選択範囲を拡大
set virtualedit+=block

" 折り畳み
set foldmethod=indent

" 不可視文字を表示する（indentの表示をしているので基本不要）
"set list
"set listchars=tab:>-,trail:.

" シフトコマンド設定
set shiftwidth=2
set shiftround

" 補完時に大文字小文字を判別
set infercase

" カーソルの下線を表示
set cursorline

" インクリメンタルサーチ
set incsearch

" 検索文字列をハイライト
set hlsearch

" 検索時に大文字と小文字を区別しない
set ignorecase

" 最後まで検索した後に先頭に戻らない
set nowrapscan

" タブ入力をスペース入力に置き換え
set expandtab

" タブが占める幅
set tabstop=2

runtime! config/init/**
runtime! config/plugins/**

