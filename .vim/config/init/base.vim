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
nmap <silent> <Leader>h <C-w>h
nmap <silent> <Leader>j <C-w>j
nmap <silent> <Leader>k <C-w>k
nmap <silent> <Leader>l <C-w>l

" 折りたたみ関連
nmap <silent> <Leader><Leader>r zR
nmap <silent> <Leader><Leader>c zM


" インクリメント/デクリメント
nnoremap = <C-a>
nnoremap - <C-x>

" quickfixを閉じる
nmap <silent> <Leader>c :cclose<CR>
