'use babel';

import _ from 'underscore-plus';

export default class Settings {
  update(settings={}) {
    this.load(settings);
  }

  load(settings={}) {
    if ('global' in settings) {
      settings['*'] = settings.global;
      delete settings.global;
    }

    if ('*' in settings) {
      let scopedSettings = settings;
      settings = settings['*'];
      delete scopedSettings['*'];

      let setting;
      let scope;
      for (scope in scopedSettings) {
        setting = scopedSettings[scope];
        this.set(setting, scope);
      }
    }

    this.set(settings);
  }

  set(settings, scope) {
    let flatSettings = {};
    let setting;
    let value;
    let valueOptions;
    let currentValue;
    let options = scope ? {scopeSelector: scope} : {};
    options.save = false;
    this.flatten(flatSettings, settings);

    for (setting in flatSettings) {
      value = flatSettings[setting];

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
