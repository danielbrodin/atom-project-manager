{Emitter} = require 'atom'
_ = require 'underscore-plus'
DB = require './db'
Project = require './project'

module.exports =
class Projects
  db: null
  
  constructor: () ->
    @emitter = new Emitter
    @db = new DB()

    @db.onUpdate () =>
      @emitter.emit 'projects-updated'

  onUpdate: (callback) ->
    @emitter.on 'projects-updated', callback

  getAll: (callback) ->
    @db.find (projectSettings) ->
      projects = []
      for key, setting of projectSettings
        if setting.paths?
          project = new Project(setting)
          projects.push(project)
      callback(projects)

  getCurrent: (callback) ->
    @getAll (projects) ->
      for project in projects
        if project.isCurrent()
          callback(project)