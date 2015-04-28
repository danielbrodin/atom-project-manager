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