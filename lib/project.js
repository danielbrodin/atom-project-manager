'use babel';

import {Emitter} from 'atom';
import _ from 'underscore-plus';
import Settings from './settings';
import DB from './db';

export default class Project {

  constructor(props={}) {
    this.props = {};
    this.emitter = new Emitter();
    this.db = new DB();
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

  updateProps(props) {
    this.props = _.deepExtend(this.defaultProps, props);
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
      this.db.setSearchQuery('_id', this.props._id);
      this.db.onUpdate((props) => {
        if (props) {
          const updatedProps = _.deepExtend(this.defaultProps, props);
          if (!_.isEqual(this.props, updatedProps)) {
            this.updateProps(props);
            this.emitter.emit('updated');
            if (this.isCurrent()) {
              this.load();
            }
          }
        } else {
          this.db.setSearchQuery('paths', this.props.paths);
          this.db.find((props) => {
            this.updateProps(props);
            this.db.setSearchQuery('_id', this.props._id);
            this.emitter.emit('updated');
            if (this.isCurrent()) {
              this.load();
            }
          });
        }
      });
    }
  }

  isCurrent() {
    const activePath = atom.project.getPaths()[0];
    const mainPath = (this.props && this.props.paths && this.props.paths[0])
      ? this.props.paths[0] : null;
    if (activePath === mainPath) {
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
      let projectSettings = new Settings();
      projectSettings.load(this.props.settings);
    }
  }

  save() {
    if (this.isValid()) {
      if (this.props._id) {
        this.db.update(this.getPropsToSave());
      } else {
        this.db.add(this.getPropsToSave(), id => {
          this.props._id = id;
          this.lookForUpdates();
        });
      }

      return true;
    }

    return false;
  }

  remove() {
    this.db.delete(this.props._id);
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
      setTimeout(function() {
        win.close();
      }, 0);
    }
  }

  onUpdate(callback) {
    this.emitter.on('updated', () => callback());
  }
}
