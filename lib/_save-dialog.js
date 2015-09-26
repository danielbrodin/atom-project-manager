'use babel';

import Dialog from './dialog';
import Project from './project';
import path from 'path';

class SaveDialog extends Dialog {

  isAttached() {
    let firstPath = atom.project.getPaths()[0];
    let title = path.basename(firstPath);
    this.setLabel('Enter name of project', 'icon-arrow-right');
    this.setInput(title, true);
  }

  confirm() {
    let input = this.editor.getText();

    if (input) {
      let properties = {
        title: input,
        paths: atom.project.getPaths()
      };

      let project = new Project(properties);
      project.save();

      this.close();
    }
  }
}

module.exports = SaveDialog = document.registerElement('project-manager-dialog', SaveDialog);

// atom.commands.add('project-manager-dialog', {
//   'core:confirm': () => this.confirm(),
//   'core:cancel': () => this.cancel()
// });
