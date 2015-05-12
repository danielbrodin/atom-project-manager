_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  properties: [
    'title', 'icon', 'paths', 'settings', 'group', 'devMode', 'template'
  ]
  requiredProperties: ['title', 'paths']

  title: null
  icon: 'icon-chevron-right'
  paths: []
  settings: {}
  group: null
  devMode: false
  template: null

  db: null
  projectSettings: null

  constructor: (properties=null) ->
    if properties
      @initProperties(properties)

  initProperties: (properties) =>
    for key, value of properties
      @properties.push(key) unless key in @properties
      @[key] = value

  loadCurrent: (callback) =>
    paths = atom.project.getPaths()
    path = paths[0]
    @db ?= new DB(path, 'paths')
    @db.find (settings) =>
      if settings
        console.log 'loadcurrent', settings
        @initProperties(settings)
        @load()

        @db.onUpdate (settings) =>
          @settings = settings
          @load()
          console.log 'An update :)'
        callback(true)
      else
        callback(false)

  isCurrent: =>
    isCurrent = true
    paths = atom.project.getPaths()
    for path in paths
      if not path in @paths
        isCurrent = false

    return isCurrent

  getProperties: ->
    properties = {}
    for key in @properties
      properties[key] = @[key] if key of @
    return properties

  isValid: ->
    valid = true
    for key in @requiredProperties
      if not @[key] or not @[key].length
        valid = false
    return valid

  # TODO
  # Look for a settings file in root folder
  # to merge with project settings
  load: ->
    if @isCurrent()
      @projectSettings ?= new Settings()
      @projectSettings.load(@settings)

  ###
    TODO:
      Add ID to all projects
      Could be the same as key perhaps?
  ###
  save: =>
    properties = @getProperties()
    @db ?= new DB()
    @db.add properties, (newProject) =>
      @_id = newProject._id

  remove: ->
    @db = new DB() unless @db
    removed = @db.delete @

  open: ->
    atom.open options =
      pathsToOpen: @paths
      devMode: @devMode