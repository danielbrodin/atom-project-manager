'use babel';

import { observable, autorun, computed, action } from 'mobx';
import FileStore from './stores/FileStore';
import GitStore from './stores/GitStore';
import Settings from './Settings';
import Project from './models/Project';

class Manager {
  @observable projects = [];

  /**
   * Create or Update a project.
   *
   * Props coming from file goes before any other source.
   */
  @action addProject(props) {
    const foundProject = this.projects.find(project =>
      project.rootPath.toLowerCase() === props.paths[0].toLowerCase()
    );

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

    atom.project.onDidChangePaths(() => {
      const activePaths = atom.project.getPaths();

      if (this.activeProject && this.activeProject.rootPath === activePaths[0]) {
        this.activeProject.updateProps({ paths: activePaths });
        this.saveProjects();
      }
    });
  }

  @computed get activeProject() {
    const activePaths = atom.project.getPaths();
    return this.projects.find(project => project.rootPath === activePaths[0]);
  }

  loadProject(project) {
    this.settings.load(project.props.settings);
  }

  open(project) {
    const win = atom.getCurrentWindow();
    const closeCurrent = atom.config.get('project-manager.closeCurrent');
    const { paths, devMode } = project.getProps();

    atom.open({
      devMode,
      pathsToOpen: paths,
      newWindow: closeCurrent,
    });

    if (closeCurrent) {
      setTimeout(() => win.close(), 0);
    }
  }

  saveProject(props) {
    this.addProject({ ...props, source: 'file' });
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
}

const manager = new Manager();
export default manager;
