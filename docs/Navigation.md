# Window Navigation

## Shell terminals

**Space → t** opens the terminal keybinding group (the old standalone toggle is
now **Space → t → t**).

| Keys | Action |
| --- | --- |
| Space → t → t | Toggle the current/last terminal (normal or terminal mode) |
| Space → t → v | Toggle a vertical terminal on the right |
| Space → t → h | Toggle a horizontal terminal below |
| Space → t → f | Toggle a floating terminal |
| Space → t → n | Create another vertical terminal |
| Space → t → s | Select and focus an existing terminal |
| Space → t → m | Interactive bottom-right terminal list |
| Space → t → r | Rename the current/last terminal |
| Space → t → c | Close the current/last terminal, after confirmation |
| Space → t → ] / [ | Focus the next/previous terminal |

Click **** in lualine for the same bottom-right terminal list. Move with `j/k`
or the arrow keys; `Enter` focuses the selected shell, `r` renames it, and `c`
closes it after confirmation. `v/h/f` creates another vertical/horizontal/floating
shell. `q` or `Esc` closes the list without stopping any shells.

The number beside the icon counts
managed shell terminals, including hidden ones. AI and ad-hoc terminals are
managed separately and excluded from this count/picker.

Layout toggles reuse a matching shell in the current working directory; use
the new-terminal action or interactive list to create multiple shells with the
same layout. Hiding preserves the process; closing terminates it. This manager
is scoped to the current Neovim session, not persistent across restarts.

Except for the toggle, use the shortcuts in normal mode: press **Esc twice
quickly** in the terminal first.

## Moving between windows

In normal mode:

| Keys | Action |
| --- | --- |
| Space → w → h | Move left |
| Space → w → j | Move down |
| Space → w → k | Move up |
| Space → w → l | Move right |

These leader mappings avoid Ctrl/Alt combinations that Zellij may intercept.
Ctrl+h/j/k/l are also available if the multiplexer passes them through.

In a Snacks terminal, press **Esc twice quickly** to leave terminal mode before
using normal-mode window navigation. Neovim's standard terminal escape is
**Ctrl+\ then Ctrl+n**. Sidekick also maps **Ctrl+q** to leave terminal mode.
