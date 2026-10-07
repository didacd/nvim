# Git Tools

| Keys | Action |
| --- | --- |
| Space → g → d | Open CodeDiff working-tree review |
| Space → g → o | Toggle mini.diff overlay |
| Space → g → b | Toggle inline Git blame (off by default) |
| Space → o → h → s | Stage the full hunk under the cursor |
| Space → o → h → r | Revert the full hunk after confirmation |
| Space → o → h → v | Toggle mini.diff overlay |

The `oh` shortcuts work in normal file buffers when AI integration is enabled.
They operate on Git changes regardless of who made them, not AI proposals.
Use `[h` / `]h` to navigate mini.diff hunks.

Hunks are compared against the Git index. Staging does not save or commit the
file. Reverting changes the buffer only: undo with `u`, or save with `:w` to
persist it. Untracked files without a Git reference cannot use these actions.

In CodeDiff, select a file and press Enter. Move into a code pane to use `]c` /
`[c` for change navigation or Space → h → s to stage a hunk. Press `g?` for
available shortcuts and `q` to close the diff.

## Verification

Test staging and confirmed reverts using the installed mini.diff plugin in a
disposable Git repository (created under `/tmp/opencode`):

```sh
nvim --headless -u NONE -l tests/hunks.lua
```
