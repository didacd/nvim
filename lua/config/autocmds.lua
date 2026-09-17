-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local agent_reload = vim.api.nvim_create_augroup("agent_reload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = agent_reload,
  command = "checktime",
  desc = "Reload files changed by external agents",
})

-- ansible-language-server deliberately only attaches to `yaml.ansible`.
-- Detect that filetype from Ansible-specific YAML keys/FQCNs, with path
-- conventions as a fallback for variable and role files that are plain YAML.
local function is_ansible_yaml(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local extension = name:match("%.([^./]+)$")

  if extension == "ansible" then
    return true
  end
  if extension ~= "yml" and extension ~= "yaml" then
    return false
  end

  local normalized_name = name:gsub("\\", "/")
  if normalized_name:match("/(group_vars|host_vars|tasks|handlers|roles|playbooks)/") then
    return true
  end

  local ansible_keys = {
    hosts = true,
    tasks = true,
    pre_tasks = true,
    post_tasks = true,
    handlers = true,
    gather_facts = true,
    vars_files = true,
    become = true,
    become_user = true,
    remote_user = true,
    import_playbook = true,
    import_tasks = true,
    include_tasks = true,
    delegate_to = true,
    register = true,
    notify = true,
  }

  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match("^#!.*/ansible%-playbook")
      or line:match("ansible%.builtin%.[%w_]+%s*:")
      or line:match("ansible%.legacy%.[%w_]+%s*:")
      or line:match("^%s*[%w_]+%.[%w_]+%.[%w_]+%s*:")
    then
      return true
    end

    local key = line:match("^%s*%-?%s*([%w_]+)%s*:")
    if key and ansible_keys[key] then
      return true
    end
  end

  return false
end

local ansible_filetype = vim.api.nvim_create_augroup("ansible_filetype", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  group = ansible_filetype,
  pattern = { "*.yml", "*.yaml", "*.ansible" },
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "yaml.ansible" and is_ansible_yaml(args.buf) then
      vim.bo[args.buf].filetype = "yaml.ansible"
    end
  end,
  desc = "Detect Ansible YAML and attach Ansible tooling",
})

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
