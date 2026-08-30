require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

if not _G.__snacks_setup_done then
  require("snacks").setup({
    explorer = { enabled = true },
    picker = { enabled = true },
    image = { enabled = true },
    input = { enabled = true },
    terminal = { enabled = true },
  })
  _G.__snacks_setup_done = true
end
