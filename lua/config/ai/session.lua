local M = {}

function M.ask(settings, default)
  local integrations = require("config.ai.integrations")
  if integrations.is_open() then
    return require("opencode").ask(default)
  end

  local directory = vim.fn.getcwd()
  require("opencode.server.discovery").get():next(function(server)
    local context = require("opencode.context").new(server)
    return require("opencode.ui.ask").ask(default, context):next(function(input)
      if vim.fn.getcwd() ~= directory then
        error("Project directory changed while asking; retry in the intended project.")
      end
      local text = context:render(input).output:plaintext()
      return server:request("/api/session", "POST", {}):next(function(response)
        local session = assert(response and response.data, "OpenCode did not return a new session")
        return server:prompt(session.id, text):next(function()
          context:clear()
          integrations.open_session(settings, session.id)
        end)
      end)
    end):catch(function(err)
      context:resume()
      return require("opencode.promise").reject(err)
    end)
  end):catch(function(err)
    if err then vim.notify(tostring(err), vim.log.levels.ERROR, { title = "OpenCode Ask" }) end
  end)
end

return M
