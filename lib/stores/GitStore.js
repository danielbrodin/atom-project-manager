'use babel';

import { observable, action } from 'mobx';
import findit from 'findit';
import path from 'path';

export default class GitStore {
  @observable data = [];

  constructor() {
    this.ignore = ['node_modules', 'vendor', 'web'];
  }

  @action fetch() {
    const projectHome = atom.config.get('core.projectHome');
    const finder = findit(projectHome);
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
