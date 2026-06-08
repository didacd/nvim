local notify = require("notify")

notify.setup({
  stages = "fade",
  timeout = 3000,
  top_down = true, -- Sets the notifications to stack from the top
  background_colour = "#000000",
})

-- Replace Neovim's default notify with nvim-notify
vim.notify = notify
