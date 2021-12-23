" lspの設定
nmap <silent> <Leader>t :LspDefinition<CR>
nmap <silent> <Leader>r :LspReferences<CR>
nmap <silent> <Leader>i :LspImplementation<CR>

let g:lsp_diagnostics_enabled = 0
"let g:lsp_diagnostics_echo_cursor = 1
"let g:asyncomplete_auto_popup = 1
"let g:asyncomplete_auto_completeopt = 0
"let g:asyncomplete_popup_delay = 300
"let g:lsp_text_edit_enabled = 1

let g:lsp_log_verbose = 0
