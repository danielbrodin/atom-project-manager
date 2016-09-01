'use babel';

import { observable, action } from 'mobx';
import CSON from 'season';
import fs from 'fs';
import os from 'os';
import _ from 'underscore-plus';

export default class FileStore {
  @observable data = [];

  constructor() {
    fs.exists(FileStore.getPath(), exists => {
      if (exists) {
        this.observeFile();
      } else {
        this.store([]);
        this.observeFile();
      }
    });
  }

  static getPath() {
    const filedir = atom.getConfigDirPath();
    const envSettings = atom.config.get('project-manager.environmentSpecificProjects');
    let filename = 'projects-empty.cson';

    if (envSettings) {
      const hostname = os.hostname().split('.').shift().toLowerCase();
      filename = `projects.${hostname}.cson`;
    }

    return `${filedir}/${filename}`;
  }

  @action fetch() {
    CSON.readFile(FileStore.getPath(), (err, data) => {
      let results = data;
      this.data.clear();

      // Support for old structure.
      if (Array.isArray(results) === false) {
        results = Object.keys(results).map(k => results[k]);
      }

      // Make sure we have an array.
      if (Array.isArray(results) === false) {
        return;
      }

      for (let result of results) {
        const templateName = result.template || null;
        const usingTemplate = results.template || null;

        if (usingTemplate) {
          const template = results.map(props => props.title === templateName);

          if (template) {
            result = _.deepExtend({}, template, result);
          }
        }

        if (this.isProject(result)) {
          result.paths = result.paths.map(this.fixPath);
          result.source = 'file';

          this.data.push(result);
        }
      }
    });
  }

  fixPath(path) {
    if (path.charAt(0) === '~') {
      return path.replace('~', os.homedir());
    }

    return path;
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

  store(projects) {
    try {
      CSON.writeFileSync(FileStore.getPath(), projects);
    } catch (e) {
      // console.log(e);
    }
  }

  observeFile() {
    if (this.fileWatcher) {
      this.fileWatcher.close();
    }

    try {
      this.fileWatcher = fs.watch(FileStore.getPath(), () => {
        this.fetch();
      });
    } catch (error) {
      // console.log(error);
    }
  }
}
