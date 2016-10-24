'use babel';

import _ from 'underscore-plus';

export default class Settings {
  update(settings = {}) {
    this.load(settings);
  }

  load(values = {}) {
    let settings = values;
    if ('global' in settings) {
      settings['*'] = settings.global;
      delete settings.global;
    }

    if ('*' in settings) {
      const scopedSettings = settings;
      settings = settings['*'];
      delete scopedSettings['*'];

      for (const scope of Object.keys(scopedSettings)) {
        const setting = scopedSettings[scope];
        this.set(setting, scope);
      }
    }

    this.set(settings);
  }

  set(settings, scope) {
    const flatSettings = {};
    const options = scope ? { scopeSelector: scope } : {};
    let value;
    options.save = false;
    this.flatten(flatSettings, settings);

    for (const key of Object.keys(flatSettings)) {
      value = flatSettings[key];
      atom.config.set(key, value, options);
    }
  }

  flatten(root, dict, path) {
    let value;
    let dotPath;
    let isObject;

    for (const key of Object.keys(dict)) {
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
