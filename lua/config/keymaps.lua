local cursor_diagnostic_group = vim.api.nvim_create_augroup("cursor_diagnostic", { clear = true })
local cursor_diagnostic_enabled = false

local function toggle_cursor_diagnostic()
  cursor_diagnostic_enabled = not cursor_diagnostic_enabled
  vim.api.nvim_clear_autocmds({ group = cursor_diagnostic_group })

  if cursor_diagnostic_enabled then
    vim.api.nvim_create_autocmd("CursorHold", {
      group = cursor_diagnostic_group,
      callback = function()
        if vim.bo.buftype ~= "" then return end
        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        if #vim.diagnostic.get(0, { lnum = line }) > 0 then
          vim.diagnostic.open_float({ scope = "cursor", focusable = false })
        end
      end,
      desc = "Show the cursor diagnostic after a pause",
    })
  end

  vim.notify(
    "Cursor diagnostics " .. (cursor_diagnostic_enabled and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

local keymaps = {
  -- Window navigation
  { "n", "<C-h>", "<C-w>h", desc = "Go to Left Window" },
  { "n", "<C-j>", "<C-w>j", desc = "Go to Lower Window" },
  { "n", "<C-k>", "<C-w>k", desc = "Go to Upper Window" },
  { "n", "<C-l>", "<C-w>l", desc = "Go to Right Window" },

  -- Window resizing
  { "n", "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase Window Height" },
  { "n", "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
  { "n", "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease Window Width" },
  { "n", "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase Window Width" },

  -- Buffers
  { "n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "n", "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "n", "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "n", "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
  { "n", "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  { "n", "<leader>bb", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
  { "n", "<leader>`", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
  { "n", "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
  { "n", "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
  { "n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
  { "n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
  { "n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
  { "n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
  { "n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },

  -- General
  { { "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", desc = "Escape and Clear hlsearch" },
  { { "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", desc = "Save File" },
  { "n", "<leader>qq", "<cmd>qa<cr>", desc = "Quit All" },
  { "n", "<leader>-", "<C-W>s", desc = "Split Window Below" },
  { "n", "<leader>|", "<C-W>v", desc = "Split Window Right" },
  { "n", "<leader>wd", "<C-W>c", desc = "Delete Window" },
  {
    "n",
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer Local Keymaps (which-key)",
  },

  -- Agent workflow
  {
    { "n", "t" },
    "<leader>ot",
    function()
      local cwd = vim.fs.root(0, ".git") or vim.fn.getcwd()
      Snacks.terminal.toggle("opencode2", {
        cwd = cwd,
        win = { position = "right", width = 0.4 },
      })
    end,
    desc = "Toggle OpenCode",
  },

  -- Noice
  { "n", "<leader>sn", "", desc = "+noice" },
  {
    "n",
    "<leader>sna",
    function()
      require("noice").cmd("all")
    end,
    desc = "Noice All",
  },
  {
    "n",
    "<leader>snd",
    function()
      require("noice").cmd("dismiss")
    end,
    desc = "Dismiss All",
  },
  {
    "n",
    "<leader>snh",
    function()
      require("noice").cmd("history")
    end,
    desc = "Noice History",
  },
  {
    "n",
    "<leader>snl",
    function()
      require("noice").cmd("last")
    end,
    desc = "Noice Last Message",
  },
  {
    "n",
    "<leader>snt",
    function()
      require("noice").cmd("telescope")
    end,
    desc = "Noice Picker (Telescope)",
  },
  {
    { "n", "i", "s" },
    "<c-f>",
    function()
      if not require("noice.lsp").scroll(4) then
        return "<c-f>"
      end
    end,
    silent = true,
    expr = true,
    desc = "Scroll Forward",
  },
  {
    { "n", "i", "s" },
    "<c-b>",
    function()
      if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
      end
    end,
    silent = true,
    expr = true,
    desc = "Scroll Backward",
  },

  -- Surround
  { "v", '"', 'gsa"', remap = true, desc = "Wrap with double quotes" },
  { "v", "'", "gsa'", remap = true, desc = "Wrap with single quotes" },
  { "v", "`", "gsa`", remap = true, desc = "Wrap with backticks" },
  { "v", "(", "gsa(", remap = true, desc = "Wrap with parentheses" },
  { "v", "[", "gsa[", remap = true, desc = "Wrap with brackets" },
  { "v", "{", "gsa{", remap = true, desc = "Wrap with braces" },

  -- Snacks explorer
  {
    "n",
    "<leader>E",
    function()
      Snacks.explorer()
    end,
    desc = "Explorer Snacks (root dir)",
  },
  {
    "n",
    "<leader>e",
    function()
      Snacks.explorer({ cwd = vim.fn.getcwd() })
    end,
    desc = "Explorer Snacks (cwd)",
  },
  {
    "n",
    "<leader>fe",
    function()
      Snacks.explorer()
    end,
    desc = "Explorer Snacks (root dir)",
  },
  {
    "n",
    "<leader>fE",
    function()
      Snacks.explorer({ cwd = vim.fn.getcwd() })
    end,
    desc = "Explorer Snacks (cwd)",
  },

  -- Telescope
  { "n", "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
  { "n", "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
  { "n", "<leader>fF", "<cmd>Telescope find_files cwd=false<cr>", desc = "Find Files (cwd)" },
  { "n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
  { "n", "<leader>fR", "<cmd>Telescope oldfiles cwd=false<cr>", desc = "Recent (cwd)" },
  { "n", "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
  {
    "n",
    "<leader>fc",
    "<cmd>Telescope find_files cwd=" .. vim.fn.stdpath("config") .. "<cr>",
    desc = "Find Config File",
  },
  { "n", "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
  { "n", "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Buffers" },
  { "n", "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep (Root Dir)" },
  { "n", "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep (Root Dir)" },
  { "n", "<leader>sG", "<cmd>Telescope live_grep cwd=false<cr>", desc = "Grep (cwd)" },
  { "n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
  { "n", "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
  { "n", "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
  { "n", "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
  { "n", "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
  { "n", "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "n", "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Marks" },
  { "n", "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
  { "n", "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
  { "n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
  { "n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
  { "n", "<leader>ss", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
  { "n", "<leader>uC", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },

  -- Git
  { "n", "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
  { "n", "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
  { "n", "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Review Working Tree" },
  {
    "n",
    "<leader>go",
    function()
      require("mini.diff").toggle_overlay(0)
    end,
    desc = "Toggle Diff Overlay",
  },

  -- Trouble
  { "n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
  { "n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
  { "n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
  { "n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP References/Definitions (Trouble)" },
  { "n", "<leader>ci", "<cmd>Trouble lsp_incoming_calls toggle<cr>", desc = "Incoming Calls (Trouble)" },
  { "n", "<leader>co", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", desc = "Outgoing Calls (Trouble)" },
  { "n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
  { "n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
  {
    "n",
    "<leader>xE",
    "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>",
    desc = "Errors (Trouble)",
  },
  { "n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
  { "n", "<leader>xT", "<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
  {
    "n",
    "[q",
    function()
      if require("trouble").is_open() then
        require("trouble").prev({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Previous Trouble/Quickfix Item",
  },
  {
    "n",
    "]q",
    function()
      if require("trouble").is_open() then
        require("trouble").next({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Next Trouble/Quickfix Item",
  },

  -- LSP
  { "n", "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
  { "n", "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
  { "n", "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
  { "n", "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
  { "n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto T[y]pe Definition" },
  { "n", "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "n", "K", vim.lsp.buf.hover, desc = "Hover" },
  { "n", "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
  { "i", "<c-k>", vim.lsp.buf.signature_help, desc = "Signature Help" },
  { { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
  { "n", "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens" },
  { "n", "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh Codelens" },
  { "n", "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
  {
    "n",
    "<leader>uh",
    function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
    end,
    desc = "Toggle Inlay Hints",
  },
  {
    "n",
    "<leader>uv",
    function()
      vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
    end,
    desc = "Toggle Diagnostic Virtual Text",
  },
  { "n", "<leader>uD", toggle_cursor_diagnostic, desc = "Toggle Cursor Diagnostics" },
  { "n", "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
  {
    "n",
    "<leader>ld",
    function()
      vim.diagnostic.open_float({ scope = "cursor" })
    end,
    desc = "Cursor Diagnostic",
  },
  { "n", "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
  { "n", "[d", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
  {
    "n",
    "]e",
    function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end,
    desc = "Next Error",
  },
  {
    "n",
    "[e",
    function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end,
    desc = "Prev Error",
  },
  {
    "n",
    "]w",
    function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
    end,
    desc = "Next Warning",
  },
  {
    "n",
    "[w",
    function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
    end,
    desc = "Prev Warning",
  },
  { "n", "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
  { "n", "[t", function() require("todo-comments").jump_prev() end, desc = "Prev Todo Comment" },
  { "n", "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
  { "n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
}

for _, keymap in ipairs(keymaps) do
  local opts = {}
  for name, value in pairs(keymap) do
    if type(name) == "string" then
      opts[name] = value
    end
  end

  vim.keymap.set(keymap[1], keymap[2], keymap[3], opts)
end
