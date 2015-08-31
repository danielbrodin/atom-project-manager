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
        @writeFile({})
        # fs.writeFile @file(), '{}', (error) ->
        #   if error
        #     atom.notifications?.addError "Project Manager", options =
        #       details: "Could not create the file for storing projects"
      else
        @subscribeToProjectsFile()

  # FIND
  # TODO: Add support for @searchValue array
  find: (callback, filter=true) =>

    # CSON.readFile @file(), (error, results) =>
    @readFile (results) =>
      found = false
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

      callback?(found)

  add: (props, callback) ->
    @readFile (projects) =>
      id = props.title.replace(/\s+/g, '').toLowerCase()
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
    @fileWatcher = fs.watch @file(), (event, filename) =>
      @emitter.emit 'db-updated'

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

  readFile: (callback) ->
    fs.exists @file(), (exists) =>
      if exists
        projects = CSON.readFileSync(@file()) || {}
        callback?(projects)
      else
        fs.writeFile @file(), '{}', (error) ->
          callback?({})

  writeFile: (projects, callback) ->
    CSON.writeFileSync @file(), projects
    callback?()