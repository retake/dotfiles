" vim-plug: 未インストール時に自動インストール
let s:plug_path = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:plug_path)
  execute '!curl -fLo ' . s:plug_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" ファイラー
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'yuki-yano/fern-preview.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'
Plug 'ryanoasis/vim-devicons'

" カラースキーム
Plug 'chriskempson/vim-tomorrow-theme'

" 編集補助
Plug 'bronson/vim-trailing-whitespace'
Plug 'rhysd/accelerated-jk'
Plug 'simeji/winresizer'
Plug 'markonm/traces.vim'
Plug 'machakann/vim-highlightedyank'

" Syntax
Plug 'cespare/vim-toml'

" ヘルプ日本語化
Plug 'vim-jp/vimdoc-ja'

" Deno統合
Plug 'vim-denops/denops.vim'

" チートシート
Plug 'reireias/vim-cheatsheet'

call plug#end()

" --- プラグイン設定 ---

" fern
let g:fern#default_hidden=1
let g:fern#disable_default_mappings=1
nnoremap <silent> <Leader>n :Fern . -reveal=% -drawer -toggle -width=30<CR>

function! FernInit() abort
  set norelativenumber
  set nonumber
  set signcolumn=no
  nnoremap <buffer><expr>
      \ <Plug>(fern-my-open-or-expand-or-collapse)
      \ fern#smart#leaf(
      \   "<Plug>(fern-action-open)",
      \   "<Plug>(fern-action-expand)",
      \   "<Plug>(fern-action-collapse)",
      \ )
  nnoremap <silent> <buffer> o <Plug>(fern-my-open-or-expand-or-collapse)
  nnoremap <silent> <buffer> <cr> <Plug>(fern-my-open-or-expand-or-collapse)
  nnoremap <silent> <buffer> i <Plug>(fern-action-open:split)
  nnoremap <silent> <buffer> s <Plug>(fern-action-open:vsplit)
  nnoremap <silent> <buffer> <backspace> <Plug>(fern-action-leave)
  nnoremap <silent> <buffer> cp <Plug>(fern-action-clipboard-copy)
  nnoremap <silent> <buffer> mv <Plug>(fern-action-clipboard-move)
  nnoremap <silent> <buffer> pp <Plug>(fern-action-clipboard-paste)
  nnoremap <silent> <buffer> rename <Plug>(fern-action-rename)
  nnoremap <silent> <buffer> del <Plug>(fern-action-remove)
endfunction

augroup fern
  autocmd!
  autocmd FileType fern call FernInit()
augroup END

" fern-preview
function! s:fern_settings() abort
  nnoremap <silent> <buffer> <leader>p <Plug>(fern-action-preview:auto:toggle)
  nnoremap <silent> <buffer> l <Plug>(fern-action-preview:scroll:down:half)
  nnoremap <silent> <buffer> h <Plug>(fern-action-preview:scroll:up:half)
  nnoremap <silent> <buffer> <expr> <Plug>(fern-quit-or-close-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:close)", ":q\<CR>")
  nnoremap <silent> <buffer> q <Plug>(fern-quit-or-close-preview)
endfunction

augroup fern-settings
  autocmd!
  autocmd FileType fern call s:fern_settings()
augroup END

" fern-renderer-nerdfont
let g:fern#renderer = "nerdfont"
let g:fern#renderer#nerdfont#indent_markers=1

" glyph-palette
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
augroup END

" accelerated-jk
nnoremap j <Plug>(accelerated_jk_gj)
nnoremap k <Plug>(accelerated_jk_gk)

" winresizer
nmap <silent> <Leader>e <C-e>

" vimdoc-ja
set helplang=ja

" vim-cheatsheet
let g:cheatsheet#cheat_file = '~/.cheatsheet.md'
nnoremap <silent> <leader><leader>c :Cheat<CR>
