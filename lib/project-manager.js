'use babel';

import {CompositeDisposable} from 'atom';
import ProjectsListView from './projects-list-view';
import Projects from './projects';
import Project from './project';
import SaveDialog from './save-dialog';
import DB from './db';

export default class ProjectManager {

  static config = {
    showPath: {
      type: 'boolean',
      default: true
    },
    closeCurrent: {
      type: 'boolean',
      default: false,
      description: 'Currently disabled since it\'s broken. Waiting for a better way to implement it.'
    },
    environmentSpecificProjects: {
      type: 'boolean',
      default: false
    },
    sortBy: {
      type: 'string',
      description: 'Default sorting is the order in which the projects are',
      default: 'default',
      enum: ['default', 'title', 'group']
    }
  }

  static activate() {
    this.disposables = new CompositeDisposable;

    this.disposables.add(atom.commands.add('atom-workspace', {
      'project-manager:list-projects': (e) => {
        let projectsListView = new ProjectsListView();
        projectsListView.toggle();
      },

      'project-manager:save-project': (e) => {
        saveDialog = new SaveDialog();
        saveDialog.attach();
      },

      'project-manager:edit-projects': (e) => {
        db = new DB();
        atom.workspace.open(db.file());
      }
    }));

    atom.project.onDidChangePaths(() => this.updatePaths());
    this.loadProject();
  }

  static loadProject() {
    this.projects = new Projects();
    this.projects.getCurrent((project) => {
      if (project) {
        this.project = project;
        this.project.load();
      }
    });
  }

  static updatePaths() {
    var paths = atom.project.getPaths();
    if (this.project && paths.length) {
      this.project.set('paths', paths);
    }
  }

  static provideProjects() {
    return {
      projects: new Projects()
    };
  }

  static deactivate() {
    this.disposables.dispose();
  }
}
