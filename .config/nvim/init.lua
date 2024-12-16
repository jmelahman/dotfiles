-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Personal configurations
vim.opt.compatible = false      -- Set compatibility to Vim only
vim.opt.modelines = 0           -- Disable modelines
vim.opt.encoding = 'utf-8'
vim.opt.spelllang = 'en'        -- English language for spellcheck
vim.opt.spell = true            -- Enable spellcheck by default
vim.opt.signcolumn = "no"       -- Disable vertical gutter
vim.opt.clipboard = "unnamedplus" -- Enable the clipboard

-- Searching
vim.opt.ignorecase = true       -- Case insensitive
vim.opt.smartcase = true        -- Use case if any caps are used
vim.opt.hlsearch = true         -- Highlight search
vim.opt.incsearch = true        -- Show match as search proceeds

-- Indenting
vim.opt.tabstop = 2             -- Set tab width to 2
vim.opt.shiftwidth = 2          -- Set indent to 2
vim.opt.expandtab = true        -- Replace tabs with spaces
vim.opt.autoindent = true       -- Enable auto indent
vim.opt.smartindent = true      -- Enable smart indent

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99          -- Open all folds by default

-- Formatting
vim.opt.number = true           -- Enable line numbers
vim.opt.relativenumber = true   -- Enable relative line numbers
vim.opt.cursorline = true       -- Highlight current line
vim.opt.textwidth = 99          -- Width of screen
vim.opt.colorcolumn = '+1'      -- Vertical ruler
vim.cmd('syntax on')            -- Enable syntax highlighting
vim.opt.wrap = false            -- Disable line wrapping
vim.opt.scrolloff = 3           -- Minimum lines around cursor displayed
vim.opt.listchars = { tab = '▸ ', trail = '•' }  -- Configure Visualize whitespace
vim.opt.list = true             -- Enable whitespace visualization

-- Automatically remove trailing whitespace
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = [[%s/\s\+$//e]]
})

-- Highlighting
vim.cmd('hi clear SpellBad')
vim.cmd('hi SpellBad cterm=underline')

vim.g.coq_settings = {
  auto_start = "shut-up",
  clients = { tabnine = { enabled = true }},
  display = { icons = { mode = "none" }},
}

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
        lspconfig.pyright.setup({})
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
      opts = {},
      -- opts = {
      --   provider = "copilot",
      -- },
      build = "make",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        "zbirenbaum/copilot.lua",
      },
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true , notify = false },
})

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"python", "go", "rust"},
  highlight = { enable = true },
}

vim.cmd [[ colorscheme jvim ]]
