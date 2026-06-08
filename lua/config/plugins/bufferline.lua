require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    offsets = {
      {
        filetype = "snacks_explorer",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
      },
    },
  },
})