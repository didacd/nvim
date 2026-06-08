-- Options are automatically loaded before vim.pack startup
-- Add any additional options here

-- Set leader keys before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.termguicolors = true -- Essential for modern themes like catppuccin
opt.timeoutlen = 300 -- Decrease mapped sequence wait time (makes which-key snappy)
opt.foldlevel = 99 -- Do not fold code by default when opening a file
opt.foldlevelstart = 99

