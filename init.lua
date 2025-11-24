-- ======================
--  General settings
-- ======================

-- File encodings and formats
vim.opt.fileformat = 'unix'

-- ======================
--  Indentation
-- ======================

-- Global tab/indent settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true

-- Python-specific indentation
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.py",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
  end
})

-- Lua-specific indentation
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end
})

-- ======================
--  UI and visuals
-- ======================

vim.opt.list = true
vim.opt.listchars = { tab = '=>-', trail = '~' }

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.showcmd = true
vim.opt.showmode = false

vim.opt.termguicolors = true

-- ======================
--  Files, backups, undo
-- ======================

vim.opt.errorbells = false
vim.opt.visualbell = true
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undofile = true

-- ======================
--  Searching
-- ======================

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ======================
-- Keymaps
-- ======================

-- Clear search highlight on Enter
vim.keymap.set('n', '<CR>', '<cmd>nohlsearch<CR>', { silent = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
-- Folds
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- Save and restore folds automatically
vim.api.nvim_create_autocmd("BufWinLeave", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Skip special, unnamed, or plugin buffers
    if vim.bo[buf].buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! mkview")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Skip special, unnamed, or plugin buffers
    if vim.bo[buf].buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! loadview")
    end
  end,
})

-- ======================
-- Plugin manager
-- ======================
require("config.lazy")
