'use babel';

import { GitRepository } from 'atom';
import { observable, action, asFlat } from 'mobx';
import findit from 'findit';
import path from 'path';
import untildify from 'untildify';

export default class GitStore {
  @observable data = asFlat([]);

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
        const repository = GitRepository.open(projectPath);

        const item = {
          title: projectName,
          paths: [projectPath],
          source: 'git',
          icon: 'icon-repo',
          repository,
        };

        this.data.push(item);
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
