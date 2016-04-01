'use babel';

export default class ProjectManager {
  static activate() {
    const CompositeDisposable = require('atom').CompositeDisposable;
    this.disposables = new CompositeDisposable();
    this.projects = require('./projects');

    this.disposables.add(atom.commands.add('atom-workspace', {
      'project-manager:list-projects': () => {
        if (!this.projectsListView) {
          const ProjectsListView = require('./projects-list-view');
          this.projectsListView = new ProjectsListView();
        }

        this.projectsListView.toggle();
      },

      'project-manager:save-project': () => {
        if (!this.saveDialog) {
          const SaveDialog = require('./save-dialog');
          this.saveDialog = new SaveDialog();
        }

        this.saveDialog.attach();
      },

      'project-manager:edit-projects': () => {
        if (!this.db) {
          this.db = require('./db');
        }

        atom.workspace.open(this.db.file());
      }
    }));

    atom.project.onDidChangePaths(() => this.updatePaths());
    this.loadProject();
  }

  static loadProject() {
    this.projects.getCurrent(project => {
      if (project) {
        this.project = project;
        this.project.load();
      }
    });
  }

  static updatePaths() {
    this.projects.getCurrent(project => {
      const newPaths = atom.project.getPaths();
      const currentRoot = newPaths.length ? newPaths[0] : null;

      if (project.rootPath === currentRoot) {
        project.set('paths', newPaths);
      }
    });
  }

  static provideProjects() {
    return {
      projects: this.projects
    };
  }

  static deactivate() {
    this.disposables.dispose();
  }
}
