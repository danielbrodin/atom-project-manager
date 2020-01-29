'use babel';

import { observable, action } from 'mobx';
import findit from 'findit';
import path from 'path';
import untildify from 'untildify';

export default class GitStore {
  @observable data = observable.array({ deep: false });

  constructor() {
    const ignoreDirectories = atom.config.get('project-manager.ignoreDirectories');
    this.ignore = ignoreDirectories.replace(/ /g, '').split(',');
  }

  @action fetch() {
    const projectHome = atom.config.get('core.projectHome');
    const finder = findit(untildify(projectHome));
    this.data.clear();

    finder.on('directory', (dir, stat, stop) => {
      const base = path.basename(dir);
      const projectPath = path.dirname(dir);
      const projectName = path.basename(projectPath);

      if (base === '.git') {
        this.data.push({
          title: projectName,
          paths: [projectPath],
          source: 'git',
          icon: 'icon-repo',
        });
      }

      if (this.ignore.includes(base)) {
        stop();
      }
    });
  }

  @action empty() {
    this.data.clear();
  }
}
