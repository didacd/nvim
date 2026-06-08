-- 1. Load core options
require("config.options")

-- 2. Bootstrap plugins via vim.pack
require("config.pack")

-- 3. Setup installed plugins
require("config.plugins")

-- 4. Load keymaps and autocmds
require("config.autocmds")
require("config.keymaps")
