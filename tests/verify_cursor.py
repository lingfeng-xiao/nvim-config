"""Check the installed Cursor map without exposing unrelated User settings."""
import json
import os
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
user = Path(os.environ["APPDATA"]) / "Cursor" / "User"
settings = json.loads((user / "settings.json").read_text(encoding="utf-8-sig"))
keys = json.loads((user / "keybindings.json").read_text(encoding="utf-8-sig"))
assert isinstance(keys, list) and all(isinstance(item, dict) for item in keys)
spec = json.loads((root / "vim-first-keymap.json").read_text(encoding="utf-8"))

assert settings["vim.leader"] == "<space>"
assert settings["whichkey.delay"] == 0
normal = settings["whichkey.bindings"]
assert [item["key"] for item in normal] == list("eftwacrb?")
ai = next(item for item in normal if item["key"] == "a")["bindings"]
assert "c" not in {item["key"] for item in ai}, "Visual-only AI context leaked to Normal mode"
visual = settings["vim.visualModeKeyBindingsNonRecursive"][0]["commands"][0]["args"][0]
visual_ai = next(item for item in visual if item["key"] == "a")["bindings"]
assert any(item["key"] == "c" and item["command"] == "aichat.newfollowupaction" for item in visual_ai)
assert any(item["key"] == "t" and item["command"] == "workbench.action.terminal.toggleTerminal" for item in normal)
help_group = next(item for item in normal if item["key"] == "c")["bindings"]
assert any(item["key"] == "h" and item["command"] == "vimFirst.showCheatsheet" for item in help_group)
assert any(item["key"] == "?" and item["command"] == "whichkey.searchBindings" for item in normal)
explorer = next(item for item in keys if item.get("key") == "space" and item.get("command") == "whichkey.show")
assert explorer["args"][0]["key"] == "e" and explorer["args"][0]["command"] == "workbench.action.focusActiveEditorGroup"
assert not any(item["key"] == "ctrl+w l" for item in keys)

for direction, command in zip("hjkl", ("navigateLeft", "navigateDown", "navigateUp", "navigateRight")):
    matches = [item for item in keys if item.get("key") == "ctrl+" + direction
               and item.get("command") == "workbench.action." + command]
    assert len(matches) == 2, (direction, matches)
    assert any("vim.mode == 'Normal'" in item["when"] and "editorTextFocus" in item["when"] for item in matches)
    assert any("filesExplorerFocus" in item["when"] and "!inputFocus" in item["when"] for item in matches)
editor_return = [item for item in keys if item.get("key") == "ctrl+alt+e"]
assert len(editor_return) == 1
assert editor_return[0]["command"] == "workbench.action.focusActiveEditorGroup"
assert "when" not in editor_return[0], "Editor return must also work inside Agent input"

manifest_leader = {binding["keys"][len("<leader>"):] for binding in spec["bindings"]
                   if binding["keys"].startswith("<leader>") and not binding.get("visual_only")}
def flatten(menu, prefix=""):
    for item in menu:
        if item["type"] == "bindings":
            yield from flatten(item["bindings"], prefix + item["key"])
        elif item["key"] != "?":
            yield prefix + item["key"]
assert set(flatten(normal)) == manifest_leader
sheet = (user / "vim-first-cheatsheet.md").read_text(encoding="utf-8")
for label in ("键位看板", "## 窗口", "Space wv", "Space ws", "## Cursor AI", "仅 Cursor Visual"):
    assert label in sheet, label
assert settings["vimFirst.cheatsheetPath"] == str(user / "vim-first-cheatsheet.md")
extensions = sorted((Path.home() / ".cursor" / "extensions").glob("lingfeng-local.vim-first-cheatsheet-*/package.json"))
assert extensions, "Vim First cheatsheet extension is not installed"
extension = json.loads(extensions[-1].read_text(encoding="utf-8"))
assert extension["version"] == "0.1.1"
assert any(command["command"] == "vimFirst.showCheatsheet" for command in extension["contributes"]["commands"])
extension_source = (extensions[-1].parent / "extension.js").read_text(encoding="utf-8")
assert "openTextDocument" in extension_source and "showTextDocument" in extension_source
assert "markdown.showPreview" not in extension_source
assert "vscode.Uri.file" in extension_source

if len(sys.argv) > 1:
    backup = Path(sys.argv[1])
    previous = json.loads((backup / "settings.json").read_text(encoding="utf-8-sig"))
    owned = {"vim.leader", "vim.useCtrlKeys", "vim.handleKeys",
             "vim.normalModeKeyBindingsNonRecursive", "vim.visualModeKeyBindingsNonRecursive",
             "whichkey.bindings", "whichkey.delay", "whichkey.sortOrder", "vimFirst.cheatsheetPath"}
    assert {k: v for k, v in settings.items() if k not in owned} == {k: v for k, v in previous.items() if k not in owned}

print("Cursor Vim-first keymap verified:", len(spec["bindings"]), "bindings")
