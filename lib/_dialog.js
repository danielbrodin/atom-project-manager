'use babel';

import {TextEditor, CompositeDisposable} from 'atom';

export default class Dialog extends HTMLElement {

  createdCallback() {
    this.disposables = new CompositeDisposable();

    this.classList.add('project-manager-dialog', 'overlay', 'from-top');

    this.label = document.createElement('label');
    this.label.classList.add('project-manager-dialog-label', 'icon');

    this.editor = new TextEditor({mini: true});
    this.editorElement = atom.views.getView(this.editor);

    this.errorMessage = document.createElement('div');
    this.errorMessage.classList.add('error');

    this.appendChild(this.label);
    this.appendChild(this.editorElement);
    this.appendChild(this.errorMessage);

    this.disposables.add(atom.commands.add('project-manager-dialog', {
      'core:confirm': () => this.confirm(),
      'core:cancel': () => this.cancel()
    }));

    this.editorElement.addEventListener('blur', () => this.cancel());

    this.isAttached();
  }

  attachedCallback() {
    this.editorElement.focus();
  }

  attach() {
    atom.views.getView(atom.workspace).appendChild(this);
  }

  detach() {
    console.log('Detached called');
    console.log(this);
    console.log(this.parentNode);
    if (this.parentNode == 'undefined' || this.parentNode == null) {
      return false;
    }

    this.disposables.dispose();
    atom.workspace.getActivePane().activate();
    this.parentNode.removeChild(this);
  }

  // attributeChangedCallback(attr, oldVal, newVal) {
  //
  // }

  setLabel(text='', iconClass) {
    this.label.textContent = text;
    if (iconClass) {
      this.label.classList.add(iconClass);
    }
  }

  setInput(input='', select=false) {
    this.editor.setText(input);

    if (select) {
      let range = [[0, 0], [0, input.length]];
      this.editor.setSelectedBufferRange(range);
    }
  }

  showError(message='') {
    this.errorMessage.textContent(message);
  }

  cancel() {
    this.detach();
  }

  close() {
    this.detach();
  }

}
