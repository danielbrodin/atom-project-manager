DB = require './db'
Project = require './project'

module.exports =
class Projects
  db: null

  constructor: ->
    @db = new DB()

  getAll: (callback) ->
    @db.findAll (projectSettings) ->
      projects = []
      for setting in projectSettings
        if setting.paths?
          project = new Project(setting)
          projects.push(project)

      callback(projects)