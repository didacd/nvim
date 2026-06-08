-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_user_command("Reload", function()
  -- Unload all custom configuration modules
  for name, _ in pairs(package.loaded) do
    if name:match("^config%.") then
      package.loaded[name] = nil
    end
  end

  -- Source the main init.lua
  local init_path = vim.fn.stdpath("config") .. "/init.lua"
  local ok, err = pcall(dofile, init_path)
  
  if ok then
    vim.notify("Neovim configuration reloaded successfully", vim.log.levels.INFO, { title = "Config" })
  else
    vim.notify("Error reloading config: " .. tostring(err), vim.log.levels.ERROR, { title = "Config" })
  end
end, { desc = "Fully reload Neovim configuration" })
