_ = require 'underscore-plus'
DB = require './db'
Project = require './project'

module.exports =
class Projects
  db: null

  constructor: () ->
    @db = new DB()

  getAll: (callback) ->
    @db.findAll (projectSettings) ->
      projects = []
      for key, setting of projectSettings
        if setting.paths?
          project = new Project(setting)
          projects.push(project)
      callback(projects)

  getCurrent: (callback) ->
    paths = atom.project.getPaths()
    path = paths[0]
    @db.find path, 'paths', (settings) ->
      project = new Project(settings)
      callback(project)