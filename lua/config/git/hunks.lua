local M = {}

local function hunk_range(hunks, line)
  for _, hunk in ipairs(hunks) do
    -- Deleted hunks can start at line zero and have no buffer lines.
    local first = math.max(hunk.buf_start, 1)
    local last = math.max(first, hunk.buf_start + hunk.buf_count - 1)
    if first <= line and line <= last then
      return first, last
    end
  end
end

function M.act(action)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" then
    return vim.notify("Hunk actions require a normal file buffer.", vim.log.levels.WARN)
  end
  local diff = require("mini.diff")
  local data = diff.get_buf_data(buf)
  if not data or not data.ref_text or not data.summary or data.summary.source_name ~= "git" then
    return vim.notify("No Git diff available for this buffer.", vim.log.levels.WARN)
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local first, last = hunk_range(data.hunks, line)
  if not first then
    return vim.notify("No hunk under the cursor.", vim.log.levels.INFO)
  end
  if action == "reset" then
    local choice = vim.fn.confirm("Revert this hunk to the Git index? (Buffer only)", "&Revert\n&Cancel", 2)
    if choice ~= 1 then
      return
    end
  end
  diff.do_hunks(buf, action, { line_start = first, line_end = last })
end

return M
