'use babel';

import { autorun } from 'mobx';
import { CompositeDisposable } from 'atom';
import manager from './Manager';
import { SAVE_URI, EDIT_URI } from './views/view-uri';

let disposables = null;
let projectsListView = null;
let FileStore = null;

export function editComponent() {
  const EditView = require('./views/EditView');

  return new EditView({ project: manager.activeProject });
}

export function activate() {
  disposables = new CompositeDisposable();

  disposables.add(atom.workspace.addOpener((uri) => {
    if (uri === EDIT_URI || uri === SAVE_URI) {
      return editComponent();
    }

    return null;
  }));

  disposables.add(atom.commands.add('atom-workspace', {
    'project-manager:list-projects': () => {
      if (!this.projectsListView) {
        const ProjectsListView = require('./views/projects-list-view');

        projectsListView = new ProjectsListView();
      }

      projectsListView.toggle();
    },
    'project-manager:edit-projects': () => {
      if (!FileStore) {
        FileStore = require('./stores/FileStore');
      }

      atom.workspace.open(FileStore.getPath());
    },
    'project-manager:save-project': () => {
      atom.workspace.open(SAVE_URI);
    },
    'project-manager:edit-project': () => {
      atom.workspace.open(EDIT_URI);
    },
    'project-manager:update-projects': () => {
      manager.fetchProjects();
    },
  }));
}

export function deactivate() {
  disposables.dispose();
}

export function provideProjects() {
  return {
    getProjects: (callback) => {
      autorun(() => {
        callback(manager.projects);
      });
    },
    getProject: (callback) => {
      autorun(() => {
        callback(manager.activeProject);
      });
    },
    saveProject: (project) => {
      manager.saveProject(project);
    },
    openProject: (project) => {
      manager.open(project);
    },
  };
}
