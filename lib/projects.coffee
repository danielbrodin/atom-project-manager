DB = require './db'
Project = require './project'

module.exports =
class Projects
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

  initialize: () ->
    @db = new DB()

  getAll: ->
    projectSettings = @db.findAll()
    projects = []
    for setting in projectSettings
      if setting.paths?
        project = new Project(setting)
        projects.push(project)

    return projects