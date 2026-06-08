local map = vim.keymap.set

-- ============================================================================
-- GENERAL KEYMAPS
-- ============================================================================

-- Window Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Window Resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Buffers
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
map("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Pick Buffer" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle Pin" })
map("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
map("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Delete Other Buffers" })
map("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
map("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })

-- Clear Search
map({ "i", "n", "s" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Save & Quit
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Splits
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window" })

-- ============================================================================
-- WHICH-KEY
-- ============================================================================
map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

-- ============================================================================
-- OPENCODE.NVIM
-- ============================================================================
map({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
map({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "Execute opencode action…" })
map({ "n", "t" }, "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle opencode window" })
map({ "n", "x" }, "<leader>or", function() return require("opencode").operator("@this ") end, { expr = true, desc = "Add range to opencode" })
map("n", "<leader>ol", function() return require("opencode").operator("@this ") .. "_" end, { expr = true, desc = "Add line to opencode" })
map("n", "<leader>ou", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
map("n", "<leader>od", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

-- ============================================================================
-- NOICE.NVIM
-- ============================================================================
map("n", "<leader>sn", "", { desc = "+noice" })
map("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
map("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
map("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
map("n", "<leader>snt", function() require("noice").cmd("telescope") end, { desc = "Noice Picker (Telescope)" })
map({ "n", "i", "s" }, "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, { silent = true, expr = true, desc = "Scroll Forward" })
map({ "n", "i", "s" }, "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, { silent = true, expr = true, desc = "Scroll Backward" })

-- ============================================================================
-- SURROUND (Visual Mode quick wrap)
-- ============================================================================
map("v", '"', 'gsa"', { remap = true, desc = "Wrap with double quotes" })
map("v", "'", "gsa'", { remap = true, desc = "Wrap with single quotes" })
map("v", "`", "gsa`", { remap = true, desc = "Wrap with backticks" })
map("v", "(", "gsa(", { remap = true, desc = "Wrap with parentheses" })
map("v", "[", "gsa[", { remap = true, desc = "Wrap with brackets" })
map("v", "{", "gsa{", { remap = true, desc = "Wrap with braces" })

-- ============================================================================
-- SNACKS.NVIM (Explorer & Picker)
-- ============================================================================
map("n", "<leader>E", function()
  Snacks.explorer()
end, { desc = "Explorer Snacks (root dir)" })
map("n", "<leader>e", function()
  Snacks.explorer({ cwd = vim.fn.getcwd() })
end, { desc = "Explorer Snacks (cwd)" })
map("n", "<leader>fe", function()
  Snacks.explorer()
end, { desc = "Explorer Snacks (root dir)" })
map("n", "<leader>fE", function()
  Snacks.explorer({ cwd = vim.fn.getcwd() })
end, { desc = "Explorer Snacks (cwd)" })

-- ============================================================================
-- TELESCOPE (Find & Search)
-- ============================================================================
map("n", "<leader><space>", "<cmd>Telescope find_files<cr>", { desc = "Find Files (Root Dir)" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files (Root Dir)" })
map("n", "<leader>fF", "<cmd>Telescope find_files cwd=false<cr>", { desc = "Find Files (cwd)" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent" })
map("n", "<leader>fR", "<cmd>Telescope oldfiles cwd=false<cr>", { desc = "Recent (cwd)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map(
  "n",
  "<leader>fc",
  "<cmd>Telescope find_files cwd=" .. vim.fn.stdpath("config") .. "<cr>",
  { desc = "Find Config File" }
)
map("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Files (git-files)" })

map("n", "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", { desc = "Buffers" })
map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Grep (Root Dir)" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Grep (Root Dir)" })
map("n", "<leader>sG", "<cmd>Telescope live_grep cwd=false<cr>", { desc = "Grep (cwd)" })
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer" })
map("n", "<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command History" })
map("n", "<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" })
map("n", "<leader>sH", "<cmd>Telescope highlights<cr>", { desc = "Search Highlight Groups" })
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>sm", "<cmd>Telescope marks<cr>", { desc = "Marks" })
map("n", "<leader>sq", "<cmd>Telescope quickfix<cr>", { desc = "Quickfix List" })
map("n", "<leader>sl", "<cmd>Telescope loclist<cr>", { desc = "Location List" })
map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document Diagnostics" })
map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace Diagnostics" })
map("n", "<leader>uC", "<cmd>Telescope colorscheme<cr>", { desc = "Colorschemes" })

-- Git
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git Status" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })

-- ============================================================================
-- TROUBLE (Diagnostics)
-- ============================================================================
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

-- ============================================================================
-- LSP (Language Server Protocol)
-- ============================================================================
map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
map("n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto T[y]pe Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh Codelens" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })
map("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev Error" })
map("n", "]w", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Next Warning" })
map("n", "[w", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Prev Warning" })
