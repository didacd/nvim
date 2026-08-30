local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  -- Core Dependencies
  gh("nvim-lua/plenary.nvim"),

  -- UI & Theming
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  gh("nvim-lualine/lualine.nvim"),
  gh("akinsho/bufferline.nvim"),
  gh("folke/trouble.nvim"),
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
}, { load = true })
