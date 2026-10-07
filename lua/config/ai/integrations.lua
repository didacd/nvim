local M = {}

local function terminal(settings, toggle)
  -- Match opencode.nvim's session targeting: Neovim's working directory.
  local opts = {
    cwd = vim.fn.getcwd(),
    win = { position = "right", width = 0.4 },
  }
  local snacks = require("snacks")
  local command = { settings.commands[settings.agent] }
  if toggle then
    snacks.terminal.toggle(command, opts)
  else
    snacks.terminal.open(command, opts)
  end
end

local function setup_opencode(settings)
  local function start()
    terminal(settings, false)
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
    terminal(settings, true)
  else
    require("sidekick.cli").toggle({ name = settings.tool })
  end
end

return M
