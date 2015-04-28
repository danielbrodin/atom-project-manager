Datastore = require 'nedb'

module.exports =
class DB
  db: null
  filepath: null

  initialize: ->
    dbSettings =
      filename: @file()
      autoload: true

    @db = new Datastore(dbSettings)

    @lookForChanges()

  ## CREATE
  add: (project) ->
    if not project._id
      @db.insert project

  ## FIND
  findCurrent: ->
    paths = atom.project.getPaths()
    path = paths[0]
    @find(path)

  find: (value='', key='paths') ->
    findBy = {}
    findBy[key] = value
    @db.findOne findBy, (err, data) ->
      return data

  ## UPDATE
  update: (project) ->
    @db.update project


  ## DELETE
  delete: (project) ->
    return false unless project._id
    @db.remove {_id: project._id}, {}, (err, numRemoved) ->
      return numRemoved


  lookForChanges: ->
    # Look for changes to the environment setting
    atom.config.observe 'project-manager.environmentSpecificProjects',
      (newValue, obj = {}) =>
        previous = if obj.previous? then obj.previous else newValue
        unless newValue is previous
          dbSettings =
            filename: @file(true)
            autoload: true
          @db = new Datastore(dbSettings)
          # @subscribeToProjectsFile()

  file: (update=false) ->
    @filepath = null if update

    unless @filepath?
      filename = 'projects'
      filedir = atom.getConfigDirPath()

      if atom.config.get('project-manager.environmentSpecificProjects')
        os = require 'os'
        hostname = os.hostname().split('.').shift().toLowerCase()
        filename = "projects.#{hostname}"

      @filepath = "#{filedir}/#{@filename}"
    @filepath