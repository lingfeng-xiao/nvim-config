"""Install this repository's shared Vim-first keymap into Cursor User settings."""
import copy
import datetime
import json
import os
from pathlib import Path
import shutil
import sys

check_only = "--check" in sys.argv[1:]
if any(arg != "--check" for arg in sys.argv[1:]):
    raise SystemExit("Usage: python cursor/install_windows.py [--check]")

root = Path(__file__).resolve().parents[1]
spec = json.loads((root / "vim-first-keymap.json").read_text(encoding="utf-8"))
user = Path(os.environ["APPDATA"]) / "Cursor" / "User"
settings_path, keys_path, guide_path = (user / name for name in ("settings.json", "keybindings.json", "vim-first-cheatsheet.md"))
workbench = Path(os.environ["LOCALAPPDATA"]) / "Programs/cursor/resources/app/out/vs/workbench/workbench.desktop.main.js"
if not workbench.exists():
    raise SystemExit(f"Cursor workbench not found: {workbench}")
source = workbench.read_text(encoding="utf-8")
for binding in spec["bindings"]:
    command = binding["cursor"]
    if command != "vim-first.cheatsheet-preview" and command not in source:
        raise SystemExit(f"Command is not present in this Cursor build: {command}")


def read_json(path, fallback):
    return json.loads(path.read_text(encoding="utf-8-sig")) if path.exists() else fallback


def menu(bindings):
    items, groups = [], {}
    for binding in bindings:
        key = binding["keys"].removeprefix("<leader>")
        if key == binding["keys"]:
            continue
        command = "vimFirst.showCheatsheet" if binding["cursor"] == "vim-first.cheatsheet-preview" else binding["cursor"]
        entry = {"key": key[-1], "name": binding["label"], "type": "command", "command": command}
        if len(key) == 1:
            items.append(entry)
        else:
            if key[0] not in groups:
                group = {"key": key[0], "name": "+" + binding["group"], "type": "bindings", "bindings": []}
                groups[key[0]] = group
                items.append(group)
            groups[key[0]]["bindings"].append(entry)
    items.append({"key": "?", "name": "Search shortcuts", "type": "command", "command": "whichkey.searchBindings"})
    order = {key: index for index, key in enumerate("eftwacrb?")}
    return sorted(items, key=lambda item: order.get(item["key"], len(order)))


def sequence(key):
    return ["<leader>", *key.removeprefix("<leader>")] if key.startswith("<leader>") else list(key)


settings, keys = read_json(settings_path, {}), read_json(keys_path, [])
if not isinstance(settings, dict) or not isinstance(keys, list):
    raise SystemExit("Cursor User settings/keybindings have an unexpected format")
normal_menu = menu([b for b in spec["bindings"] if not b.get("visual_only")])
visual_menu = menu([b for b in spec["bindings"] if b.get("visual") or b.get("visual_only")])
settings.update({
    "vim.leader": "<space>", "vim.useCtrlKeys": True,
    "vim.handleKeys": {**settings.get("vim.handleKeys", {}), **{key: True for key in ("<C-w>", "<C-i>", "<C-o>", "<C-v>", "<C-h>", "<C-j>", "<C-k>", "<C-l>")}},
    "vim.normalModeKeyBindingsNonRecursive": [
        {"before": sequence(b["keys"]), "commands": [b["cursor"]]}
        for b in spec["bindings"] if not b["keys"].startswith("<leader>") and not b.get("cursor_binding")
    ] + [{"before": ["<leader>"], "commands": ["whichkey.show"], "silent": True}],
    "vim.visualModeKeyBindingsNonRecursive": [{"before": ["<leader>"], "commands": [{"command": "whichkey.show", "args": [visual_menu]}], "silent": True}],
    "whichkey.bindings": normal_menu, "whichkey.delay": 0, "whichkey.sortOrder": "none",
    "vimFirst.cheatsheetPath": str(guide_path),
})
managed = read_json(root / "cursor/keybindings.managed.json", [])
if "workbench.action.focusActiveEditorGroup" not in source:
    raise SystemExit("Editor focus command is not present in this Cursor build")
for binding in spec["bindings"]:
    if binding.get("cursor_binding") == "normal-and-explorer":
        key = "ctrl+" + binding["keys"][3].lower()
        matches = [item for item in managed if item["key"] == key and item["command"] == binding["cursor"]]
        if len(matches) != 2 or not any("vim.mode == 'Normal'" in item["when"] for item in matches) or not any("filesExplorerFocus" in item["when"] for item in matches):
            raise SystemExit(f"Missing scoped Normal/Explorer bindings for {key}")
explorer_menu = copy.deepcopy(normal_menu)
for item in explorer_menu:
    if item["key"] == "e":
        item.update(name="Return to Editor", command="workbench.action.focusActiveEditorGroup")
for item in managed:
    if item["key"] == "space" and item["command"] == "whichkey.show":
        item["args"] = explorer_menu
owned = {(item["key"], item.get("when", "")) for item in managed}
legacy = {("ctrl+w l", "workbench.action.focusActiveEditorGroup"),
          ("ctrl+alt+e", "workbench.action.focusActiveEditorGroup")}
keys = [item for item in keys if (item.get("key"), item.get("when", "")) not in owned
        and (item.get("key"), item.get("command")) not in legacy] + managed

lines = [
    "# Vim-first · 键位看板", "",
    "**Normal 按 `Space`**：显示 Which Key；在面板中按字母逐层选择，`?` 搜索快捷键。",
    "**Visual 按 `Space`**：只显示适用于选区的操作。**Explorer 按 `Space`**：显示文件树菜单，`e` 返回编辑器。",
    "**`Space ch`**：在普通编辑器中打开本看板；用 `j/k`、`Ctrl+d/u`、`gg/G`、`/` 浏览，`Space bd` 关闭。Caps 短按 `Esc`，按住等于 `Ctrl`。", "",
    "| 高频入口 | 作用 |", "|---|---|",
    "| `Space e` / `Space ff` / `Space fg` / `Space fb` | Explorer / 文件 / 全局搜索 / 已打开编辑器 |",
    "| `Ctrl+h/j/k/l` / `Space wv/ws` | 方向焦点 / 竖、横分屏 |",
    "| `Space t` / `Space aa` / `Space ai` | Terminal / Agent / Inline Edit |", "",
]
group_names = {"LSP": "代码关系", "Diagnostics": "诊断", "Code": "代码修改", "Rename": "重命名",
               "Files": "文件与搜索", "Explorer": "文件树", "Buffers": "Buffer", "Windows": "窗口",
               "Terminal": "终端", "Help": "提示", "AI": "Cursor AI"}
for group, title in group_names.items():
    bindings = [b for b in spec["bindings"] if b["group"] == group]
    if not bindings:
        continue
    lines += [f"## {title}", "", "| 键位 | 操作 | 范围 |", "|---|---|---|"]
    for b in bindings:
        display_keys = b["keys"].replace("<leader>", "Space ").replace("<C-", "Ctrl+").replace(">", "")
        scope = "仅 Cursor Visual" if b.get("visual_only") else ("仅 Cursor" if b["nvim"] is None else "两端")
        lines.append(f"| `{display_keys}` | {b['label']} | {scope} |")
    lines.append("")
lines += [
    "## 原生 Vim 与返回", "",
    "`hjkl`、文本对象、`d/c/y`、`/ ? * # n N`、`.`、宏、marks 和 `Ctrl+o/i` 保留原生语义；Neovim 仍保留原生 `Ctrl+w`。",
    "`Ctrl+h/j/k/l` 只在 Normal 编辑器和非输入状态 Explorer 中移动焦点；Insert、Terminal、AI 输入框中的 Ctrl 键不被这组映射接管。",
    "Explorer 中按 `Space e`、`q` 或 `Esc` 返回编辑器；Terminal、Agent 等非编辑器区域按 `Ctrl+Alt+E` 返回。",
    "`gt/gT` 保留宿主原生行为：Neovim 是 Tab page，Cursor 是 Editor。`Space as` 暂未绑定。",
]
backup = user / "vim-first-backups" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
if not isinstance(keys, list) or not all(isinstance(item, dict) for item in keys):
    raise SystemExit("Generated Cursor keybindings must remain an array of objects")
if check_only:
    print(json.dumps({"check": "ok", "bindings": len(spec["bindings"]), "managed_keybindings": len(managed), "cursor_user": str(user)}, ensure_ascii=False))
    raise SystemExit(0)
user.mkdir(parents=True, exist_ok=True)
backup.mkdir(parents=True)
for path in (settings_path, keys_path, guide_path):
    if path.exists():
        shutil.copy2(path, backup / path.name)
settings_path.write_text(json.dumps(settings, ensure_ascii=False, indent=4) + "\n", encoding="utf-8")
keys_path.write_text(json.dumps(keys, ensure_ascii=False, indent=4) + "\n", encoding="utf-8")
guide_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(json.dumps({"backup": str(backup), "bindings": len(spec["bindings"]), "cursor_user": str(user)}, ensure_ascii=False))
