'use babel';

import { observable, computed, extendObservable, action, toJS } from 'mobx';
import fs from 'fs';
import untildify from 'untildify';
import CSON from 'season';

export default class Project {
  @observable props = {}
  @observable stats = null;

  @computed get title() {
    return this.props.title;
  }

  @computed get paths() {
    return this.props.paths.map(path => untildify(path));
  }

  @computed get group() {
    return this.props.group;
  }

  @computed get rootPath() {
    return this.paths[0];
  }

  @computed get settings() {
    return toJS(this.props.settings);
  }

  @computed get source() {
    return this.props.source;
  }

  @computed get lastModified() {
    let mtime = new Date(0);
    if (this.stats) {
      mtime = this.stats.mtime;
    }

    return mtime;
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
    this.setFileStats();
  }

  getProps() {
    return toJS(this.props);
  }

  getChangedProps() {
    const { ...props } = this.getProps();
    const defaults = Project.defaultProps;

    Object.keys(defaults).forEach((key) => {
      switch (key) {
        case 'settings': {
          if (Object.keys(props[key]).length === 0) {
            delete props[key];
          }
          break;
        }

        default: {
          if (props[key] === defaults[key]) {
            delete props[key];
          }
        }
      }
    });

    return props;
  }

  @action setFileStats() {
    fs.stat(this.rootPath, (err, stats) => {
      if (!err) {
        this.stats = stats;
      }
    });
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
