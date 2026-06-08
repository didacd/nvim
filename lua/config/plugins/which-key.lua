require("which-key").setup({
  preset = "helix", -- Makes which-key small and usually docked to the bottom right
  delay = function(ctx)
    return ctx.plugin and 0 or 0
  end,
})

-- Add standard prefix groups so which-key labels menus correctly
require("which-key").add({
  { "<leader><tab>", group = "tabs" },
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>e", icon = "󰙅 " },
  { "<leader>E", icon = "󰙅 " },
  { "<leader>f", group = "file/find" },
  { "<leader>g", group = "git" },
  { "<leader>o", group = "opencode" },
  { "<leader>q", group = "quit/session" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui" },
  { "<leader>w", group = "windows" },
  { "<leader>x", group = "diagnostics/quickfix" },
})