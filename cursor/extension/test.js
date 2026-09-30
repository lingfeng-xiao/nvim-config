'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const Module = require('node:module');
const os = require('node:os');
const path = require('node:path');

const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'vim-first-extension-'));
const cheatsheet = path.join(dir, 'cheatsheet.md');
fs.writeFileSync(cheatsheet, '# Vim-first\n');

let configured = cheatsheet;
let command;
let shown;
let error;
const vscode = {
  Uri: { file: file => ({ fsPath: file }) },
  commands: { registerCommand: (id, callback) => { assert.equal(id, 'vimFirst.showCheatsheet'); command = callback; return { dispose() {} }; } },
  workspace: {
    getConfiguration: () => ({ get: () => configured }),
    openTextDocument: async uri => ({ uri }),
  },
  window: {
    showTextDocument: async (document, options) => { shown = { document, options }; },
    showErrorMessage: message => { error = message; },
  },
};
const load = Module._load;
Module._load = function (request, parent, isMain) {
  return request === 'vscode' ? vscode : load.call(this, request, parent, isMain);
};
const extension = require('./extension');
Module._load = load;

(async () => {
  const context = { subscriptions: [] };
  extension.activate(context);
  assert.equal(context.subscriptions.length, 1);
  await command();
  assert.equal(shown.document.uri.fsPath, cheatsheet);
  assert.deepEqual(shown.options, { preview: false, preserveFocus: false });
  assert.equal(error, undefined);

  configured = path.join(dir, 'missing.md');
  shown = undefined;
  await command();
  assert.equal(shown, undefined);
  assert.match(error, /missing/i);
  console.log('Vim-enabled cheatsheet editor verified');
})().finally(() => {
  fs.unlinkSync(cheatsheet);
  fs.rmdirSync(dir);
}).catch(failure => {
  console.error(failure);
  process.exitCode = 1;
});
