local M = {}
local window
local refresh_window

-- The panel receives the terminal API, avoiding a circular module dependency.
function M.open(terminals)
  if window and window:valid() then
    refresh_window()
    window:focus()
    return window
  end

  local active = terminals.current()
  local entries = {}
  local win

  local function refresh()
    if not win or not win:valid() then return end
    local row = vim.api.nvim_win_get_cursor(win.win)[1]
    entries = terminals.list()
    local lines = {}
    for _, entry in ipairs(entries) do
      local visibility = entry.terminal:valid() and "visible" or "hidden"
      lines[#lines + 1] = string.format(" %s · %s · %s · %s", entry.name, entry.layout, visibility, entry.cwd)
    end
    if #lines == 0 then lines = { "No shell terminals. Press v, h, or f to create one." } end
    vim.bo[win.buf].modifiable = true
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, lines)
    vim.bo[win.buf].modified = false
    vim.bo[win.buf].modifiable = false
    win.opts.height = math.min(#lines, 12)
    win:update()
    vim.api.nvim_win_set_cursor(win.win, { math.min(row, #lines), 0 })
  end

  local function selected()
    return win:valid() and entries[vim.api.nvim_win_get_cursor(win.win)[1]] or nil
  end

  local function create(layout)
    win:close()
    terminals.new(layout)
  end

  win = require("snacks").win({
    text = { "Loading terminals…" },
    relative = "editor",
    position = "float",
    row = -2,
    col = -1,
    width = function() return math.min(72, math.max(1, vim.o.columns - 4)) end,
    height = 1,
    enter = true,
    backdrop = false,
    border = "rounded",
    title = "  Shell terminals ",
    title_pos = "center",
    footer = " Enter:focus  r:rename  c:close  v/h/f:new  q:quit ",
    footer_pos = "center",
    bo = { modifiable = false },
    wo = { cursorline = true, wrap = false },
    keys = {
      ["<CR>"] = function()
        local entry = selected()
        if entry then
          win:close()
          terminals.focus(entry)
        end
      end,
      r = function()
        local entry = selected()
        if entry then terminals.rename(entry, refresh) end
      end,
      c = function()
        local entry = selected()
        if entry then
          terminals.close(entry)
          refresh()
        end
      end,
      v = function() create("vertical") end,
      h = function() create("horizontal") end,
      f = function() create("floating") end,
      q = "close",
      ["<Esc>"] = "close",
    },
  })
  window = win
  refresh_window = refresh
  terminals.on_change(refresh)
  refresh()
  for i, entry in ipairs(entries) do
    if entry == active then
      vim.api.nvim_win_set_cursor(win.win, { i, 0 })
      break
    end
  end
  return win
end

return M
