-- Shared read-only statusline popups.
local M = {}
local windows = {}

function M.toggle(id, title, lines)
  local current = windows[id]
  if current and current:valid() then
    current:close()
    return nil
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local win = require("snacks").win({
    text = lines,
    relative = "editor",
    position = "float",
    row = -2,
    col = -1,
    width = function() return math.min(58, math.max(1, vim.o.columns - 4)) end,
    height = #lines,
    backdrop = false,
    enter = false,
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
    bo = { modifiable = false, readonly = true },
    keys = { q = "close", ["<Esc>"] = "close" },
  })
  win:on({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, function(panel)
    panel:close()
  end, { buffer = source_buf })
  windows[id] = win
  return win
end

function M.update(win, lines)
  if not win or not win:valid() then
    return
  end
  vim.bo[win.buf].readonly = false
  vim.bo[win.buf].modifiable = true
  vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, lines)
  vim.bo[win.buf].modified = false
  vim.bo[win.buf].modifiable = false
  vim.bo[win.buf].readonly = true
  win.opts.height = #lines
  win:update()
end

return M
