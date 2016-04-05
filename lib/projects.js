'use babel';

import {Emitter} from 'atom';
import Project from './project';
import db from './db';

class Projects {
  constructor() {
    this.emitter = new Emitter();
    this.projects = [];

    db.addUpdater('iwantitall', {}, (project) => {
      this.addProject(project);
    });
  }

  onUpdate(callback) {
    this.emitter.on('projects-updated', callback);
  }

  getAll(callback) {
    db.find(projectSettings => {
      for (const setting of projectSettings) {
        this.addProject(setting);
      }

      callback(this.projects);
    });
  }

  getCurrent(callback) {
    this.getAll(projects => {
      projects.forEach(project => {
        if (project.isCurrent()) {
          callback(project);
        }
      });
    });
  }

  addProject(settings) {
    let found = null;

    for (const project of this.projects) {
      if (project.props._id === settings._id) {
        found = project;
      } else if (project.rootPath === settings.paths[0]) {
        found = project;
      }
    }

    if (found === null) {
      const newProject = new Project(settings);
      this.projects.push(newProject);

      if (!newProject.props._id) {
        newProject.save();
      }

      this.emitter.emit('projects-updated');
      found = newProject;

    }

    return found;
  }
}

export default new Projects();
