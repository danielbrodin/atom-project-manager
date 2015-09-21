{Emitter} = require 'atom'
CSON = require 'season'
fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'

module.exports =
class DB
  filepath: null

  constructor: (@searchKey, @searchValue) ->
    @emitter = new Emitter

    fs.exists @file(), (exists) =>
      unless exists
        @writeFile({})
      else
        @subscribeToProjectsFile()

  setSearchQuery: (@searchKey, @searchValue) ->

  # FIND
  # TODO: Add support for @searchValue array
  find: (callback) =>

    @readFile (results) =>
      found = false
      projects = []

      # "JOIN" on templates :)
      for key, result of results
        result._id = key
        if result.template? and results[result.template]?
          result = _.deepExtend(result, results[result.template])
        projects.push(result)

      if @searchKey and @searchValue
        for key, project of projects
          if _.isEqual project[@searchKey], @searchValue
            found = project
      else
        found = projects

      callback?(found)

  add: (props, callback) ->
    @readFile (projects) =>
      id = @generateID(props.title)
      projects[id] = props

      @writeFile projects, () ->
        atom.notifications?.addSuccess "#{props.title} has been added"
        callback?(id)

  update: (props, callback) ->
    return false if not props._id

    @readFile (projects) =>
      for key, data of projects
        if key is props._id
          delete(props._id)
          projects[key] = props

      @writeFile projects, () ->
        callback?()

  delete: (id, callback) ->
    @readFile (projects) =>
      for key, data of projects
        if key is id
          delete(projects[key])

      @writeFile projects, () ->
        callback?()

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

    try
      @fileWatcher = fs.watch @file(), (event, filename) =>
        @emitter.emit 'db-updated'
    catch error
      watchErrorUrl = 'https://github.com/atom/atom/blob/master/docs/build-instructions/linux.md#typeerror-unable-to-watch-path'
      atom.notifications?.addError """
        <b>Project Manager</b><br>
        Could not watch for changes to `#{path.basename(@file())}`.
        Make sure you have permissions to `#{@file()}`. On linux there
        can be problems with watch sizes. See <a href='#{watchErrorUrl}'>
        this document</a> for more info.""",
        dismissable: true

  updateFile: ->
    fs.exists @file(true), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create the file for storing projects"

  generateID: (string) ->
    string.replace(/\s+/g, '').toLowerCase()

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

  readFile: (callback) ->
    fs.exists @file(), (exists) =>
      if exists
        try
          projects = CSON.readFileSync(@file()) || {}
          callback?(projects)
        catch error
          message = "Failed to load #{path.basename(this.file())}"
          detail = if error.location?
            error.stack
          else
            error.message
          @notifyFailure message, detail
      else
        fs.writeFile @file(), '{}', (error) ->
          callback?({})

  writeFile: (projects, callback) ->
    CSON.writeFileSync @file(), projects
    callback?()

  notifyFailure: (message, detail) ->
    atom.notifications.addError(message, {detail, dismissable: true})