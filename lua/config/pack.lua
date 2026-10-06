local gh = function(x) return 'https://github.com/' .. x end

local plugins = {
  -- Core Dependencies
  gh("nvim-lua/plenary.nvim"),

  -- UI & Theming
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  gh("nvim-lualine/lualine.nvim"),
  gh("akinsho/bufferline.nvim"),
  gh("folke/trouble.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("folke/which-key.nvim"),
  gh("folke/noice.nvim"),
  gh("MunifTanjim/nui.nvim"), -- Dependency for noice
  gh("rcarriga/nvim-notify"), -- Notification manager for noice
  gh("brenoprata10/nvim-highlight-colors"),

  -- Navigation
  gh("nvim-telescope/telescope.nvim"),
  gh("folke/snacks.nvim"),
  gh("echasnovski/mini.icons"),
  gh("nvim-mini/mini.diff"),
  gh("esmuellert/codediff.nvim"),

  -- Syntax & Code Colorization
  gh("nvim-treesitter/nvim-treesitter"),
  gh("echasnovski/mini.pairs"),
  gh("echasnovski/mini.surround"),

  -- LSP & Formatting
  gh("williamboman/mason.nvim"),
  gh("williamboman/mason-lspconfig.nvim"),
  gh("neovim/nvim-lspconfig"),

  -- Completion
  gh("hrsh7th/nvim-cmp"),
  gh("hrsh7th/cmp-nvim-lsp"),
  gh("hrsh7th/cmp-buffer"),
  gh("hrsh7th/cmp-path"),
  gh("hrsh7th/cmp-emoji"),
  gh("L3MON4D3/LuaSnip"),
}

local ai = require("config.ai")
if ai.enabled then
  plugins[#plugins + 1] = {
    src = gh(ai.integration == "opencode" and "nickjvandyke/opencode.nvim" or "folke/sidekick.nvim"),
    version = "main", -- OpenCode V2 support lives on main, not the V1 release tags.
  }
end
vim.pack.add(plugins, { load = true })
