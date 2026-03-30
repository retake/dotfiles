return {
  -- カラースキーム
  {
    "chriskempson/vim-tomorrow-theme",
    priority = 1000,
    config = function()
      -- tomorrow-themeはcolorschemeコマンドで適用
      -- vim.cmd("colorscheme Tomorrow-Night") -- 好みに応じて変更
    end,
  },
}
