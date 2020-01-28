'use babel';

import { each, isArray, isObject } from 'underscore-plus';

export default class Settings {
  update(settings = {}) {
    this.load(settings);
  }

  load(values = {}, src = undefined) {
    let settings = values;
    if ('global' in settings) {
      settings['*'] = settings.global;
      delete settings.global;
    }

    if ('*' in settings) {
      const scopedSettings = settings;
      settings = settings['*'];
      delete scopedSettings['*'];

      each(scopedSettings, (k,v) => { this.set(k,v,src) }, this);
    }

    this.set(settings, undefined, src);
  }

  set(settings, scope, src) {
    const flatSettings = {};
    const options = scope ? { scopeSelector: scope } : {};
    options.save = false;
    // options.source = src;
    // options.scopeSelector = "source.js"

    console.log(options);

    this.flatten(flatSettings, settings);


    each(flatSettings, (value, key) => {
      atom.config.set(key, value, options);
    });
  }

  flatten(root, dict, path) {
    let dotPath;
    let valueIsObject;

    each(dict, (value, key) => {
      dotPath = path ? `${path}.${key}` : key;
      valueIsObject = !isArray(value) && isObject(value);

      if (valueIsObject) {
        this.flatten(root, dict[key], dotPath);
      } else {
        root[dotPath] = value; // eslint-disable-line no-param-reassign
      }
    }, this);
  }
}
