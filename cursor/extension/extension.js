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
    try {
      const document = await vscode.workspace.openTextDocument(uri);
      await vscode.window.showTextDocument(document, { preview: false, preserveFocus: false });
    } catch (error) {
      vscode.window.showErrorMessage(`Vim First cheatsheet could not be opened: ${error.message}`);
    }
  }));
}

function deactivate() {}

module.exports = { activate, deactivate };
