'use babel';

import {Emitter} from 'atom';
import CSON from 'season';
import fs from 'fs';
import path from 'path';
import os from 'os';
import _ from 'underscore-plus';

export default class DB {
  constructor(searchKey=null, searchValue=null) {
    this.setSearchQuery(searchKey, searchValue);
    this.emitter = new Emitter();

    fs.exists(this.file(), (exists) => {
      if (exists) {
        this.subscribeToProjectsFile();
      } else {
        this.writeFile({});
      }
    });
  }

  static get environmentSpecificProjects() {
    return atom.config.get('project-manager.environmentSpecificProjects');
  }

  setSearchQuery(searchKey=null, searchValue=null) {
    this.searchKey = searchKey;
    this.searchValue = searchValue;
  }

  find(callback) {
    this.readFile((results) => {
      let found = false;
      let projects = [];
      let project = null;
      let result = null;
      let template = null;

      for (key in results) {
        result = results[key];
        template = result.template || null;
        result._id = key;

        if (template && results[template] !== null) {
          result = _.deepExtend(result, results[template]);
        }

        projects.push(result);
      }

      if (this.searchKey && this.searchValue) {
        for (key in projects) {
          project = projects[key];
          if (_.isEqual(project[this.searchKey], this.searchValue)) {
            found = project;
          }
        }
      } else {
        found = projects;
      }

      callback(found);
    });
  }

  add(props, callback) {
    this.readFile((projects) => {
      let id = this.generateID(props.title);
      projects[id] = props;

      this.writeFile(projects, () => {
        atom.notifications.addSuccess(`${props.title} has been added`);
        callback(id);
      });
    });
  }

  update(props) {
    if (!props._id) {
      return false;
    }

    let project = null;

    this.readFile((projects) => {
      for (key in projects) {
        project = projects[key];
        if (key === props._id) {
          delete(props._id);
          projects[key] = props;
        }

        this.writeFile(projects);
      }
    });
  }

  delete(id, callback) {
    this.readFile((projects) => {
      for (key in projects) {
        if (key === id) {
          delete(projects[key]);
        }
      }

      this.writeFile(projects, () => {
        if (callback) {
          callback();
        }
      });
    });
  }

  onUpdate(callback) {
    this.emitter.on('db-updated', () => {
      this.find(callback);
    });
  }

  subscribeToProjectsFile() {
    if (this.fileWatcher) {
      this.fileWatcher.close();
    }

    try {
      this.fileWatcher = fs.watch(this.file(), (event, filename) => {
        this.emitter.emit('db-updated');
      });
    } catch (error) {
      let watchErrorUrl = 'https://github.com/atom/atom/blob/master/docs/build-instructions/linux.md#typeerror-unable-to-watch-path';
      let filename = path.basename(this.file());
      let errorMessage = `<b>Project Manager</b><br>Could not watch changes
        to ${filename}. Make sure you have permissions to ${this.file()}.
        On linux there can be problems with watch sizes.
        See <a href='${watchErrorUrl}'> this document</a> for more info.>`;
      atom.notifications.addError(errorMessage, {dismissable: true});
    }
  }

  updateFile() {
    fs.exists(this.file(true), (exists) => {
      if (!exists) {
        this.writeFile({});
      }
    });
  }

  generateID(string) {
    return string.replace(/\s+/g, '').toLowerCase();
  }

  file() {
    let filename = 'projects.cson';
    let filedir = atom.getConfigDirPath();

    if (this.environmentSpecificProjects) {
      hostname = os.hostname().split('.').shift().toLowerCase();
      filename = `projects.${hostname}.cson`;
    }

    filepath = `${filedir}/${filename}`;

    return filepath;
  }

  readFile(callback) {
    fs.exists(this.file(), (exists) => {
      if (exists) {
        let projects = CSON.readFileSync(this.file()) || {};
        callback(projects);
      } else {
        fs.writeFile(this.file(), '{}', (error) => {
          callback({});
        });
      }
    });
  }

  writeFile(projects, callback) {
    CSON.writeFileSync(this.file(), projects);
    if (callback) {
      callback();
    }
  }
}
