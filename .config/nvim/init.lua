require("core.bootstrap")
require("core.options")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "neovim/nvim-lspconfig",
      lazy = false,
      dependencies = {
        { "ms-jpq/coq_nvim", branch = "coq" },
        { "ms-jpq/coq.artifacts", branch = "artifacts" },
        { 'ms-jpq/coq.thirdparty', branch = "3p" }
      },
      config = function()
        local lspconfig = require('lspconfig')
        lspconfig.pyright.setup({
          disableOrganizeImports = true,
        })
        lspconfig.ruff.setup({
          cmd = { "uvx", "ruff", "server" },
          on_attach = function(client)
            -- Enable fix all auto-fixable problems on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("RuffFixAll", { clear = true }),
              pattern = "*.py",
              callback = function()
                -- Apply all auto-fixable code actions
                vim.lsp.buf.code_action({
                  context = { only = { "source.fixAll.ruff" } },
                  apply = true,
                })
                -- Also format the document
                if client.server_capabilities.documentFormattingProvider then
                  vim.lsp.buf.format({ async = false })
                end
              end,
            })
          end,
        })
        lspconfig.ts_ls.setup({
          on_attach = function(client)
            -- Enable format on save
            if client.server_capabilities.documentFormattingProvider then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("Format", { clear = true }),
                pattern = "*.js,*.jsx,*.ts,*.tsx",
                callback = function() vim.lsp.buf.format({ async = false }) end,
              })
            end
          end,
        })
        lspconfig.gopls.setup({
          on_attach = function(client)
            -- Enable format on save
            if client.server_capabilities.documentFormattingProvider then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("Format", { clear = true }),
                pattern = '*.go',
                callback = function() vim.lsp.buf.format() end
              })
            end
          end,
        })
      end,
    },
    {
      "ray-x/go.nvim",
      dependencies = {
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
      },
      config = function()
        require("go").setup()
      end,
      event = {"CmdlineEnter"},
      ft = {"go", 'gomod'},
      build = ':lua require("go.install").update_all_sync()'
    },
    {
      "hashivim/vim-terraform",
      event = "BufRead *.tf,*.tfvars",
      config = function()
        -- Optional: Autoformat terraform files
        vim.g.terraform_fmt_on_save = 1
        vim.g.terraform_align = 1

        -- Enable terraform filetype detection
        vim.cmd([[
          autocmd BufRead,BufNewFile *.tf set filetype=terraform
          autocmd BufRead,BufNewFile *.tfstate set filetype=json
        ]])
      end
    },
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      lazy = false,
      opts = {
        providers = {
          ollama = {
            model = "devstral",
            endpoint = "http://ollama.home",
            timeout = 30000,
          },
          openai = {
            endpoint = "https://openrouter.ai/api/v1",
            model = "moonshotai/kimi-k2",
            api_key_name = "OPENROUTER_API_KEY",
            max_tokens = 8000,
            extra_request_body = {
              temperature = 0.6,
            },
          },
        },
      },
      build = "make",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
    },
    {
      "cgrindel/vim-bazelrc",
      ft = "bazelrc",
      event = "BufRead *.bazelrc",
    },
    {
      "kawre/leetcode.nvim",
      event = "CmdlineEnter",
      build = ":TSUpdate html",
      dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {
        lang = "golang",
        description = {
          position = "top",
        },
      },
    },
    {
      "nvimtools/none-ls.nvim",
      config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.diagnostics.golangci_lint,
          },
        })
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true , notify = false },
})

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"python", "typescript", "go"},
  highlight = { enable = true },
}

vim.g.coq_settings = {
  auto_start = "shut-up",
  display = { icons = { mode = "none" }},
}

vim.keymap.set('n', '<leader>gi', '<cmd>GoImports<CR>', { desc = "Run GoImports" })
vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = "Code Actions" })
