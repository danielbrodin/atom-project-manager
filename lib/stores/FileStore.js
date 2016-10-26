'use babel';

import { observable, action, asFlat, transaction } from 'mobx';
import CSON from 'season';
import fs from 'fs';
import os from 'os';
import { deepExtend, each } from 'underscore-plus';

export default class FileStore {
  @observable data = asFlat([]);
  @observable fetching = false;
  templates = [];

  constructor() {
    fs.exists(FileStore.getPath(), (exists) => {
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
    this.fetching = true;
    CSON.readFile(FileStore.getPath(), (err, data) => {
      transaction(() => {
        let results = [];
        if (err) {
          FileStore.handleError(err);
        }
        if (!err && data !== null) {
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

        each(results, (res) => {
          let result = res;
          const templateName = result.template || null;

          if (templateName) {
            const template = results.filter(props => props.title === templateName);

            if (template.length) {
              result = deepExtend({}, template[0], result);
            }
          }

          if (FileStore.isProject(result)) {
            result.source = 'file';

            this.data.push(result);
          } else {
            this.templates.push(result);
          }
        }, this);

        this.fetching = false;
      });
    });
  }

  static handleError(err) {
    switch (err.name) {
      case 'SyntaxError': {
        atom.notifications.addError('There is a syntax error in your projects file. Run **Project Manager: Edit Projects** to open and fix the issue.', {
          detail: err.message,
          description: `Line: ${err.location.first_line} Row: ${err.location.first_column}`,
          dismissable: true,
        });
        break;
      }

      default: {
        // No default.
      }
    }
  }

  static isProject(settings) {
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
