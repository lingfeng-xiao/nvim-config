# Vim-first: Neovim + Cursor

This is the personal NvChad v2.5 configuration and its Cursor counterpart. Both use [one keymap](vim-first-keymap.json) for the shared high-frequency actions. Neovim implements the actions in `lua/vim_first.lua`; Cursor uses VSCodeVim, Which Key, and the installer in `cursor/`. Editor-specific capabilities such as Cursor Agent are present only in their host.

## Install on Windows

1. Install Neovim 0.12+, Git, Python 3.9+, Cursor, and the Cursor extensions `vscodevim.vim` and `vspacecode.whichkey`.
2. Clone this repository to `%LOCALAPPDATA%\nvim`. The repository bootstraps NvChad v2.5 on first Neovim launch.
3. Run `python cursor\package_cheatsheet_extension.py`, then `cursor --install-extension cursor\vim-first-cheatsheet-0.1.1.vsix` from the repository root.
4. Run `python cursor\install_windows.py` from the repository root. It backs up the existing Cursor User files under `%APPDATA%\Cursor\User\vim-first-backups`, updates only Vim/Which Key settings, merges the keyboard navigation bindings, and generates a local cheatsheet path. Java/JDK, theme, font, proxy, Maven, and Gradle settings are left in place.
5. Reload Cursor. Open a file in Normal mode and press `Space` for Which Key or `Space ch` for the complete sheet.

Neovim loads Which Key with its modern popup and shows Leader choices after 120 ms. Cursor shows the Leader menu immediately in Normal mode; Visual mode has a smaller selection-only menu, and Explorer has a menu whose `e` entry returns to the editor. In Cursor, `Space ?` searches available shortcuts. Both editors generate their labels from the same manifest; `Space ch` opens the complete grouped cheatsheet as a regular text editor. Vim motions, `Ctrl+d/u`, `/`, and `Space bd` work there; the Markdown preview Webview is not used.

The installer checks every Cursor command against the installed Cursor workbench before editing. If a future Cursor version removes a command, the installer stops without changing User files. The generated settings, the local cheatsheet path, backups, and packaged VSIX are deliberately not committed.

## Semantic contract

| Language | Keys | Meaning |
|---|---|---|
| Vim text | `hjkl`, motions, operators, text objects, `/`, `?`, `*`, `#`, `n/N`, `.`, macros, marks | Native Vim |
| Code relation | `gd`, `gD`, `gr`, `gi`, `K` | Definition, declaration, references, implementation, hover |
| Diagnostics | `[d`, `]d` | Previous/next diagnostic in the current file |
| Code editing | `Space ca`, `Space rn` | Code action, rename |
| Workspace | `Space ff`, `Space fg`, `Space fs`, `Space fb` | Files, live text search, workspace symbols, open buffers/editors |
| Explorer | `Space e` | Focus tree; in the tree `Space e`, `q`, or `Esc` returns to editor |
| Buffer | `Space bd` | Close the current buffer/editor |
| Window | `Ctrl+h/j/k/l` in Normal or Explorer; `Space wv/ws` | Move spatial focus; vertical/horizontal split |
| Terminal / Agent return | `Space t`; `Ctrl+Alt+E` | Toggle Terminal; return from any non-editor area to the editor |
| Help | `Space ch` | Shared cheatsheet; `Space` shows Which Key |
| Cursor AI | `Space aa/ai/an/ap/ar`; Visual `Space ac` | Agent, inline edit, new chat, plan, review inline changes; add selection to current chat |

Caps Lock taps `Esc` and holds `Ctrl` at the OS level. The `Ctrl+h/j/k/l` navigation bindings apply to Neovim Normal mode, and to Cursor's Vim Normal editor or non-input Explorer tree only. They leave Insert mode, terminals, and AI input alone. Neovim also retains its native `Ctrl+w` window commands; this is no longer the shared primary window language. NvChad's default keymap is intentionally not loaded because it adds overlapping Leader aliases, delays `Space t`, and maps `<Tab>` over the native `Ctrl+i` jumplist. Flash's `s/S/r/R` overrides have likewise been removed so those native text operations remain available.

`Ctrl+Alt+E` always focuses the active editor group, including when an Agent chat input reports editor text focus. It is the keyboard return path from Agent and Terminal; it is harmless when the editor is already focused.

`Space as` is intentionally unbound: no reliable side-chat command was confirmed in Cursor 3.22.12. `gt/gT` remain native: Neovim switches tab pages and VSCodeVim switches editors. AI keys have no Neovim substitute. The Command Palette remains available for low-frequency commands.

The Cursor command IDs were checked against the local Cursor 3.22.12 workbench. `[d/]d` use the current-editor marker commands, matching Neovim's buffer-local diagnostic navigation. `Space ac` uses Cursor's follow-up action with selection insertion, while `Space an` creates a new chat. Cursor desktop key presses still need a hands-on check when desktop control is available; the current verification covers configuration consistency and Neovim behavior.

When only a keyword or fragment of code is known, use `Space fg`: Cursor opens its live Quick Search picker and Neovim opens Telescope live grep. When a method, class or other symbol name is known, use `Space fs`: both editors ask the language server for workspace symbols in a keyboard-driven picker. `Space fs` requires a language extension/server for the file type; `Space fg` remains useful without one. Both pickers accept typing immediately, `Enter` opens a result, and `Esc` returns to the editor.

The previous repository state is available in Git history at `3017f9007605a9cb0a761b1e39a92563b9f2b158`.
