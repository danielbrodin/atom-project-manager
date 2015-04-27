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

  ## CREATE
  add: (project) ->
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
    @db.remove {_id: project._id}, {}, (err, numRemoved) ->
      console.log numRemoved


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