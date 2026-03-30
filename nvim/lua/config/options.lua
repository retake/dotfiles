local opt = vim.opt

-- エンコーディング
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "utf-8"
opt.fileformat = "unix"

-- ファイル
opt.hidden = true       -- 未保存ファイルがあっても別ファイルを開ける
opt.autoread = true     -- 外部変更を自動読み込み
opt.swapfile = false    -- swapファイル無効

-- 表示
vim.cmd("syntax enable")
vim.cmd("colorscheme desert")
opt.number = true
opt.cursorline = true
opt.laststatus = 2
opt.showmatch = true
opt.matchtime = 1
opt.scrolloff = 8
opt.sidescrolloff = 16
opt.display = "lastline"
opt.pumheight = 10
opt.belloff = "all"

-- 編集
opt.shiftwidth = 2
opt.shiftround = true
opt.tabstop = 2
opt.expandtab = true
opt.backspace = "indent,eol,start"
opt.infercase = true
opt.virtualedit = { "onemore", "block" }
opt.foldmethod = "indent"
opt.foldlevel = 1

-- 検索
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.wrapscan = false

-- クリップボード
opt.clipboard = "unnamedplus"

-- 補完
opt.completeopt = { "menuone", "noinsert" }

-- ヘルプ日本語
opt.helplang = "ja"
