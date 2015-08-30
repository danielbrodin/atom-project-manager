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

  add: (props, callback) ->
    projects = CSON.readFileSync(@file()) || {}
    id = props.title.replace(/\s+/g, '').toLowerCase()

    projects[id] = props
    successMessage = "#{props.title} has been added"
    errorMessage = "#{props.title} could not be saved"

    CSON.writeFile @file(), projects, (err) ->
      unless err
        atom.notifications?.addSuccess successMessage
        props._id = id
        callback(props._id)
      else
        atom.notifications?.addError errorMessage
        callback(false)

  update: (props, callback) ->
    return false if not props._id

    projects = CSON.readFileSync @file()

    for key, data of projects
      if key is props._id
        delete(props._id)
        projects[key] = props

    CSON.writeFileSync @file(), projects
    callback?(true)

  delete: (id, callback) ->
    projects = CSON.readFileSync @file()

    for key, data of projects
      if key is id
        delete(projects[key])

    CSON.writeFileSync @file(), projects
    callback()

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
