local M = {}

-- Resolve globals on each AI initialization, including config reloads.
function M.resolve()
  local settings = {
    enabled = vim.g.ai_enabled ~= false,
    agent = vim.g.ai_agent or "opencode",
    commands = vim.g.ai_commands or { opencode = "opencode2", codex = "codex", claude = "claude" },
  }
  local integration = vim.g.ai_integration or "auto"
  local agents = { opencode = true, codex = true, claude = true }
  if settings.enabled then
    assert(agents[settings.agent], "Invalid ai_agent")
    assert(integration == "auto" or integration == "sidekick", "Invalid ai_integration")
    local command = settings.commands[settings.agent]
    assert(type(command) == "string" and command ~= "", "Missing AI command")
  end
  settings.integration = "sidekick"
  if integration == "auto" and settings.agent == "opencode" then
    settings.integration = "opencode"
  end
  -- Avoid Sidekick's built-in OpenCode V1 adapter for our V2 CLI.
  settings.tool = settings.agent == "opencode" and "opencode2" or settings.agent
  return settings
end

return M
