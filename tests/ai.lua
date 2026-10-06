vim.opt.rtp:prepend(vim.fn.getcwd())
local calls = {}
local function record(name)
  return function(value) calls[name] = value end
end
package.preload["sidekick"] = function() return { setup = record("setup") } end
package.preload["sidekick.config"] = function() return { cli = {} } end
package.preload["sidekick.cli"] = function()
  return {
    send = record("send"), toggle = record("toggle"),
    render = function() return "context", { { { "context" } } } end,
    prompt = function(opts) opts.cb("prompt", { { { "prompt" } } }) end,
  }
end
package.preload["opencode"] = function()
  return { ask = record("ask"), select = record("select") }
end
package.preload["opencode.config"] = function()
  return { opts = { server = {}, select = {} } }
end
package.preload["snacks"] = function()
  return { terminal = { toggle = record("terminal"), open = record("open") } }
end

local function load(agent, integration, enabled)
  package.loaded["config.ai"] = nil
  vim.g.ai_enabled = enabled ~= false
  vim.g.ai_agent = agent
  vim.g.ai_integration = integration
  vim.g.ai_commands = { opencode = "opencode2", codex = "codex", claude = "claude" }
  calls = {}
  return require("config.ai")
end

for _, agent in ipairs({ "opencode", "codex", "claude" }) do
  for _, integration in ipairs({ "auto", "sidekick" }) do
    local ai = load(agent, integration)
    local native = agent == "opencode" and integration == "auto"
    local tool = agent == "opencode" and "opencode2" or agent
    assert(ai.integration == (native and "opencode" or "sidekick"))
    ai.setup()
    local old_add = vim.pack.add
    vim.pack.add = function(specs)
      local selected = {}
      for _, spec in ipairs(specs) do
        local src = type(spec) == "table" and spec.src or spec
        if src:match("opencode.nvim$") or src:match("sidekick.nvim$") then
          selected[#selected + 1] = src
          assert(spec.version == "main")
        end
      end
      assert(#selected == 1)
      assert(selected[1]:match(native and "opencode.nvim$" or "sidekick.nvim$"))
    end
    dofile("lua/config/pack.lua")
    vim.pack.add = old_add
    local maps = ai.keymaps()
    assert(#maps == (native and 8 or 7))
    for _, map in ipairs(maps) do assert(map[2]:match("^<leader>o")) end
    maps[1][3]()
    if native then
      assert(calls.terminal[1] == "opencode2")
      vim.g.opencode_opts.server.start()
      assert(calls.open[1] == "opencode2")
    else
      assert(calls.setup.nes.enabled == false)
      assert(calls.setup.cli.tools[tool].cmd[1] == (agent == "opencode" and "opencode2" or agent))
      assert(calls.toggle.name == tool)
    end
    ai.context("file")
    if native then assert(calls.ask == "@buffer: ")
    else assert(calls.send.name == tool and calls.send.submit == false) end
    ai.prompts()
    if native then
      assert(calls.select.commands == false)
      for _, prompt in pairs(require("opencode.config").opts.select.prompts) do
        assert(prompt:match("%.%.%.$"))
      end
    else assert(calls.send.submit == false) end
    local old_input = vim.ui.input
    vim.ui.input = function(_, cb) cb("question") end
    ai.ask()
    vim.ui.input = old_input
    if native then assert(calls.ask == "@this: ")
    else assert(calls.send.text[#calls.send.text][1][1] == "question") end
    vim.bo.modified = true
    calls.ask, calls.send = nil, nil
    local old_notify = vim.notify
    vim.notify = record("warning")
    ai.context("file")
    vim.notify = old_notify
    vim.bo.modified = false
    assert(calls.warning and not calls.ask and not calls.send)
  end
end
local disabled = load("invalid", "invalid", false)
disabled.setup()
assert(#disabled.keymaps() == 0 and next(calls) == nil)
local old_add = vim.pack.add
vim.pack.add = function(specs)
  for _, spec in ipairs(specs) do
    local src = type(spec) == "table" and spec.src or spec
    assert(not src:match("opencode.nvim$") and not src:match("sidekick.nvim$"))
  end
end
dofile("lua/config/pack.lua")
vim.pack.add = old_add
assert(not pcall(load, "invalid", "auto"))
assert(not pcall(load, "opencode", "invalid"))
print("AI configuration/adapter tests passed")
