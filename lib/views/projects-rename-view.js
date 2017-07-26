const { TextEditor } = require('atom');

const defaultValidator = (text) => {
  if (text.trim().length === 0) {
    return 'required';
  }
  return null;
};

module.exports = class RenameView {
  constructor(options = {}) {
    this.callback = options.callback;

    this.miniEditor = this.buildMiniEditor(options);
    this.message = this.buildMessage(options);
    if (options.labelText) {
      this.label = this.buildLabel(options);
    }
    this.element = this.buildElement(options);

    this.validator = options.validator ? options.validator : defaultValidator;
    this.miniEditor.onDidChange(() => {
      this.message.textContent = this.validator(this.miniEditor.getText());
    });

    atom.commands.add(this.element, {
      'core:confirm': this.confirm.bind(this),
      'core:cancel': this.close.bind(this),
    });
  }

  attach() {
    this.storeFocusedElement();
    this.panel = atom.workspace.addModalPanel({ item: this });
    this.miniEditor.element.focus();
    this.miniEditor.scrollToCursorPosition();
  }

  confirm() {
    const text = this.miniEditor.getText();
    const error = this.validator(text);
    if (error) {
      this.message.textContent = error;
      return;
    }

    if (this.callback) {
      this.callback(text);
    }
    this.close();
  }

  close() {
    this.miniEditor.setText('');
    if (this.panel) {
      this.panel.destroy();
      this.panel = null;
    }

    if (this.miniEditor.element.hasFocus()) {
      this.restoreFocus();
    }
  }

  storeFocusedElement() {
    this.previouslyFocusedElement = document.activeElement;
    return this.previouslyFocusedElement;
  }

  restoreFocus() {
    if (this.previouslyFocusedElement && this.previouslyFocusedElement.parentElement) {
      this.previouslyFocusedElement.focus();
      return;
    }
    atom.views.getView(atom.workspace).focus();
  }

  buildMiniEditor({ defaultText, textPattern, selectedRange }) {
    const miniEditor = new TextEditor({ mini: true });
    miniEditor.element.addEventListener('blur', this.close.bind(this));

    if (defaultText) {
      miniEditor.setText(defaultText);
      if (selectedRange) {
        miniEditor.setSelectedBufferRange(selectedRange);
      }
    }

    if (textPattern) {
      miniEditor.onWillInsertText(({ cancel, text }) => {
        if (!text.match(textPattern)) {
          cancel();
        }
      });
    }

    return miniEditor;
  }

  buildLabel({ labelText, labelClass }) {
    const label = document.createElement('label');
    label.textContent = labelText;
    if (labelClass) {
      label.classList.add(labelClass);
    }

    return label;
  }

  buildMessage() {
    const message = document.createElement('div');
    message.classList.add('message');
    return message;
  }

  buildElement({ elementClass }) {
    const element = document.createElement('div');
    if (elementClass) {
      element.classList.add(elementClass);
    }
    if (this.label) {
      element.appendChild(this.label);
    }
    element.appendChild(this.miniEditor.element);
    element.appendChild(this.message);

    return element;
  }
};
