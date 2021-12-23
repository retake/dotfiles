" fuzzy finder関連
let g:ctrlp_map = '<Nop>'
nmap <silent> <Leader><Leader>f :CtrlP<CR>
nnoremap <silent> <Leader>tag :CtrlPTag<CR>

if executable('ag')
  let g:ctrlp_use_caching=0
  let g:ctrlp_max_depth=100
  let g:ctrlp_max_files=100000
  let g:ctrlp_user_command='ag %s --depth -1 -g ""'
endif
