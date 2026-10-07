-- Read-only AI session metrics.
local M = {}

local function token_count(value)
  return type(value) == "number" and string.format("%.0f", value) or "Unavailable"
end

-- Refresh on click only. Never discover/start a server or submit a prompt.
function M.load(callback)
  local ai = require("config.ai")
  local lines = {
    "󰚩 CLI: " .. ai.agent,
    " Integration: " .. ai.integration,
  }
  local module = package.loaded["opencode.server"]
  local server = ai.integration == "opencode" and module and module.connected
  if not server then
    lines[#lines + 1] = "Provider/model: Unavailable"
    lines[#lines + 1] = "Token usage: Unavailable"
    lines[#lines + 1] = ai.integration == "opencode"
        and "Use an OpenCode action to connect first."
      or "Sidekick does not expose these metrics."
    callback(lines)
    return
  end

  server:resolve_session():next(function(session)
    local model = session.model
    lines[#lines + 1] = "Session: " .. session.id
    lines[#lines + 1] = "Provider: " .. (model and model.providerID or "Unavailable")
    lines[#lines + 1] = "Model: " .. (model and model.id or "Unavailable")
    local tokens = session.tokens or {}
    local cache = tokens.cache or {}
    lines[#lines + 1] = "Session input tokens: " .. token_count(tokens.input)
    lines[#lines + 1] = "Session output tokens: " .. token_count(tokens.output)
    lines[#lines + 1] = "Reasoning tokens: " .. token_count(tokens.reasoning)
    lines[#lines + 1] = "Cache read/write: " .. token_count(cache.read) .. " / " .. token_count(cache.write)

    return server:request("/api/model", "GET"):next(function(response)
      local limit
      for _, info in ipairs(response and response.data or {}) do
        if model and info.id == model.id and info.providerID == model.providerID then
          limit = info.limit and info.limit.context
          break
        end
      end
      lines[#lines + 1] = "Model context limit: " .. token_count(limit)
    end):catch(function()
      lines[#lines + 1] = "Model context limit: Unavailable"
    end):next(function()
      lines[#lines + 1] = "Context used / account quota: Unavailable"
      lines[#lines + 1] = "Session totals are not context-window usage."
      lines[#lines + 1] = "Session: newest root session in Neovim's cwd."
      callback(lines)
    end)
  end):catch(function()
    callback({ lines[1], lines[2], "Session metrics unavailable; retry after connecting." })
  end)
end

return M
