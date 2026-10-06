local M = {
  enabled = vim.g.ai_enabled ~= false,
  agent = vim.g.ai_agent or "opencode",
}

local integration = vim.g.ai_integration or "auto"
local commands = vim.g.ai_commands or { opencode = "opencode2", codex = "codex", claude = "claude" }
if M.enabled then
  assert(({ opencode = true, codex = true, claude = true })[M.agent], "Invalid ai_agent")
  assert(integration == "auto" or integration == "sidekick", "Invalid ai_integration")
  assert(type(commands[M.agent]) == "string" and commands[M.agent] ~= "", "Missing AI command")
end
M.integration = integration == "auto" and M.agent == "opencode" and "opencode" or "sidekick"
-- Do not load Sidekick's built-in OpenCode V1 server adapter for our V2 CLI.
local tool = M.agent == "opencode" and "opencode2" or M.agent

local function terminal(toggle)
  -- Match opencode.nvim's session targeting: Neovim's working directory.
  local opts = { cwd = vim.fn.getcwd(), win = { position = "right", width = 0.4 } }
  local snacks = require("snacks")
  if toggle then
    snacks.terminal.toggle({ commands[M.agent] }, opts)
  else
    snacks.terminal.open({ commands[M.agent] }, opts)
  end
end

function M.setup()
  if not M.enabled then return end
  if M.integration == "opencode" then
    vim.g.opencode_opts = { server = { start = function() terminal(false) end } }
    -- Assign directly as well: the plugin may already have loaded its config.
    local opts = require("opencode.config").opts
    opts.server.start = function() terminal(false) end
    opts.select.prompts = {
      explain = "Explain @this...", review = "Review @this...",
      test = "Add tests for @this...", fix = "Fix @diagnostics...",
    }
  else
    require("sidekick").setup({
      nes = { enabled = false },
      cli = {
        tools = { [tool] = { cmd = { commands[M.agent] } } },
        win = { layout = "right", split = { width = math.floor(vim.o.columns * 0.4) } },
      },
    })
    -- Sidekick merges default tools; retain only the configured agent.
    require("sidekick.config").cli.tools = { [tool] = { cmd = { commands[M.agent] } } }
  end
end

local function warn_unsaved()
  if vim.bo.modified then
    vim.notify("AI file references read from disk; save this buffer first.", vim.log.levels.WARN)
    return true
  end
end

local contexts = {
  file = { "@buffer", "{file}" },
  selection = { "@this", "{selection}" },
  diagnostics = { "Explain @diagnostics", "Explain {diagnostics}" },
  quickfix = { "@quickfix", "{quickfix}" },
}

function M.context(kind)
  if warn_unsaved() then return end
  local context = contexts[kind]
  if M.integration == "opencode" then
    require("opencode").ask(context[1] .. ": ")
  else
    require("sidekick.cli").send({ name = tool, msg = context[2], submit = false })
  end
end

function M.ask()
  if warn_unsaved() then return end
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
        cli.send({ name = tool, text = combined, submit = false })
      end
    end)
  end
end

function M.prompts()
  if warn_unsaved() then return end
  if M.integration == "opencode" then
    -- Trailing ellipses open editable input rather than immediately submitting.
    require("opencode").select({ commands = false })
  else
    local cli = require("sidekick.cli")
    cli.prompt({ cb = function(_, text)
      if text then cli.send({ name = tool, text = text, submit = false }) end
    end })
  end
end

function M.keymaps()
  if not M.enabled then return {} end
  local maps = {
    { { "n", "t" }, "<leader>ot", function()
      if M.integration == "opencode" then terminal(true)
      else require("sidekick.cli").toggle({ name = tool }) end
    end, desc = "Toggle " .. M.agent },
    { { "n", "x" }, "<leader>oa", M.ask, desc = "Ask AI with context" },
    { { "n", "x" }, "<leader>op", M.prompts, desc = "AI prompt picker" },
    { "n", "<leader>of", function() M.context("file") end, desc = "Stage current file" },
    { "x", "<leader>ov", function() M.context("selection") end, desc = "Stage selection" },
    { { "n", "x" }, "<leader>od", function() M.context("diagnostics") end, desc = "Explain diagnostics" },
    { "n", "<leader>oq", function() M.context("quickfix") end, desc = "Stage quickfix" },
  }
  if M.integration == "opencode" then
    maps[#maps + 1] = { "n", "<leader>oc", function() require("opencode").select() end, desc = "OpenCode actions/commands" }
  end
  return maps
end

return M
