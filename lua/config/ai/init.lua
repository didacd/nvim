local M = require("config.ai.settings").resolve()
local tool = M.tool

function M.setup()
  require("config.ai.integrations").setup(M)
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
    require("config.ai.session").ask(M, context.opencode .. ": ")
  else
    stage_sidekick({ msg = context.sidekick })
  end
end

function M.ask()
  if warn_unsaved() then
    return
  end

  if M.integration == "opencode" then
    require("config.ai.session").ask(M, "@this: ")
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

-- Compatibility entry point; the implementation belongs to Git, not AI.
M.hunk = require("config.git.hunks").act

local function toggle_terminal()
  require("config.ai.integrations").toggle(M)
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
