import json
import pathlib
import zipfile

root = pathlib.Path(__file__).resolve().parent
package = json.loads((root/'extension/package.json').read_text(encoding='utf-8'))
assert package['contributes']['commands'][0]['command'] == 'vimFirst.showCheatsheet'
output = root/f"vim-first-cheatsheet-{package['version']}.vsix"
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED) as archive:
    archive.write(root/'extension/package.json','extension/package.json')
    archive.write(root/'extension/extension.js','extension/extension.js')
print(output)
