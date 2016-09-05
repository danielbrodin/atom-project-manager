'use babel';

import mobx, { observable, computed, extendObservable, action } from 'mobx';
import fs from 'fs';
import os from 'os';
import CSON from 'season';

export default class Project {
  @observable props = {}

  @computed get title() {
    return this.props.title;
  }

  @computed get paths() {
    const paths = this.props.paths.map(path => {
      if (path.charAt(0) === '~') {
        return path.replace('~', os.homedir());
      }

      return path;
    });

    return paths;
  }

  @computed get group() {
    return this.props.group;
  }

  @computed get rootPath() {
    return this.paths[0];
  }

  @computed get isCurrent() {
    const activePath = atom.project.getPaths()[0];

    if (activePath === this.rootPath) {
      return true;
    }

    return false;
  }

  static get defaultProps() {
    return {
      title: '',
      group: '',
      paths: [],
      icon: 'icon-chevron-right',
      settings: {},
      devMode: false,
      template: null,
      source: null,
    };
  }

  constructor(props) {
    extendObservable(this.props, Project.defaultProps);
    this.updateProps(props);
  }

  updateProps(props) {
    extendObservable(this.props, props);
  }

  getProps() {
    return mobx.toJS(this.props);
  }

  get lastModified() {
    let mtime = 0;
    try {
      const stats = fs.statSync(this.rootPath);
      mtime = stats.mtime;
    } catch (e) {
      mtime = new Date(0);
    }

    return mtime;
  }

  /**
   * Fetch settings that are saved locally with the project
   * if there are any.
   */
  @action fetchLocalSettings() {
    const file = `${this.rootPath}/project.cson`;
    CSON.readFile(file, (err, settings) => {
      if (err) {
        return;
      }

      extendObservable(this.props.settings, settings);
    });
  }
}
