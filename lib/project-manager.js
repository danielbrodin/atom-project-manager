'use babel';

export default class ProjectManager {
  static activate() {
    const CompositeDisposable = require('atom').CompositeDisposable;
    const manager = require('./Manager');

    this.disposables = new CompositeDisposable();
    this.manager = manager;

    this.disposables.add(atom.commands.add('atom-workspace', {
      'project-manager:list-projects': () => {
        if (!this.projectsListView) {
          const ProjectsListView = require('./views/projects-list-view');

          this.projectsListView = new ProjectsListView();
        }

        this.projectsListView.toggle();
      },
      'project-manager:edit-projects': () => {
        if (!this.FileStore) {
          const FileStore = require('./stores/FileStore');

          this.FileStore = FileStore;
        }

        atom.workspace.open(this.FileStore.getPath());
      },
      'project-manager:save-project': () => {
        if (!this.saveDialog) {
          // const SaveDialog = require('./views/save-dialog');
          const SaveDialog = require('./views/SaveView');

          this.saveDialog = new SaveDialog();
        }

        this.saveDialog.attach();
      },
    }));
  }

  static provideProjects() {
  }

  static deactivate() {
    this.disposables.dispose();
  }
}
