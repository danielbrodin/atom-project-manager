{Emitter} = require 'atom'
CSON = require 'season'
fs = require 'fs'
_ = require 'underscore-plus'

module.exports =
class DB
  filepath: null
  searchValue: null
  searchKey: null

  constructor: (searchValue, searchKey) ->
    @searchValue = searchValue
    @searchKey = searchKey
    @emitter = new Emitter

    fs.exists @file(), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create the file for storing projects"
      else
        @subscribeToProjectsFile()

  # FIND
  # TODO: Add support for @searchValue array
  find: (callback, filter=true) =>

    CSON.readFile @file(), (error, results) =>
      found = false
      unless error
        projects = []

        # "JOIN" on templates :)
        for key, result of results
          result._id = key
          if result.template? and results[result.template]?
            result = _.deepExtend(result, results[result.template])
          projects.push(result)

        if filter and @searchKey and @searchValue
          for key, project of projects
            if typeof project[@searchKey] is 'object'
              if @searchValue in project[@searchKey]
                found = project
            else if project[@searchKey] is @searchValue
              found = project
        else
          found = projects

        callback(found)

  ## CREATE
  add: (project, callback) ->
    projects = CSON.readFileSync(@file()) || {}
    id = project.title.replace(/\s+/g, '').toLowerCase()

    projects[id] = project
    successMessage = "#{project.title} has been added"
    errorMessage = "#{project.title} could not be saved"

    CSON.writeFile @file(), projects, (err) ->
      unless err
        atom.notifications?.addSuccess successMessage
        project._id = id
        callback(project)
      else
        atom.notifications?.addError errorMessage

  ## UPDATE
  update: (project, callback) ->
    return false if not project._id

    CSON.readFile @file(), (error, results) =>
      unless error
        for key, value in results
          if key is project._id
            results[key] = project

      CSON.writeFile @file(), results, (err)  ->
        if err
          message = "Project could not be updated. Please try again"
          atom.notifications?.addError message
        else
          callback(true) if callback?

  ## DELETE
  # delete: (project) ->

  onUpdate: (callback) ->
    @emitter.on 'db-updated', () =>
      @find callback

  lookForChanges: =>
    # Look for changes to the environment setting
    atom.config.observe 'project-manager.environmentSpecificProjects',
      (newValue, obj = {}) =>
        previous = if obj.previous? then obj.previous else newValue
        unless newValue is previous
          @subscribeToProjectsFile()
          @updateFile()

  subscribeToProjectsFile: =>
    @fileWatcher.close() if @fileWatcher?
    @fileWatcher = fs.watch @file(), (event, filename) =>
      @emitter.emit 'db-updated'
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
