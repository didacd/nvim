local M = {}
local native_terminals = {}

local function terminal(settings, toggle)
  -- Match opencode.nvim's session targeting: Neovim's working directory.
  local opts = {
    cwd = vim.fn.getcwd(),
    win = { position = "right", width = 0.4 },
  }
  local snacks = require("snacks")
  local command = { settings.commands[settings.agent] }
  if toggle then
    native_terminals[opts.cwd] = snacks.terminal.toggle(command, opts)
  else
    native_terminals[opts.cwd] = snacks.terminal.open(command, opts)
  end
end

local function setup_opencode(settings)
  local function start()
    -- Discovery needs the service, not an unrelated TUI/session.
    vim.fn.jobstart({ settings.commands[settings.agent], "service", "start" })
  end
  vim.g.opencode_opts = { server = { start = start } }
  -- Assign directly too: the plugin may already have loaded its config.
  local opts = require("opencode.config").opts
  opts.server.start = start
  -- Ellipses open editable input instead of immediately submitting.
  opts.select.prompts = {
    explain = "Explain @this...",
    review = "Review @this...",
    test = "Add tests for @this...",
    fix = "Fix @diagnostics...",
  }
end

local function setup_sidekick(settings)
  local tools = { [settings.tool] = { cmd = { settings.commands[settings.agent] } } }
  require("sidekick").setup({
    nes = { enabled = false },
    cli = {
      tools = tools,
      win = { layout = "right", split = { width = math.floor(vim.o.columns * 0.4) } },
    },
  })
  -- Sidekick merges default tools; retain only the configured agent.
  require("sidekick.config").cli.tools = tools
end

function M.setup(settings)
  if not settings.enabled then return end
  if settings.integration == "opencode" then
    setup_opencode(settings)
  else
    setup_sidekick(settings)
  end
end

function M.toggle(settings)
  if settings.integration == "opencode" then
    local existing = native_terminals[vim.fn.getcwd()]
    if existing and existing:buf_valid() then
      existing:toggle()
    else
      terminal(settings, true)
    end
  else
    require("sidekick.cli").toggle({ name = settings.tool })
  end
end

function M.is_open()
  local existing = native_terminals[vim.fn.getcwd()]
  return existing and existing:valid() or false
end

function M.open_session(settings, id)
  native_terminals[vim.fn.getcwd()] = require("snacks").terminal.open(
    { settings.commands[settings.agent], "--session", id },
    { cwd = vim.fn.getcwd(), win = { position = "right", width = 0.4 } }
  )
end

return M
