require("mini.surround").setup({
  custom_surroundings = nil,
  highlight_duration = 500,
  mappings = {
    add = 'gsa', -- Add surrounding in Normal and Visual modes
    delete = 'gsd', -- Delete surrounding
    find = 'gsf', -- Find surrounding (to the right)
    find_left = 'gsF', -- Find surrounding (to the left)
    highlight = 'gsh', -- Highlight surrounding
    replace = 'gsr', -- Replace surrounding
    update_n_lines = 'gsn', -- Update `n_lines`
    suffix_last = 'l', -- Suffix to search with "prev" method
    suffix_next = 'n', -- Suffix to search with "next" method
  },
  n_lines = 20,
  respect_selection_type = false,
  search_method = 'cover',
  silent = false,
})

-- Add descriptions to which-key for mini.surround
local wk = require("which-key")
wk.add({
  { "gs", group = "surround" },
  { "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
  { "gsd", desc = "Delete Surrounding" },
  { "gsf", desc = "Find Right Surrounding" },
  { "gsF", desc = "Find Left Surrounding" },
  { "gsh", desc = "Highlight Surrounding" },
  { "gsr", desc = "Replace Surrounding" },
  { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
})