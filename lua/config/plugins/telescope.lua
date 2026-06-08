require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
    winblend = 0,
  },
})
-- Keymap for telescope (Plugin local setup)
vim.keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("data") .. "/site/pack" })
end, { desc = "Find Plugin File" })