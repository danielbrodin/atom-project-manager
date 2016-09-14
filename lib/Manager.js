'use babel';

import { observable, autorun, computed, action } from 'mobx';
import os from 'os';
import projectUtil from 'atom-project-util';
import FileStore from './stores/FileStore';
import GitStore from './stores/GitStore';
import Settings from './Settings';
import Project from './models/Project';

class Manager {
  @observable projects = [];
  @observable activePaths = [];

  /**
   * Create or Update a project.
   *
   * Props coming from file goes before any other source.
   */
  @action addProject(props) {
    const foundProject = this.projects.find(project => {
      const projectRootPath = project.rootPath.toLowerCase();
      let propsRootPath = props.paths[0].toLowerCase();

      if (propsRootPath.charAt(0) === '~') {
        propsRootPath = propsRootPath.replace('~', os.homedir()).toLowerCase();
      }

      return projectRootPath === propsRootPath;
    });

    if (!foundProject) {
      const newProject = new Project(props);
      this.projects.push(newProject);
    } else {
      if (foundProject.source === 'file' && props.source === 'file') {
        foundProject.updateProps(props);
      }

      if (props.source === 'file' || typeof props.source === 'undefined') {
        foundProject.updateProps(props);
      }
    }
  }

  constructor() {
    this.gitStore = new GitStore();
    this.fileStore = new FileStore();
    this.settings = new Settings();

    this.fileStore.fetch();

    if (atom.config.get('project-manager.includeGitRepositories')) {
      this.gitStore.fetch();
    }

    atom.config.observe('project-manager.includeGitRepositories', (include) => {
      if (include) {
        this.gitStore.fetch();
      } else {
        this.gitStore.empty();
      }
    });

    autorun(() => {
      for (const fileProp of this.fileStore.data) {
        this.addProject(fileProp);
      }

      for (const gitProp of this.gitStore.data) {
        this.addProject(gitProp);
      }
    });

    autorun(() => {
      if (this.activeProject) {
        this.loadProject(this.activeProject);
      }
    });


    this.activePaths = atom.project.getPaths();
    atom.project.onDidChangePaths(() => {
      this.activePaths = atom.project.getPaths();
      const activePaths = atom.project.getPaths();

      if (this.activeProject && this.activeProject.rootPath === activePaths[0]) {
        if (this.activeProject.paths.length !== activePaths.length) {
          this.activeProject.updateProps({ paths: activePaths });
          this.saveProjects();
        }
      }
    });
  }

  @computed get activeProject() {
    if (this.activePaths.length === 0) {
      return null;
    }

    return this.projects.find(project => project.rootPath === this.activePaths[0]);
  }

  loadProject(project) {
    this.settings.load(project.getProps().settings);
  }

  open(project, openInSameWindow = false) {
    if (this.isProject(project)) {
      const { devMode } = project.getProps();

      if (openInSameWindow) {
        projectUtil.switch(project.paths);
      } else {
        atom.open({
          devMode,
          pathsToOpen: project.paths,
        });
      }
    }
  }

  saveProject(props) {
    let propsToSave = props;
    if (this.isProject(props)) {
      propsToSave = props.getProps();
    }
    this.addProject({ ...propsToSave, source: 'file' });
    this.saveProjects();
  }

  saveProjects() {
    const projects = this.projects.filter(project => project.props.source === 'file');
    const arr = [];

    for (const project of projects) {
      const props = project.getProps();
      delete props.source;
      arr.push(props);
    }

    this.fileStore.store(arr);
  }

  isProject(project) {
    if (project instanceof Project) {
      return true;
    }

    return false;
  }
}

const manager = new Manager();
export default manager;
