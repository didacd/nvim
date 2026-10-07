local M = {
  enabled = vim.g.ai_enabled ~= false,
  agent = vim.g.ai_agent or "opencode",
}

-- Resolve the user-facing settings once, before plugins are loaded.
local integration = vim.g.ai_integration or "auto"
local commands = vim.g.ai_commands or { opencode = "opencode2", codex = "codex", claude = "claude" }
local supported_agents = { opencode = true, codex = true, claude = true }

if M.enabled then
  assert(supported_agents[M.agent], "Invalid ai_agent")
  assert(integration == "auto" or integration == "sidekick", "Invalid ai_integration")
  assert(type(commands[M.agent]) == "string" and commands[M.agent] ~= "", "Missing AI command")
end
M.integration = "sidekick"
if integration == "auto" and M.agent == "opencode" then
  M.integration = "opencode"
end
-- Do not load Sidekick's built-in OpenCode V1 server adapter for our V2 CLI.
local tool = M.agent == "opencode" and "opencode2" or M.agent

local function open_terminal(toggle)
  -- Match opencode.nvim's session targeting: Neovim's working directory.
  local opts = {
    cwd = vim.fn.getcwd(),
    win = { position = "right", width = 0.4 },
  }
  local snacks = require("snacks")
  if toggle then
    snacks.terminal.toggle({ commands[M.agent] }, opts)
  else
    snacks.terminal.open({ commands[M.agent] }, opts)
  end
end

local function setup_opencode()
  local function start()
    open_terminal(false)
  end

  vim.g.opencode_opts = { server = { start = start } }
  -- Assign directly as well: the plugin may already have loaded its config.
  local opts = require("opencode.config").opts
  opts.server.start = start
  -- Trailing ellipses open editable input rather than immediately submitting.
  opts.select.prompts = {
    explain = "Explain @this...",
    review = "Review @this...",
    test = "Add tests for @this...",
    fix = "Fix @diagnostics...",
  }
end

local function setup_sidekick()
  local tools = { [tool] = { cmd = { commands[M.agent] } } }
  require("sidekick").setup({
    nes = { enabled = false },
    cli = {
      tools = tools,
      win = {
        layout = "right",
        split = { width = math.floor(vim.o.columns * 0.4) },
      },
    },
  })
  -- Sidekick merges default tools; retain only the configured agent.
  require("sidekick.config").cli.tools = tools
end

function M.setup()
  if not M.enabled then
    return
  end

  if M.integration == "opencode" then
    setup_opencode()
  else
    setup_sidekick()
  end
end

local function warn_unsaved()
  if vim.bo.modified then
    vim.notify("AI file references read from disk; save this buffer first.", vim.log.levels.WARN)
    return true
  end
end

local contexts = {
  file = { opencode = "@buffer", sidekick = "{file}" },
  selection = { opencode = "@this", sidekick = "{selection}" },
  diagnostics = { opencode = "Explain @diagnostics", sidekick = "Explain {diagnostics}" },
  quickfix = { opencode = "@quickfix", sidekick = "{quickfix}" },
}

local function stage_sidekick(message)
  message.name = tool
  message.submit = false
  require("sidekick.cli").send(message)
end

function M.context(kind)
  if warn_unsaved() then
    return
  end

  local context = contexts[kind]
  if M.integration == "opencode" then
    require("opencode").ask(context.opencode .. ": ")
  else
    stage_sidekick({ msg = context.sidekick })
  end
end

function M.ask()
  if warn_unsaved() then
    return
  end

  if M.integration == "opencode" then
    require("opencode").ask("@this: ")
  else
    -- Render before opening input so the original editor context is retained.
    local cli = require("sidekick.cli")
    local _, text = cli.render("{file}\n{selection}\n")
    vim.ui.input({ prompt = "Ask " .. M.agent .. ": " }, function(input)
      if input and input ~= "" then
        local combined = vim.deepcopy(text or {})
        combined[#combined + 1] = { { input } }
        stage_sidekick({ text = combined })
      end
    end)
  end
end

function M.prompts()
  if warn_unsaved() then
    return
  end

  if M.integration == "opencode" then
    require("opencode").select({ commands = false })
  else
    local cli = require("sidekick.cli")
    cli.prompt({
      cb = function(_, text)
        if text then
          stage_sidekick({ text = text })
        end
      end,
    })
  end
end

-- Git hunk actions are independent of the selected AI integration.
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

function M.hunk(action)
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

local function toggle_terminal()
  if M.integration == "opencode" then
    open_terminal(true)
  else
    require("sidekick.cli").toggle({ name = tool })
  end
end

-- Bind an action's argument without embedding callbacks in every keymap.
local function bind(action, argument)
  return function()
    action(argument)
  end
end

function M.keymaps()
  if not M.enabled then
    return {}
  end

  local maps = {
    { { "n", "t" }, "<leader>ot", toggle_terminal, desc = "Toggle " .. M.agent },
    { { "n", "x" }, "<leader>oa", M.ask, desc = "Ask AI with context" },
    { { "n", "x" }, "<leader>op", M.prompts, desc = "AI prompt picker" },
    { "n", "<leader>of", bind(M.context, "file"), desc = "Stage current file" },
    { "x", "<leader>ov", bind(M.context, "selection"), desc = "Stage selection" },
    { { "n", "x" }, "<leader>od", bind(M.context, "diagnostics"), desc = "Explain diagnostics" },
    { "n", "<leader>oq", bind(M.context, "quickfix"), desc = "Stage quickfix" },
    { "n", "<leader>ohs", bind(M.hunk, "apply"), desc = "Stage Git hunk" },
    { "n", "<leader>ohr", bind(M.hunk, "reset"), desc = "Revert Git hunk (confirm)" },
    {
      "n", "<leader>ohv",
      function()
        require("mini.diff").toggle_overlay(0)
      end,
      desc = "Toggle diff overlay",
    },
  }
  if M.integration == "opencode" then
    maps[#maps + 1] = {
      "n", "<leader>oc",
      function()
        require("opencode").select()
      end,
      desc = "OpenCode actions/commands",
    }
  end
  return maps
end

return M
