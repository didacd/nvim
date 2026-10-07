# AI Integration

Edit the AI section in `lua/config/options.lua`, then restart Neovim:

```lua
vim.g.ai_enabled = true
vim.g.ai_agent = "opencode" -- "opencode", "codex", or "claude"
vim.g.ai_integration = "auto" -- or "sidekick"
vim.g.ai_commands = { opencode = "opencode2", codex = "codex", claude = "claude" }
```

`auto` selects `nickjvandyke/opencode.nvim` (V2/main) for OpenCode and
`folke/sidekick.nvim` for Codex or Claude. `sidekick` uses Sidekick for any
selected agent, without Copilot or Next Edit Suggestions. Only the chosen
integration is declared and configured; switching does not delete old plugins.
Commands are executable names/paths, not shell commands with arguments.
The Sidekick alternative registers OpenCode as a custom `opencode2` tool to avoid
its built-in V1 server adapter; prompts are staged through the V2 terminal.

All AI mappings use **Space → o**; which-key labels the selected agent:

| Keys | Action |
| --- | --- |
| `ot` | Toggle selected agent terminal (also in terminal mode) |
| `oa` | Ask with editor context (normal/visual mode) |
| `op` | Choose a contextual prompt (normal/visual mode) |
| `of` | Stage current-file context |
| `ov` | Stage visual selection |
| `od` | Explain diagnostics (normal/visual mode) |
| `oq` | Stage quickfix context |
| `oc` | OpenCode actions/commands (native integration only) |
| `ohs` | Stage the full Git hunk under the cursor in a normal buffer |
| `ohr` | Revert the full hunk to the Git index, after confirmation |
| `ohv` | Toggle the diff overlay in a normal buffer |

Hunk actions use mini.diff against the Git index, regardless of who made the
changes. Staging does not save or commit the file. Reverting changes the buffer
only: undo with `u`, or save with `:w` to persist it. Untracked files without a
Git reference cannot use these hunk actions. Use `[h` / `]h` to navigate mini.diff
hunks, then `Space → o → h → s` to stage or `Space → o → h → r` to revert.

Native OpenCode context actions open editable prompt input; confirming submits
through its API. Sidekick stages text in the selected CLI; submit from the CLI
when ready. The native `oc` action picker also includes actions that execute
immediately. Native OpenCode provides permission prompts, proposed-edit review,
and event-driven refresh; Sidekick leaves approvals to each CLI.

Start Neovim in the intended project directory (or use `:cd` before launching).
Terminal startup and native OpenCode session targeting use Neovim's working
directory. OpenCode targets the most recently updated session for that directory;
avoid multiple competing sessions there. Context actions warn and stop if the
current buffer has unsaved edits, since file references are read from disk.
No automatic saves or permission bypasses are enabled.

Use `<leader>gd` for working-tree review and `<leader>go` for diff overlays.
Run `:checkhealth opencode` or `:checkhealth sidekick` for integration diagnostics.
Sidekick requires Neovim 0.11.2 or newer; all CLIs need their own authentication.

### Verification

Run the configuration/adapter tests without installing plugins or sending prompts:

```sh
nvim --headless -u NONE -l tests/ai.lua
```

Test staging and confirmed reverts using the installed mini.diff plugin in a
disposable Git repository (created under `/tmp/opencode`):

```sh
nvim --headless -u NONE -l tests/hunks.lua
```

After changing agents, manually verify terminal toggle/reuse, selection context,
prompt staging, CLI approvals, and external file refresh in a disposable project.
