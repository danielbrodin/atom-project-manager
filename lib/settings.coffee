module.exports =
  flatten: (root, dict, path) ->
    _ = require 'underscore-plus'
    for key, value of dict
      dotPath = key
      dotPath = "#{path}.#{key}" if path?
      isObject = not _.isArray(value) and _.isObject(value)
      if not isObject
        root[dotPath] = value
      else
        @flatten root, dict[key], dotPath

  enable: (settings) ->
    _ = require 'underscore-plus'
    flatSettings = {}
    @flatten flatSettings, settings
    for setting, value of flatSettings
      if _.isArray value
        currentValue = atom.config.get setting
        value = _.union currentValue, value
      atom.config.setRawValue setting, value