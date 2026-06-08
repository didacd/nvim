require("lualine").setup({
  sections = {
    lualine_x = {
      function()
        return "😄"
      end,
    },
  },
})