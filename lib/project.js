'use babel';

import {Emitter} from 'atom';
import _ from 'underscore-plus';
import Settings from './settings';
import fs from 'fs';
import db from './db';
import CSON from 'season';

export default class Project {

  constructor(props={}) {
    this.props = this.defaultProps;
    this.emitter = new Emitter();
    this.settings = new Settings();
    this.updateProps(props);
    this.lookForUpdates();
  }

  get requiredProperties() {
    return ['title', 'paths'];
  }

  get defaultProps() {
    return {
      title: '',
      paths: [],
      icon: 'icon-chevron-right',
      settings: {},
      group: null,
      devMode: false,
      template: null
    };
  }

  get rootPath() {
    if (this.props.paths[0]) {
      return this.props.paths[0];
    }

    return '';
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

  updateProps(props) {
    const activePaths = atom.project.getPaths();
    const newProps = _.clone(this.props);
    _.deepExtend(newProps, props);
    this.props = newProps;

    if (this.isCurrent()) {
      // Add any new paths.
      for (const path of this.props.paths) {
        if (activePaths.indexOf(path) < 0) {
          atom.project.addPath(path);
        }
      }

      // Remove paths that have been removed.
      for (const activePath of activePaths) {
        if (this.props.paths.indexOf(activePath) < 0) {
          atom.project.removePath(activePath);
        }
      }
    }

    try {
      const stats = fs.statSync(this.rootPath);
      this.stats = stats;
    } catch (e) {
      this.stats = false;
    }
  }

  getPropsToSave() {
    let saveProps = {};
    let value;
    let key;
    for (key in this.props) {
      value = this.props[key];
      if (!this.isDefaultProp(key, value)) {
        saveProps[key] = value;
      }
    }

    return saveProps;
  }

  isDefaultProp(key, value) {
    if (!this.defaultProps.hasOwnProperty(key)) {
      return false;
    }

    const defaultProp = this.defaultProps[key];
    if (typeof defaultProp === 'object' && _.isEqual(defaultProp, value)) {
      return true;
    }

    if (defaultProp === value) {
      return true;
    }

    return false;
  }

  set(key, value) {
    if (typeof key === 'object') {
      for (let i in key) {
        value = key[i];
        this.props[i] = value;
      }

      this.save();
    } else {
      this.props[key] = value;
      this.save();
    }
  }

  unset(key) {
    if (_.has(this.defaultProps, key)) {
      this.props[key] = this.defaultProps[key];
    } else {
      this.props[key] = null;
    }

    this.save();
  }

  lookForUpdates() {
    if (this.props._id) {
      const id = this.props._id;
      const query = {
        key: 'paths',
        value: this.props.paths
      };
      db.addUpdater(id, query, (props) => {
        if (props) {
          const updatedProps = this.defaultProps;
          _.deepExtend(updatedProps, props);
          if (!_.isEqual(this.props, updatedProps)) {
            this.updateProps(props);
            this.emitter.emit('updated');

            if (this.isCurrent()) {
              this.load();
            }
          }
        }
      });
    }
  }

  isCurrent() {
    const activePath = atom.project.getPaths()[0];
    if (activePath === this.rootPath) {
      return true;
    }

    return false;
  }

  isValid() {
    let valid = true;
    this.requiredProperties.forEach(key => {
      if (!this.props[key] || !this.props[key].length) {
        valid = false;
      }
    });

    return valid;
  }

  load() {
    if (this.isCurrent()) {
      this.checkForLocalSettings();
      this.settings.load(this.props.settings);
    }
  }

  checkForLocalSettings() {
    if (this.localSettingsWatcher) {
      this.localSettingsWatcher.close();
    }

    if (!this.localSettingsChecked) {
      this.localSettingsChecked = true;
      try {
        const localSettingsFile = `${this.rootPath}/project.cson`;
        const settings = CSON.readFileSync(localSettingsFile);

        if (settings) {
          this.localSettingsWatcher = fs.watch(localSettingsFile, () => {
            this.localSettingsChecked = false;

            if (this.isCurrent()) {
              this.load();
            } else {
              this.checkForLocalSettings();
            }
          });

          this.updateProps(settings);
        }
      } catch (e) {}
    }
  }

  save() {
    if (this.isValid()) {
      if (this.props._id) {
        db.update(this.getPropsToSave());
      } else {
        db.add(this.getPropsToSave(), id => {
          this.props._id = id;
          this.lookForUpdates();
        });
      }

      return true;
    }

    return false;
  }

  remove() {
    db.delete(this.props._id);
  }

  open() {
    const win = atom.getCurrentWindow();
    const closeCurrent = atom.config.get('project-manager.closeCurrent');

    atom.open({
      pathsToOpen: this.props.paths,
      devMode: this.props.devMode,
      newWindow: closeCurrent
    });

    if (closeCurrent) {
      setTimeout(function () {
        win.close();
      }, 0);
    }
  }

  onUpdate(callback) {
    this.emitter.on('updated', () => callback());
  }
}
