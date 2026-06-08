-- Recursively require all Lua files in this directory (except init.lua)
local function load_all()
  local scan_dir = vim.fn.stdpath("config") .. "/lua/config/plugins"
  
  -- Use vim.fs.dir to iterate over files in the directory
  for name, type in vim.fs.dir(scan_dir) do
    if type == "file" and name:match("%.lua$") and name ~= "init.lua" then
      local mod_name = name:gsub("%.lua$", "")
      require("config.plugins." .. mod_name)
    end
  end
end

load_all()