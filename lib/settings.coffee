_ = require 'underscore-plus'

module.exports =
class Settings
  cosntructor: ()->

  update: (settings={}) ->
    @load(settings)

  load: (settings={}) ->
    flatSettings = {}
    @flattenSettings flatSettings, settings
    for setting, value of flatSettings
      if _.isArray value
        currentValue = atom.config.get setting
        value = _.union currentValue, value
      atom.config.setRawValue setting, value
    atom.config.emit 'updated'

  flattenSettings: (root, dict, path) ->
    for key, value of dict
      dotPath = key
      dotPath = "#{path}.#{key}" if path?
      isObject = not _.isArray(value) and _.isObject(value)
      if not isObject
        root[dotPath] = value
      else
        @flattenSettings root, dict[key], dotPath