_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  props: {}
  requiredProperties: ['title', 'paths']

  # Properties that have been set
  # as to not save default values in DB
  setProps: []

  db: null
  projectSettings: null

  constructor: (props=null) ->
    @props = @getDefaultProps()
    if props
      for key, value of props
        @setProps.push(key) unless key in @setProps
        @props[key] = value

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
    @setProps.push(key) unless key in @setProps
    @save()

  unset: (key) ->
    unset(@props[key])
    unset(@setProps[key])
    @save()

  isCurrent: =>
    isCurrent = true
    paths = atom.project.getPaths()
    for path in paths
      if not path in @props.paths
        isCurrent = false

    return isCurrent

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
    props = {}
    for key, value in @setProps
      props[key] = @props[key]

    @db ?= new DB()
    @db.add props, (newProject) =>
      @props._id = newProject._id

  remove: ->
    @db = new DB() unless @db
    removed = @db.delete @props._id

  open: ->
    atom.open options =
      pathsToOpen: @props.paths
      devMode: @props.devMode