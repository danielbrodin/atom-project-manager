'use babel';

import {Emitter} from 'atom';
import _ from 'underscore-plus';
import DB from './db';
import Project from './project';

export default class Projects {
  constructor() {
    this.emitter = new Emitter();
    this.db = new DB();
    this.db.onUpdate(() => this.emitter.emit('projects-updated'));
  }

  onUpdate(callback) {
    this.emitter.on('projects-updated', callback);
  }

  getAll(callback) {
    this.db.find((projectSettings) => {
      let projects = [];
      for (key in projectSettings) {
        let setting = projectSettings[key];
        if (setting.paths) {
          let project = new Project(setting);
          projects.push(project);
        }
      }

      callback(projects);
    });
  }

  getCurrent(callback) {
    this.getAll((projects) => {
      for (project of projects) {
        if (project.isCurrent()) {
          callback(project);
        }
      }
    });
  }
}
