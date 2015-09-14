'use babel';

import {$, TextEditorView, View} from 'atom-space-pen-views';

export default class Dialog extends View {
  content({prompt={}}) {
    this.div({class: 'project-manager-dialog'}, () => {
      this.label(prompt, {class:'icon', outlet: 'promptText'});
      this.subview('miniEditor', new TextEditorView({mini: true}));
      this.div({class: 'error-message', outlet: 'errorMessage'});
    });
  }

  initialize({input, select, iconClass}={}) {
    if (iconClass) {
      this.promptText.addCLass(iconClass);
    }

    atom.commands.add(this.element, {
      'core:confirm': () => this.onConfirm(this.miniEditor.getText()),
      'core:cancel': () => this.cancel()
    });

    this.miniEditor.on('blir', () => this.close());
    this.miniEditor.getModel().onDidChange(() => this.showError());
    this.miniEditor.getModel().setText(input);

    if (select) {
      range = [[0, 0], [0, input.length]];
      this.miniEditor.getModel().setSelectedBufferRange(range);
    }
  }

  attach() {
    this.panel = atom.workspace.addModalPanel({item: this.element});
    this.miniEditor.focus();
    this.miniEditor.getModel().scrollToCursorPosition();
  }

  close() {
    let panelToDestroy = this.panel;
    this.panel = null;
    if (panelToDestroy) {
      panelToDestroy.destroy();
    }

    atom.workspace.getActivePane().activate();
  }

  cancel() {
    this.close();
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'focus');
  }

  showError(message='') {
    this.errorMessage.text(message);
    if (message) {
      this.flashError();
    }
  }
}
