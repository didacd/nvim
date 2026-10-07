-- Shell lifecycle and public terminal API.
local M = {}
local terminals = {}
local next_id = 0
local last_used
local refresh_manager

function M.on_change(callback)
  refresh_manager = callback
end

local layouts = {
  horizontal = { position = "bottom", height = 0.3 },
  vertical = { position = "right", width = 0.4 },
  floating = { position = "float", width = 0.85, height = 0.8, border = "rounded" },
}

function M.list()
  terminals = vim.tbl_filter(function(entry)
    return entry.terminal:buf_valid()
  end, terminals)
  return terminals
end

local function current()
  local buf = vim.api.nvim_get_current_buf()
  local previous
  for _, entry in ipairs(M.list()) do
    if entry.terminal.buf == buf then
      return entry
    end
    if entry == last_used then previous = entry end
  end
  return previous
end

local function focus(entry)
  if entry and entry.terminal:buf_valid() then
    last_used = entry
    entry.terminal:show():focus()
  end
end

M.current = current
M.focus = focus

function M.new(layout)
  layout = layout or "vertical"
  next_id = next_id + 1
  local entry = {
    id = next_id,
    name = "Shell " .. next_id,
    layout = layout,
    cwd = vim.fn.getcwd(),
  }
  local win = vim.deepcopy(assert(layouts[layout], "Invalid terminal layout"))
  win.title = " " .. entry.name .. " "
  win.wo = { winbar = " " .. entry.name }
  entry.terminal = require("snacks").terminal.open(nil, {
    cwd = entry.cwd,
    count = 1000 + next_id, -- Separate identities from ad-hoc/default Snacks shells.
    auto_close = false, -- Our cleanup also handles intentionally stopped shells.
    win = win,
  })
  entry.terminal:on("TermClose", function(terminal)
    vim.schedule(function()
      if terminal:buf_valid() then terminal:close() end
      if refresh_manager then refresh_manager() end
    end)
  end, { buf = true })
  terminals[#terminals + 1] = entry
  last_used = entry
  if refresh_manager then refresh_manager() end
  return entry
end

function M.toggle(layout)
  local entry = current()
  if layout and (not entry or entry.layout ~= layout) then
    entry = nil
    local cwd = vim.fn.getcwd()
    for _, candidate in ipairs(M.list()) do
      if candidate.layout == layout and candidate.cwd == cwd then entry = candidate end
    end
  end
  if not entry then
    return M.new(layout)
  end
  last_used = entry
  if entry.terminal:valid() then
    entry.terminal:hide()
  else
    focus(entry)
  end
end

function M.select()
  local entries = M.list()
  if #entries == 0 then
    vim.notify("No shell terminals. Use Space → t → n to create one.", vim.log.levels.INFO)
    return
  end
  vim.ui.select(entries, {
    prompt = "Shell terminals",
    format_item = function(entry)
      local visibility = entry.terminal:valid() and "visible" or "hidden"
      return string.format(" %s · %s · %s · %s", entry.name, entry.layout, visibility, entry.cwd)
    end,
  }, focus)
end

function M.cycle(direction)
  local entries = M.list()
  if #entries == 0 then return end
  local active = current()
  local index = direction > 0 and 0 or 1
  for i, entry in ipairs(entries) do
    if entry == active then index = i; break end
  end
  focus(entries[(index - 1 + direction) % #entries + 1])
end

function M.rename(entry, on_rename)
  entry = entry or current()
  if not entry then return M.select() end
  vim.ui.input({ prompt = "Terminal name: ", default = entry.name }, function(name)
    if not name or name == "" or not entry.terminal:buf_valid() then return end
    entry.name = name
    -- winbar is a statusline expression; escape literal percent signs.
    entry.terminal.opts.wo.winbar = " " .. name:gsub("%%", "%%%%")
    entry.terminal.opts.title = " " .. name .. " "
    if entry.terminal:valid() then entry.terminal:update() end
    if on_rename then on_rename() end
  end)
end

function M.close(entry)
  entry = entry or current()
  if not entry then return end
  local choice = vim.fn.confirm("Close " .. entry.name .. " and stop its shell?", "&Close\n&Keep open", 2)
  if choice == 1 then entry.terminal:close() end
end

function M.manage()
  return require("config.terminals.panel").open(M)
end

function M.statusline()
  local count = #M.list()
  return "" .. (count > 0 and (" " .. count) or "")
end

return M
