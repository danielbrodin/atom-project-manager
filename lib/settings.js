'use babel';

import _ from 'underscore-plus';

export default class Settings {

  update(settings={}) {
    this.load(settings);
  }

  load(settings={}) {
    if (settings.global != null) {
      settings['*'] = settings.global;
      delete settings.global;
    }

    if (settings['*'] != null) {
      let scopedSettings = settings;
      settings = settings['*'];
      delete scopedSettings['*'];

      let setting = null;
      for (scope in scopedSettings) {
        setting = scopedSettings[scope];
        this.set(setting, scope);
      }
    }

    this.set(settings);
  }

  set(settings, scope) {
    let flatSettings = {};
    let options = scope ? {scopeSelector: scope} : {};
    options.save = false;
    this.flatten(flatSettings, settings);

    for (setting in flatSettings) {
      let value = flatSettings[setting];
      if (_.isArray(value)) {
        let valueOptions = scope ? {scope: scope} : {};
        let currentValue = atom.config.get(setting, valueOptions);
        value = _.union(currentValue, value);
      }

      atom.config.set(setting, value, options);
    }
  }

  flatten(root, dict, path) {
    let key;
    let value;
    let dotPath;
    let isObject;
    for (key in dict) {
      value = dict[key];
      dotPath = path ? `${path}.${key}` : key;
      isObject = !_.isArray(value) && _.isObject(value);

      if (isObject) {
        this.flatten(root, dict[key], dotPath);
      } else {
        root[dotPath] = value;
      }
    }
  }
}
