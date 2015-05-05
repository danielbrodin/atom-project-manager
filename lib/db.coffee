CSON = require 'season'
fs = require 'fs'
_ = require 'underscore-plus'

module.exports =
class DB
  filepath: null
  events: {}

  constructor: (@events) ->
    fs.exists @file(), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create the file for storing projects"
      else
        @subscribeToProjectsFile()

  ## CREATE
  add: (project, callback) ->
    projects = CSON.readFileSync(@file()) || {}
    projects[project.title] = project
    successMessage = "#{project.title} has been added"
    errorMessage = "#{project.title} could not be saved to #{@file()}"

    CSON.writeFile @file(), projects, (err) ->
      unless err
        atom.notifications?.addSuccess successMessage
        callback(project)
      else
        atom.notifications?.addError errorMessage

  ## FIND
  find: (value='', key='paths', callback) ->
    CSON.readFile @file(), (error, results) ->
      found = false
      unless error
        projects = []

        # "JOIN" on templates :)
        for key, result of results
          if result.template? and results[result.template]?
            result = _.deepExtend(result, results[result.template])
          projects.push(result)

        if key and value
          for project of projects
            if typeof project[key] is 'object'
              if value in project[key]
                found = project
            else if project[key] is value
              found = project
        else
          found = projects

        callback(found)


  findCurrent: (callback) ->
    paths = atom.project.getPaths()
    path = paths[0]
    @find path, 'paths', callback

  findAll: (callback) ->
    @find '', '', callback

  ## UPDATE
  # update: (project) ->
  #   @db.update project


  ## DELETE
  # delete: (project) ->

  lookForChanges: ->
    # Look for changes to the environment setting
    atom.config.observe 'project-manager.environmentSpecificProjects',
      (newValue, obj = {}) =>
        previous = if obj.previous? then obj.previous else newValue
        unless newValue is previous
          @subscribeToProjectsFile()
          @updateFile()

  subscribeToProjectsFile: ->
    @fileWatcher.close() if @fileWatcher?
    @fileWatcher = fs.watch @file(), (event, filename) ->
      # Send update event

  updateFile: ->
    fs.exists @file(true), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create the file for storing projects"

  file: (update=false) ->
    @filepath = null if update

    unless @filepath?
      filename = 'projects.cson'
      filedir = atom.getConfigDirPath()

      if atom.config.get('project-manager.environmentSpecificProjects')
        os = require 'os'
        hostname = os.hostname().split('.').shift().toLowerCase()
        filename = "projects.#{hostname}.cson"

      @filepath = "#{filedir}/#{filename}"
    @filepath