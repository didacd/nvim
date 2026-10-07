# Neovim dotfiles

> Made with [LazyVim/starter](https://github.com/LazyVim/starter)

## Configuration structure

- `lua/config/ai/`: settings validation, plugin setup, prompts/actions, and AI metrics.
- `lua/config/terminals/`: shell lifecycle and the interactive management panel.
- `lua/config/git/`: Git hunk operations, independent of AI integrations.
- `lua/config/ui/`: shared read-only floating panels.
- `lua/config/plugins/`: plugin setup entry points and lualine configuration.

User preferences remain in `lua/config/options.lua`; global shortcuts remain in
`lua/config/keymaps.lua`. `require("config.ai")` and `require("config.terminals")`
continue to expose the existing APIs through their folders' `init.lua` files.

## Features

- Nerd Font statusline with Git changes, diagnostics, file state, LSP progress,
  selected AI agent, macro recording, search matches, and cursor
  position. Secondary details hide on terminals narrower than 120 columns.
  Click **** beside the filetype to show encoding, line endings, and indentation
  settings in a read-only bottom-right panel (requires mouse support, e.g.
  `:set mouse=a`). Click the icon again or move the cursor to dismiss.
  Click the AI icon for a read-only panel. Connected native OpenCode exposes the
  newest project session's provider/model, token totals, and model context limit.
  Totals are not current context usage or account quota; those metrics, and
  Sidekick provider/token metrics, are shown as unavailable. Panels refresh on click.

- [AI Integration](/docs/AI.md)
- [Window Navigation](/docs/Navigation.md)
- Multiple shell terminals: horizontal, vertical, or floating layouts under
  **Space → t**. Click **** for a bottom-right list: `Enter` focuses the selected
  shell, `r` renames it, and `c` closes it with confirmation.
- [Git Tools](/docs/Git.md)
- Git blame: **Space → g → b** toggles inline author, date, and commit summary
  for the current line. Disabled by default.
