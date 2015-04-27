Project = require './project'
DB = require './db'

module.exports =
class Manager
  db: null
  project: null
  filepath: null

  activate: (state)->
    @db = new DB()
    projectSettings = @db.findCurrent()

    if project
      @project = new Project(projectSettings)
      @project.load()