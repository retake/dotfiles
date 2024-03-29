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
nnoremap <silent> <Leader><leader>q :q<CR>

nnoremap <silent> <Leader>v <C-v>

" インサートモードで保存
inoremap <silent> jw <C-o>:w<CR>

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

" バッファの設定
nmap <silent> <Leader><leader>k :bprev<CR>
nmap <silent> <Leader><Leader>j :bnext<CR>
"nnoremap <silent> <Leader>q :bd<CR>
nnoremap <silent> <Leader>q :up<CR>:call CloseBuf()<CR>

function! CloseBuf()
  if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    :q
  else
    :bd
  endif
endfunction

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
tnoremap <leader>j <C-\><C-n>
nnoremap <Leader>term :bo terminal ++close /bin/bash --login<CR>

" インデントの自動修正
nmap <silent> <leader>in vv=


" ファイルを開く際に分割にする
nmap <silent> gf <C-w>f

" カーソルラインを必要な時だけ有効にする
augroup vimrc-auto-cursorline
  autocmd!
  autocmd CursorMoved,CursorMovedI,WinLeave * setlocal nocursorline
  autocmd CursorHold,CursorHoldI * setlocal cursorline
augroup END

" lazygitを起動する
nmap <silent> <Leader>git :vert term ++close lazygit<CR>

" 補完windowの設定
set completeopt=menuone,noinsert
