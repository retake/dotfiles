  " Dcoker-composeでのテスト用定義。環境が変わったら書き換える
  function! RunLineSpec() abort
    let absolute_path = expand("%:p")
    let relation_path = absolute_path[stridx(absolute_path, "spec/"):]
    let rspec_cmd = 'docker-compose run operator_web bundle exec rspec -f documentation ' . relation_path . ':' . line(".")
    "let rspec_cmd = 'docker compose run operator_web bundle exec rspec --format progress --require /app/quickfix_formatter.rb --format QuickfixFormatter --out quickfix.out spec'
    "let rspec_cmd = 'docker compose run operator_web bundle exec rspec --format progress --require /app/quickfix_formatter.rb --format QuickfixFormatter --out quickfix.out '. relation_path . ":" . line(".")
    execute 'Dispatch' rspec_cmd
  endfunction

  nmap <silent> <Leader>test :call RunLineSpec()<CR>

  function! SpecResultInit() abort
    hi Failures ctermfg=red
    syn match Failures 'Failures:'
    syn match Failures 'failures'
    hi Expected ctermfg=green
    syn match Expected 'expected'
    hi Got ctermfg=red
    syn match Got 'got'
    hi Failed ctermfg=red
    syn match Failed 'FAILED'
    syn match Failed 'failed'
    hi FailedList ctermfg=red
    syn match FailedList 'rspec.*'
    hi Example ctermfg=yellow
    syn match Example 'example'
  endfunction

  augroup vim-rspec
    autocmd!
    autocmd FileType qf call SpecResultInit()
  augroup END

