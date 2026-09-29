# Vim-first: Neovim + Cursor

This is the personal NvChad v2.5 configuration and its Cursor counterpart. Both use [one keymap](vim-first-keymap.json) for the shared high-frequency actions. Neovim implements the actions in `lua/vim_first.lua`; Cursor uses VSCodeVim, Which Key, and the installer in `cursor/`. Editor-specific capabilities such as Cursor Agent are present only in their host.

## Install on Windows

1. Install Neovim 0.12+, Git, Python 3.9+, Cursor, and the Cursor extensions `vscodevim.vim` and `vspacecode.whichkey`.
2. Clone this repository to `%LOCALAPPDATA%\nvim`. The repository bootstraps NvChad v2.5 on first Neovim launch.
3. Run `python cursor\package_cheatsheet_extension.py`, then `cursor --install-extension cursor\vim-first-cheatsheet-0.1.0.vsix` from the repository root.
4. Run `python cursor\install_windows.py` from the repository root. It backs up the existing Cursor User files under `%APPDATA%\Cursor\User\vim-first-backups`, updates only Vim/Which Key settings, merges the keyboard navigation bindings, and generates a local cheatsheet path. Java/JDK, theme, font, proxy, Maven, and Gradle settings are left in place.
5. Reload Cursor. Open a file in Normal mode and press `Space` for Which Key or `Space ch` for the complete sheet.

The installer checks every Cursor command against the installed Cursor workbench before editing. If a future Cursor version removes a command, the installer stops without changing User files. The generated settings, the local cheatsheet path, backups, and packaged VSIX are deliberately not committed.

## Semantic contract

| Language | Keys | Meaning |
|---|---|---|
| Vim text | `hjkl`, motions, operators, text objects, `/`, `?`, `*`, `#`, `n/N`, `.`, macros, marks | Native Vim |
| Code relation | `gd`, `gD`, `gr`, `gi`, `K` | Definition, declaration, references, implementation, hover |
| Diagnostics | `[d`, `]d` | Previous/next diagnostic in the current file |
| Code editing | `Space ca`, `Space rn` | Code action, rename |
| Workspace | `Space ff`, `Space fg`, `Space fb` | Files, workspace grep, open buffers/editors |
| Explorer | `Space e` | Focus tree; in the tree `Space e`, `q`, or `Esc` returns to editor |
| Buffer | `Space bd` | Close the current buffer/editor |
| Window | `Ctrl+w h/j/k/l`, `Ctrl+w v/s/q` | Vim window navigation, split, close |
| Terminal | `Space tt` | Toggle; `Ctrl+Alt+E` returns to editor |
| Help | `Space ch` | Shared cheatsheet; `Space` shows Which Key |
| Cursor AI | `Space aa/ai/an/ap/ac/ar` | Agent, inline edit, new chat, plan, add selection to current chat, review inline changes |

`Space as` is intentionally unbound: no reliable side-chat command was confirmed in Cursor 3.22.12. `gt/gT` remain native: Neovim switches tab pages and VSCodeVim switches editors. This host distinction is preferable to overriding an established Vim operation. AI keys have no Neovim substitute. The Command Palette remains available for low-frequency commands.

The Cursor command IDs were checked against the local Cursor 3.22.12 workbench. `[d/]d` use the current-editor marker commands, matching Neovim's buffer-local diagnostic navigation. `Space ac` uses Cursor's follow-up action with selection insertion, while `Space an` creates a new chat. Cursor desktop key presses still need a hands-on check when desktop control is available; the current verification covers configuration consistency and Neovim behavior.

The previous repository state is available in Git history at `3017f9007605a9cb0a761b1e39a92563b9f2b158`.
