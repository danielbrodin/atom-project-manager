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
    let found = false;

    for (const project of this.projects) {
      if (project.props._id === settings._id) {
        found = true;
      } else if (project.props.paths[0] === settings.paths[0]) {
        found = true;
      }
    }

    if (found === false) {
      const newProject = new Project(settings);
      this.projects.push(newProject);
      this.emitter.emit('projects-updated');
    }
  }
}

export default new Projects();
