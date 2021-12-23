let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive', 'passive_filetypes': ['ruby'] }
let g:syntastic_ruby_checkers = ['rubocop']

nnoremap <Leader>ru :w<CR>:SyntasticCheck<CR>

