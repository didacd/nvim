-- Options are automatically loaded before vim.pack startup
-- Add any additional options here

-- Set leader keys before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- AI integration (restart Neovim after changing these options)
vim.g.ai_enabled = true
vim.g.ai_agent = "opencode" -- "opencode", "codex", or "claude"
vim.g.ai_integration = "auto" -- "auto" uses opencode.nvim for OpenCode; "sidekick" supports all agents
vim.g.ai_commands = { opencode = "opencode2", codex = "codex", claude = "claude" }

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.autoread = true
opt.termguicolors = true -- Essential for modern themes like catppuccin
opt.timeoutlen = 300 -- Decrease mapped sequence wait time (makes which-key snappy)
opt.foldlevel = 99 -- Do not fold code by default when opening a file
opt.foldlevelstart = 99
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Number of spaces a tab counts for
opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
opt.colorcolumn = "80" -- Draw a guide line at column 80 (best-practice line length)
