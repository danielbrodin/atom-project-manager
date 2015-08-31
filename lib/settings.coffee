<<<<<<< HEAD
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

  resetUserSettings: (settings, scope) ->
    _ = require 'underscore-plus'
=======
_ = require 'underscore-plus'

module.exports =
class Settings
  update: (settings={}) ->
    @load(settings)

  load: (settings={}) ->
    if settings.global?
      settings['*'] = settings.global
      delete settings.global

    if settings['*']?
      scopedSettings = settings
      settings = settings['*']
      delete scopedSettings['*']

      @set setting, scope for scope, setting of scopedSettings

    @set settings

  set: (settings, scope) ->
>>>>>>> Rewrite
    flatSettings = {}
    options = if scope then {scopeSelector: scope} else {}
    options.save = false

    @flatten flatSettings, settings
    for setting, value of flatSettings
      if _.isArray value
        valueOptions = if scope then {scope: scope} else {}
        currentValue = atom.config.get setting, valueOptions
        value = _.union currentValue, value
      atom.config.set setting, value, options

<<<<<<< HEAD
  enable: (settings) ->
    if settings.global?
      settings['*'] = settings.global
      delete settings.global

    if settings['*']?
      scopedSettings = settings
      settings = settings['*']
      delete scopedSettings['*']

      @resetUserSettings setting, scope for scope, setting of scopedSettings

    @resetUserSettings settings
=======
  flatten: (root, dict, path) ->
    for key, value of dict
      dotPath = key
      dotPath = "#{path}.#{key}" if path?
      isObject = not _.isArray(value) and _.isObject(value)
      if not isObject
        root[dotPath] = value
      else
        @flatten root, dict[key], dotPath
>>>>>>> Rewrite
