_ = require 'underscore-plus'
Settings = require './settings'
DB = require './db'

module.exports =
class Project
  properties:
    _id: null
    title: null
    icon: null
    paths: []
    settings: {}
    group: null
    devMode: false
    template: null

  db: null

  initialize: (settings={}, newProject=false) ->
    if settings.template
      @db = new DB() unless @db
      template = @db.find('title', settings.template)
      settings = _.deepExtend(settings, template)

    for key, value in settings
      @properties[key] = value

    if newProject
      @save()

  load: ->
    Settings.load(@settings)

  save: ->
    @db = new DB() unless @db
    @db.add(@properties)

  delete: ->
    @db = new DB() unless @db
    delete = @db.delete @

  open: ->
    atom.open options =
      pathsToOpen: @properties.paths
      devMode: @properties.devMode