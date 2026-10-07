local ai = require("config.ai")

local function wide_screen()
  return vim.o.columns >= 120
end

-- Reuse mini.diff's buffer summary instead of running Git on every redraw.
local function diff_counts()
  local summary = vim.b.minidiff_summary
  if not summary or summary.source_name ~= "git" then
    return nil
  end
  return { added = summary.add, modified = summary.change, removed = summary.delete }
end

local function workspace()
  return vim.fs.basename(vim.fn.getcwd())
end

local function show_file_info(_, button)
  if button and button ~= "l" then
    return
  end

  local line_endings = { unix = "LF (Unix)", dos = "CRLF (Windows)", mac = "CR (Mac)" }
  local shiftwidth = vim.bo.shiftwidth == 0 and vim.bo.tabstop or vim.bo.shiftwidth
  local lines = {
    " : " .. (vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding),
    "󰌑 Line endings: " .. (line_endings[vim.bo.fileformat] or vim.bo.fileformat),
    "󰌒 Indentation: " .. (vim.bo.expandtab and "Spaces" or "Tabs"),
    "  Indent width: " .. shiftwidth,
    "  Tab width: " .. vim.bo.tabstop,
  }
  require("config.ui.info-panel").toggle("file", "File info", lines)
end

local function show_ai_info(_, button)
  if button ~= "l" then
    return
  end
  local panel = require("config.ui.info-panel")
  local win = panel.toggle("ai", "AI info", { "Loading AI information…" })
  if win then
    require("config.ai.info").load(function(lines)
      panel.update(win, lines)
    end)
  end
end

local function recording()
  local register = vim.fn.reg_recording()
  return register ~= "" and ("Recording @" .. register) or ""
end

local function ai_status()
  -- Read an already-loaded status module; never connect/start an agent here.
  local status = package.loaded["opencode.events.status"]
  if ai.integration == "opencode" and status then
    return status.icon()
  end
  return "󰚩"
end

require("lualine").setup({
  options = {
    theme = "auto",
    icons_enabled = true,
    globalstatus = true,
    component_separators = { left = "│", right = "│" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_a = {
      { "mode", icon = "" },
    },
    lualine_b = {
      { "branch", icon = "" },
      {
        "diff",
        source = diff_counts,
        symbols = { added = " ", modified = " ", removed = " " },
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
      },
    },
    lualine_c = {
      { workspace, icon = "", cond = wide_screen },
      {
        "filename",
        icon = "󰈔",
        path = 1,
        newfile_status = true,
        symbols = {
          modified = "●",
          readonly = "",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
      { recording, icon = "", color = "DiagnosticError" },
      { "searchcount", icon = "" },
    },
    lualine_x = {
      {
        function() return require("config.terminals").statusline() end,
        on_click = function(_, button)
          if button == "l" then require("config.terminals").manage() end
        end,
      },
      {
        ai_status,
        cond = function() return ai.enabled and wide_screen() end,
        on_click = show_ai_info,
      },
      {
        "lsp_status",
        icon = "",
        cond = wide_screen,
        ignore_lsp = { "opencode_ask" },
        symbols = { done = "", separator = " " },
      },
      { "filetype", colored = true },
      {
        function() return "" end,
        on_click = show_file_info,
        cond = function() return vim.bo.buftype == "" end,
      },
    },
    lualine_y = {
      { "progress", icon = "󰦨" },
    },
    lualine_z = {
      { "location", icon = "" },
    },
  },
  inactive_sections = {
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "location" },
  },
  extensions = { "quickfix", "trouble", "mason" },
})
