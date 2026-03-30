local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ノーマルモードに戻る
map("i", "jj", "<ESC>", { silent = true })
map("i", "jw", "<C-o>:w<CR>", { silent = true })

-- ビジュアルモード: v で行末まで選択
map("v", "v", "$h")

-- 設定再読み込み
map("n", "<Leader>;", ":source $MYVIMRC<CR>")

-- ファイル保存・終了
map("n", "<Leader>w", ":w<CR>", { silent = true })
map("n", "<Leader><Leader>q", ":q<CR>", { silent = true })

-- 矩形選択
map("n", "<Leader>v", "<C-v>", { silent = true })

-- 上下左右移動（インサートモード）
map({ "n", "i", "v" }, "<C-h>", "<Left>")
map({ "n", "i", "v" }, "<C-j>", "<Down>")
map({ "n", "i", "v" }, "<C-k>", "<Up>")
map({ "n", "i", "v" }, "<C-l>", "<Right>")

-- ウィンドウ移動
map("n", "<Leader>h", "<C-w>h", { silent = true })
map("n", "<Leader>j", "<C-w>j", { silent = true })
map("n", "<Leader>k", "<C-w>k", { silent = true })
map("n", "<Leader>l", "<C-w>l", { silent = true })

-- バッファ移動・閉じる
map("n", "<Leader><Leader>k", ":bprev<CR>", { silent = true })
map("n", "<Leader><Leader>j", ":bnext<CR>", { silent = true })
map("n", "<Leader>q", function()
  vim.cmd("update")
  local bufs = vim.fn.filter(vim.fn.range(1, vim.fn.bufnr("$")), "buflisted(v:val)")
  if #bufs == 1 then
    vim.cmd("q")
  else
    vim.cmd("bd")
  end
end, { silent = true })

-- 折りたたみ
map("n", "<CR>", "zo", { silent = true })
map("n", "<Leader><CR>", "zc", { silent = true })
map("n", "<Leader>r", "zR", { silent = true })
map("n", "<Leader><Leader>r", "zM", { silent = true })

-- quickfix
map("n", "<Leader>c", ":cclose<CR>", { silent = true })

-- インデント修正
map("n", "<Leader>in", "vv=", { silent = true })

-- ファイルを分割で開く
map("n", "gf", "<C-w>f", { silent = true })

-- lazygit
map("n", "<Leader>git", ":vert term lazygit<CR>", { silent = true })

-- ターミナルモード
map("t", "<Leader>j", "<C-\\><C-n>")

-- ハイライト消去
map("n", "<Esc><Esc>", ":nohlsearch<CR>", { silent = true })

-- カーソルラインを必要な時だけ表示
local cursorline_group = vim.api.nvim_create_augroup("auto-cursorline", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinLeave" }, {
  group = cursorline_group,
  callback = function() vim.opt_local.cursorline = false end,
})
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = cursorline_group,
  callback = function() vim.opt_local.cursorline = true end,
})
