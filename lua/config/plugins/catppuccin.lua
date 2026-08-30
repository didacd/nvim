require("catppuccin").setup({
  transparent_background = true,
  background = { -- map vim's background setting to catppuccin flavors
    light = "latte",
    dark = "mocha",
  },
})
vim.cmd.colorscheme("catppuccin")
