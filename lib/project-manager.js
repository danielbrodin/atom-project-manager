'use babel';

let CompositeDisposable;
let ProjectsListView;
let projects;
let SaveDialog;

export default class ProjectManager {
  static activate() {
    CompositeDisposable = require('atom').CompositeDisposable;
    this.disposables = new CompositeDisposable();
    projects = require('./projects');

    this.disposables.add(atom.commands.add('atom-workspace', {
      'project-manager:list-projects': () => {
        ProjectsListView = require('./projects-list-view');
        let projectsListView = new ProjectsListView();
        projectsListView.toggle();
      },

      'project-manager:save-project': () => {
        SaveDialog = require('./save-dialog');
        let saveDialog = new SaveDialog();
        saveDialog.attach();
      },

      'project-manager:edit-projects': () => {
        db = require('./db');
        atom.workspace.open(db.file());
      }
    }));

    atom.project.onDidChangePaths(() => this.updatePaths());
    this.loadProject();
  }

  static loadProject() {
    projects.getCurrent(project => {
      if (project) {
        this.project = project;
        this.project.load();
      }
    });
  }

  static updatePaths() {
    let paths = atom.project.getPaths();
    if (this.project && paths.length) {
      this.project.set('paths', paths);
    }
  }

  static provideProjects() {
    return {
      projects: projects
    };
  }

  static deactivate() {
    this.disposables.dispose();
  }
}
