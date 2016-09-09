'use babel';

import { observable, action, asFlat } from 'mobx';
import CSON from 'season';
import fs from 'fs';
import os from 'os';
import _ from 'underscore-plus';

export default class FileStore {
  @observable data = asFlat([]);
  templates = [];

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
    let filename = 'projects.cson';

    if (envSettings) {
      const hostname = os.hostname().split('.').shift().toLowerCase();
      filename = `projects.${hostname}.cson`;
    }

    return `${filedir}/${filename}`;
  }

  @action fetch() {
    CSON.readFile(FileStore.getPath(), (err, data) => {
      let results = [];
      if (!err) {
        results = data;
      }

      this.data.clear();
      this.templates = [];

      // Support for old structure.
      if (Array.isArray(results) === false) {
        results = Object.keys(results).map(k => results[k]);
      }

      // Make sure we have an array.
      if (Array.isArray(results) === false) {
        results = [];
      }

      for (let result of results) {
        const templateName = result.template || null;

        if (templateName) {
          const template = results.filter(props => props.title === templateName);

          if (template.length) {
            result = _.deepExtend({}, template[0], result);
          }
        }

        if (this.isProject(result)) {
          result.source = 'file';

          this.data.push(result);
        } else {
          this.templates.push(result);
        }
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

  store(projects) {
    const store = projects.concat(this.templates);
    try {
      CSON.writeFileSync(FileStore.getPath(), store);
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
