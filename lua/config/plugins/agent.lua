require("mini.diff").setup()
require("config.ai").setup()

require("codediff").setup({
  diff = {
    layout = "side-by-side",
    compact = true,
  },
})
