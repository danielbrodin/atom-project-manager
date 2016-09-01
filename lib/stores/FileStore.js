'use babel';

import { observable, action } from 'mobx';
import CSON from 'season';
import fs from 'fs';
import os from 'os';
import _ from 'underscore-plus';

export default class FileStore {
  @observable data = [];

  constructor() {
    fs.exists(FileStore.file, exists => {
      if (exists) {
        this.observeFile();
      } else {
        this.writeFile([]);
        this.observeFile();
      }
    });
  }

  static get file() {
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
    CSON.readFile(FileStore.file, (err, data) => {
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
        const template = result.template || null;

        if (this.isProject(result)) {
          if (template && results[template] !== null) {
            const templateSettings = results[template];
            const projectSettings = result;
            result = _.deepExtend({}, templateSettings, projectSettings);
          }

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

  writeFile(projects) {
    try {
      CSON.writeFileSync(FileStore.file, projects);
    } catch (e) {
      // console.log(e);
    }
  }

  observeFile() {
    if (this.fileWatcher) {
      this.fileWatcher.close();
    }

    try {
      this.fileWatcher = fs.watch(FileStore.file, () => {
        this.fetch();
      });
    } catch (error) {
      // console.log(error);
    }
  }
}
