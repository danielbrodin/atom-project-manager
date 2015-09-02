_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  requiredProperties: ['title', 'paths']
  db: null
  projectSettings: null

  constructor: (props={}) ->
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
    unset(@props[key])
    unset(@propsToSave[key])
    @save()

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
        @db.add props, (newProject) =>
          @props._id = newProject._id

  remove: ->
    @db ?= new DB()
    removed = @db.delete @props._id

  open: ->
    atom.open options =
      pathsToOpen: @props.paths
      devMode: @props.devMode