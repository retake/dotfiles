return {
  -- LSP基盤
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSPサーバー自動インストール
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      -- 補完エンジン
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- スニペット（nvim-cmpの必須依存）
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- LSP接続時のキーバインド
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, opts)
        end,
      })

      -- mason-lspconfig: インストール済みサーバーを自動セットアップ
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason-lspconfig").setup({
        -- 追加したい言語サーバーをここに列挙する
        -- 例: ensure_installed = { "lua_ls", "ts_ls" }
        ensure_installed = {},
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,
        },
      })

      -- nvim-cmp 補完設定
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]   = cmp.mapping.select_next_item(),
          ["<C-p>"]   = cmp.mapping.select_prev_item(),
          ["<C-d>"]   = cmp.mapping.scroll_docs(4),
          ["<C-u>"]   = cmp.mapping.scroll_docs(-4),
          ["<C-e>"]   = cmp.mapping.abort(),
          ["<CR>"]    = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
