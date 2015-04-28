_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  allowedProperties: [
    '_id', 'title', 'icon', 'paths', 'settings', 'group', 'devMode'
  ]
  # properties:
  title: ''
  icon: 'icon-chevron-right'
  paths: []
  settings: {}
  group: null
  devMode: false
  template: null

  db: null
  projectSettings: null

  constructor: (properties={}, newProject=false) ->
    # if settings.template
    #   @db = new DB() unless @db
    #   template = @db.find('title', settings.template)
    #   settings = _.deepExtend(settings, template)

    for key, value of properties
      if key in @allowedProperties
        @[key] = value

    if newProject
      @save()

    if @settings
      @projectSettings = new Settings()
      @projectSettings.load(@settings)

  getProperties: ->
    properties = {}
    for key in @allowedProperties
      properties[key] = @[key] if @[key]?
    return properties

  load: ->
    Settings.load(@settings)

  save: ->
    properties = @getProperties()
    @db = new DB() unless @db
    @db.add properties, (newProject) =>
      @_id = newProject._id

  remove: ->
    @db = new DB() unless @db
    removed = @db.delete @

  open: ->
    atom.open options =
      pathsToOpen: @paths
      devMode: @devMode