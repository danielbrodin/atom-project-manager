'use babel';

import { observable, autorun, computed, action } from 'mobx';
import untildify from 'untildify';
import tildify from 'tildify';
import projectUtil from 'atom-project-util';
import { each, map } from 'underscore-plus';
import FileStore from './stores/FileStore';
import GitStore from './stores/GitStore';
import Settings from './Settings';
import Project from './models/Project';

export class Manager {
  @observable projects = [];
  @observable activePaths = [];

  @computed get activeProject() {
    if (this.activePaths.length === 0) {
      return null;
    }

    return this.projects.find(project => project.rootPath === this.activePaths[0]);
  }

  constructor() {
    this.gitStore = new GitStore();
    this.fileStore = new FileStore();
    this.settings = new Settings();

    this.fetchProjects();

    atom.config.observe('project-manager.includeGitRepositories', (include) => {
      if (include) {
        this.gitStore.fetch();
      } else {
        this.gitStore.empty();
      }
    });

    autorun(() => {
      each(this.fileStore.data, (fileProp) => {
        this.addProject(fileProp);
      }, this);
    });

    autorun(() => {
      each(this.gitStore.data, (gitProp) => {
        this.addProject(gitProp);
      }, this);
    });

    autorun(() => {
      if (this.activeProject) {
        this.settings.load(this.activeProject.settings);
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

  /**
   * Create or Update a project.
   *
   * Props coming from file goes before any other source.
   */
  @action addProject(props) {
    const foundProject = this.projects.find((project) => {
      const projectRootPath = project.rootPath.toLowerCase();
      const propsRootPath = untildify(props.paths[0]).toLowerCase();
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

  fetchProjects() {
    this.fileStore.fetch();

    if (atom.config.get('project-manager.includeGitRepositories')) {
      this.gitStore.fetch();
    }
  }

  static open(project, openInSameWindow = false) {
    if (Manager.isProject(project)) {
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
    if (Manager.isProject(props)) {
      propsToSave = props.getProps();
    }
    this.addProject({ ...propsToSave, source: 'file' });
    this.saveProjects();
  }

  saveProjects() {
    const projects = this.projects.filter(project => project.props.source === 'file');

    const arr = map(projects, (project) => {
      const props = project.getChangedProps();
      delete props.source;

      if (atom.config.get('project-manager.savePathsRelativeToHome')) {
        props.paths = props.paths.map(path => tildify(path));
      }

      return props;
    });

    this.fileStore.store(arr);
  }

  static isProject(project) {
    if (project instanceof Project) {
      return true;
    }

    return false;
  }
}

const manager = new Manager();
export default manager;
