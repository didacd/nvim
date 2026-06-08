-- Download/Update Parsers via the nvim-treesitter package manager
require("nvim-treesitter").setup()
require("nvim-treesitter").install({
  "bash", "html", "javascript", "json", "lua", "markdown",
  "markdown_inline", "python", "query", "regex", "tsx",
  "typescript", "vim", "yaml", "c"
})

-- Enable Native Treesitter Highlighting and Folding globally (Neovim 0.12+)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function()
    local ok = pcall(vim.treesitter.start)
    if ok then
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
    end
  end,
})