'use babel';

import {Emitter} from 'atom';
import CSON from 'season';
import fs from 'fs';
import path from 'path';
import os from 'os';
import _ from 'underscore-plus';

export default class CSONDB {
  constructor() {
    this.emitter = new Emitter();
    this.updaters = {};

    this.onUpdate((projects) => {
      for (let project of projects) {
        this.sendUpdate(project);
      }
    });

    fs.exists(this.file(), (exists) => {
      if (exists) {
        this.observeProjects();
      } else {
        this.writeFile({});
      }
    });
  }

  get environmentSpecificProjects() {
    return atom.config.get('project-manager.environmentSpecificProjects');
  }

  find(callback=null) {
    this.readFile(results => {
      const projects = [];

      for (const key in results) {
        let result = results[key];
        const template = result.template || null;

        if (this.isProject(result) === false) {
          continue;
        }

        result._id = key;
        if (template && results[template] !== null) {
          const templateSettings = results[template];
          const projectSettings = result;
          result = _.deepExtend({}, templateSettings, projectSettings);
        }

        for (let i in result.paths) {
          if (typeof result.paths[i] !== 'string') {
            continue;
          }

          if (result.paths[i].charAt(0) === '~') {
            result.paths[i] = result.paths[i].replace('~', os.homedir());
          }
        }

        projects.push(result);
      }

      if (callback) {
        callback(projects);
      }
    });
  }

  isProject(settings) {
    if (typeof settings.paths === 'undefined') {
      return false;
    }

    if (settings.paths.length === 0) {
      return false;
    }

    return true;
  }

  add(props, callback) {
    this.readFile(projects => {
      const id = this.generateID(props.title);
      projects[id] = props;

      this.writeFile(projects, () => {
        atom.notifications.addSuccess(`${props.title} has been added`);

        if (callback) {
          callback(id);
        }
      });
    });
  }

  update(props) {
    if (!props._id) {
      return false;
    }

    const id = props._id;
    delete props._id;

    this.readFile(projects => {
      projects[id] = props;
      this.writeFile(projects);
    });
  }

  delete(id, callback) {
    this.readFile(projects => {
      for (let key in projects) {
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

  onUpdate(callback=null) {
    this.emitter.on('db-updated', () => {
      this.find(callback);
    });
  }

  sendUpdate(project) {
    for (let key in this.updaters) {
      const {id, query, callback} = this.updaters[key];

      if (Object.keys(query).length === 0) {
        callback(project);
      } else if (id === project._id ||
        _.isEqual(project[query.key], query.value)) {
        callback(project);
      }
    }
  }

  addUpdater(id, query, callback) {
    this.updaters[id] = {
      id,
      query,
      callback
    };
  }

  observeProjects() {
    if (this.fileWatcher) {
      this.fileWatcher.close();
    }

    try {
      this.fileWatcher = fs.watch(this.file(), () => {
        this.emitter.emit('db-updated');
      });
    } catch (error) {
      let url = 'https://github.com/atom/atom/blob/master/docs/';
      url += 'build-instructions/linux.md#typeerror-unable-to-watch-path';
      const filename = path.basename(this.file());
      const errorMessage = `<b>Project Manager</b><br>Could not watch changes
        to ${filename}. Make sure you have permissions to ${this.file()}.
        On linux there can be problems with watch sizes.
        See <a href='${url}'> this document</a> for more info.>`;
      this.notifyFailure(errorMessage);
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

  updateFilepath(filepath) {
    this.filepath = filepath;
    this.observeProjects();
  }

  file() {
    if (this.filepath) {
      return this.filepath;
    }

    let filename = 'projects.cson';
    const filedir = atom.getConfigDirPath();

    if (this.environmentSpecificProjects) {
      let hostname = os.hostname().split('.').shift().toLowerCase();
      filename = `projects.${hostname}.cson`;
    }

    return `${filedir}/${filename}`;
  }

  readFile(callback=null) {
    const exists = fs.existsSync(this.file());
    let projects = null;

    if (exists) {
      try {
        projects = CSON.readFileSync(this.file()) || {};
      } catch (error) {
        console.log(error);
        const message = `Failed to load ${path.basename(this.file())}`;
        const detail = error.location != null ? error.stack : error.message;
        this.notifyFailure(message, detail);
      }
    } else {
      fs.writeFileSync(this.file(), '{}');
      projects = {};
    }

    if (callback) {
      callback(projects);
    }

    return projects;
  }

  writeFile(projects, callback) {
    try {
      CSON.writeFileSync(this.file(), projects);
    } catch (e) {
      console.log(e);
    }

    if (callback) {
      callback();
    }
  }

  notifyFailure(message, detail=null) {
    atom.notifications.addError(message, {
      detail: detail,
      dismissable: true
    });
  }
}
