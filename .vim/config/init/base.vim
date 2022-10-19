" pathの設定（デフォルトで入って居るべきパスが何故か入って居ないため、手動で現在のパスを追加）
set path=$PWD/**
"set path+=$PWD/**

" リーダー設定
let mapleader = " "

vnoremap v $h

" ノーマルモードに変更
inoremap <silent> jj <ESC>

" .vimrcの再読み込み
nnoremap <Leader>; :so ~/.vimrc<Cr>

" ファイル保存、閉じる
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>

nnoremap <silent> <Leader>v <C-v>

" キーバインド
"nmap <silent> <Leader><Leader>c <C-c>

" 上下左右移動
noremap <C-h> <Left>
noremap <C-j> <Down>
noremap <C-k> <Up>
noremap <C-l> <Right>

" ウィンドウの移動
nnoremap <silent> <Leader>h <C-w>h
nnoremap <silent> <Leader>j <C-w>j
nnoremap <silent> <Leader>k <C-w>k
nnoremap <silent> <Leader>l <C-w>l

" 折りたたみ関連
set foldlevel=1

nnoremap <silent> <CR> zo
nnoremap <silent> <Leader><CR> zc
nnoremap <silent> <Leader>r zR
nnoremap <silent> <Leader><Leader>r zM

" インクリメント/デクリメント
nnoremap = <C-a>
nnoremap = <C-x>

" quickfixを閉じる
nnoremap <silent> <Leader>c :cclose<CR>

" ターミナルモードのマッピング
"set termkey=<C-l> " 何故か動かない
tnoremap jj <C-\><C-n>
nnoremap <Leader>term :bo terminal ++close /bin/bash --login<CR>

" インデントの自動修正
nmap <silent> <leader>in vv=


" ファイルを開く際に分割にする
nmap <silent> gf <C-w>f
