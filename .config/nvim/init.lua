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
#vim.api.nvim_create_autocmd('BufWritePre', {
#  pattern = '*',
#  command = [[%s/\s\+$//e]]
#})

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
    { "Tsuzat/NeoSolarized.nvim", lazy = false, priority = 1000 },
    {
      "neovim/nvim-lspconfig",
      lazy = false,
      dependencies = {
        { "ms-jpq/coq_nvim", branch = "coq" },
        { "ms-jpq/coq.artifacts", branch = "artifacts" },
        { 'ms-jpq/coq.thirdparty', branch = "3p" }
      },
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
        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
                require('go.format').goimport()
            end,
            group = format_sync_grp,
        })
      end,
      event = {"CmdlineEnter"},
      ft = {"go", 'gomod'},
      build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "NeoSolarized" } },
  -- automatically check for plugin updates
  checker = { enabled = true , notify = false },
})

vim.cmd [[ colorscheme NeoSolarized ]]
