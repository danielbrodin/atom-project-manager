{Emitter} = require 'atom'
_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  requiredProperties: ['title', 'paths']
  db: null
  projectSettings: null

  constructor: (@props={}) ->
    @emitter = new Emitter
    @db = new DB()
    @updateProps @props
    @lookForUpdates()

  updateProps: (props) ->
    @propsToSave = []
    for key, value of props
      @propsToSave.push(key) unless key in @propsToSave
    @props = _.deepExtend @getDefaultProps(), props

  getDefaultProps: ->
    props =
      title: ''
      paths: []
      icon: 'icon-chevron-right'
      settings: {}
      group: null
      devMode: false
      template: null

  set: (key, value) =>
    @props[key] = value
    @propsToSave.push(key) unless key in @propsToSave
    @save()

  unset: (key) ->
    defaults = @getDefaultProps()
    delete(@props[key])
    @propsToSave = _.without @propsToSave, key
    @props[key] = defaults[key] if defaults[key]?
    @save()

  lookForUpdates: =>
    if @props._id?
      @db.setSearchQuery '_id', @props._id
      @db.onUpdate (props) =>
        updatedProps = _.deepExtend @getDefaultProps(), updatedProps
        if not _.isEqual @props, updatedProps
          @updateProps props
          @emitter.emit 'updated'
          if @isCurrent()
            @load()

  isCurrent: =>
    activePath = atom.project.getPaths()[0]
    projectPath = @props.paths[0]
    if activePath is projectPath
      return true
    return false

  isValid: ->
    valid = true
    for key in @requiredProperties
      if not @props[key] or not @props[key].length
        valid = false
    return valid

  # TODO
  # Look for a settings file in root folder
  # to merge with project settings
  load: ->
    if @isCurrent()
      @projectSettings ?= new Settings()
      @projectSettings.load(@props.settings)

  save: =>
    if @isValid()
      @db ?= new DB()
      props = {}
      for key, value in @propsToSave
        props[key] = @props[key]

      if @props._id
        @db.update(props)
      else
        @db.add props, (id) =>
          @props._id = id
          @lookForUpdates()
      return true
    else
      return false

  remove: ->
    @db ?= new DB()
    removed = @db.delete @props._id

  open: ->
    atom.open options =
      pathsToOpen: @props.paths
      devMode: @props.devMode

  onUpdate: (callback) ->
    @emitter.on 'updated', () ->
      callback()