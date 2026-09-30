"""Check the installed Cursor map without exposing unrelated User settings."""
import json
import os
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
user = Path(os.environ["APPDATA"]) / "Cursor" / "User"
settings = json.loads((user / "settings.json").read_text(encoding="utf-8-sig"))
keys = json.loads((user / "keybindings.json").read_text(encoding="utf-8-sig"))
spec = json.loads((root / "vim-first-keymap.json").read_text(encoding="utf-8"))

assert settings["vim.leader"] == "<space>"
assert settings["whichkey.delay"] == 0
normal = settings["whichkey.bindings"]
ai = next(item for item in normal if item["key"] == "a")["bindings"]
assert "c" not in {item["key"] for item in ai}, "Visual-only AI context leaked to Normal mode"
visual = settings["vim.visualModeKeyBindingsNonRecursive"][0]["commands"][0]["args"][0]
visual_ai = next(item for item in visual if item["key"] == "a")["bindings"]
assert any(item["key"] == "c" and item["command"] == "aichat.newfollowupaction" for item in visual_ai)
assert any(item["key"] == "t" and item["command"] == "workbench.action.terminal.toggleTerminal" for item in normal)
assert not any(item["key"] == "ctrl+w l" for item in keys)

for direction, command in zip("hjkl", ("navigateLeft", "navigateDown", "navigateUp", "navigateRight")):
    matches = [item for item in keys if item.get("key") == "ctrl+" + direction
               and item.get("command") == "workbench.action." + command]
    assert len(matches) == 2, (direction, matches)
    assert any("vim.mode == 'Normal'" in item["when"] and "editorTextFocus" in item["when"] for item in matches)
    assert any("filesExplorerFocus" in item["when"] and "!inputFocus" in item["when"] for item in matches)
assert any(item["key"] == "ctrl+alt+e" and item["when"] == "terminalFocus" for item in keys)

manifest_leader = {binding["keys"][len("<leader>"):] for binding in spec["bindings"]
                   if binding["keys"].startswith("<leader>") and not binding.get("visual_only")}
def flatten(menu, prefix=""):
    for item in menu:
        if item["type"] == "bindings":
            yield from flatten(item["bindings"], prefix + item["key"])
        elif item["key"] != "?":
            yield prefix + item["key"]
assert set(flatten(normal)) == manifest_leader

if len(sys.argv) > 1:
    backup = Path(sys.argv[1])
    previous = json.loads((backup / "settings.json").read_text(encoding="utf-8-sig"))
    owned = {"vim.leader", "vim.useCtrlKeys", "vim.handleKeys",
             "vim.normalModeKeyBindingsNonRecursive", "vim.visualModeKeyBindingsNonRecursive",
             "whichkey.bindings", "whichkey.delay", "whichkey.sortOrder", "vimFirst.cheatsheetPath"}
    assert {k: v for k, v in settings.items() if k not in owned} == {k: v for k, v in previous.items() if k not in owned}

print("Cursor Vim-first keymap verified:", len(spec["bindings"]), "bindings")
