'use strict';
const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

function activate(context) {
  context.subscriptions.push(vscode.commands.registerCommand('vimFirst.showCheatsheet', async () => {
    const configured = vscode.workspace.getConfiguration('vimFirst').get('cheatsheetPath');
    if (typeof configured !== 'string' || !path.isAbsolute(configured) || !fs.existsSync(configured)) {
      vscode.window.showErrorMessage('Vim First cheatsheet file is missing.');
      return;
    }
    const uri = vscode.Uri.file(configured);
    await vscode.commands.executeCommand('markdown.showPreview', uri);
  }));
}

function deactivate() {}

module.exports = { activate, deactivate };
