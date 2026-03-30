return {
  -- ファイラー
  {
    "lambdalisue/fern.vim",
    dependencies = {
      "lambdalisue/fern-git-status.vim",
      "yuki-yano/fern-preview.vim",
      "lambdalisue/fern-renderer-nerdfont.vim",
      "lambdalisue/nerdfont.vim",
      "lambdalisue/glyph-palette.vim",
    },
    config = function()
      vim.g["fern#default_hidden"] = 1
      vim.g["fern#disable_default_mappings"] = 1
      vim.g["fern#renderer"] = "nerdfont"
      vim.g["fern#renderer#nerdfont#indent_markers"] = 1

      vim.keymap.set("n", "<Leader>n", ":Fern . -reveal=% -drawer -toggle -width=30<CR>", { silent = true })

      local function fern_init()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
        vim.opt_local.signcolumn = "no"

        local opts = { silent = true, buffer = true }
        vim.keymap.set("n", "o",         "<Plug>(fern-action-open)", opts)
        vim.keymap.set("n", "<CR>",      "<Plug>(fern-action-open)", opts)
        vim.keymap.set("n", "i",         "<Plug>(fern-action-open:split)", opts)
        vim.keymap.set("n", "s",         "<Plug>(fern-action-open:vsplit)", opts)
        vim.keymap.set("n", "<BS>",      "<Plug>(fern-action-leave)", opts)
        vim.keymap.set("n", "cp",        "<Plug>(fern-action-clipboard-copy)", opts)
        vim.keymap.set("n", "mv",        "<Plug>(fern-action-clipboard-move)", opts)
        vim.keymap.set("n", "pp",        "<Plug>(fern-action-clipboard-paste)", opts)
        vim.keymap.set("n", "rename",    "<Plug>(fern-action-rename)", opts)
        vim.keymap.set("n", "del",       "<Plug>(fern-action-remove)", opts)
        -- fern-preview
        vim.keymap.set("n", "<Leader>p", "<Plug>(fern-action-preview:auto:toggle)", opts)
        vim.keymap.set("n", "l",         "<Plug>(fern-action-preview:scroll:down:half)", opts)
        vim.keymap.set("n", "h",         "<Plug>(fern-action-preview:scroll:up:half)", opts)
        vim.keymap.set("n", "q",         "<Plug>(fern-quit-or-close-preview)", opts)

        -- glyph-palette
        vim.fn["glyph_palette#apply"]()
      end

      local fern_group = vim.api.nvim_create_augroup("fern-settings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = fern_group,
        pattern = "fern",
        callback = fern_init,
      })
    end,
  },

  -- 編集補助
  { "bronson/vim-trailing-whitespace" },
  {
    "rhysd/accelerated-jk",
    config = function()
      vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
      vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
    end,
  },
  {
    "simeji/winresizer",
    config = function()
      vim.keymap.set("n", "<Leader>e", "<C-e>", { silent = true })
    end,
  },
  { "markonm/traces.vim" },
  { "machakann/vim-highlightedyank" },

  -- Syntax
  { "cespare/vim-toml",   ft = "toml" },

  -- ヘルプ日本語化
  { "vim-jp/vimdoc-ja" },

  -- チートシート
  {
    "reireias/vim-cheatsheet",
    config = function()
      vim.g["cheatsheet#cheat_file"] = "~/.cheatsheet.md"
      vim.keymap.set("n", "<Leader><Leader>c", ":Cheat<CR>", { silent = true })
    end,
  },
}
