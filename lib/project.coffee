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

  constructor: (@properties, newProject=false) ->
    if newProject
      @save()

  getProperties: ->
    properties = {}
    for key in @allowedProperties
      properties[key] = @[key] if @[key]?
    return properties

  load: ->
    @projectSettings ?= new Settings()
    @projectSettings.load(@settings)

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