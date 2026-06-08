require("catppuccin").setup({
  background = { -- map vim's background setting to catppuccin flavors
    light = "latte",
    dark = "mocha",
  },
})
vim.cmd.colorscheme("catppuccin")