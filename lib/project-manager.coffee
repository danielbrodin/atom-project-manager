fs = require 'fs'

module.exports =
  configDefaults:
    showPath: false
    closeCurrent: false
    sortByTitle: false
    environmentSpecificProjects: false

  projectManagerView: null
  projectManagerAddView: null

  filepath: null

  activate: (state) ->
    fs.exists @file(), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            console.log "Error: Could not create #{@file()} - #{error}"
      else
        @subscribeToProjectsFile()
        @loadSettings()

    atom.workspaceView.command 'project-manager:save-project', =>
      @createProjectManagerAddView(state).toggle(@)
    atom.workspaceView.command 'project-manager:toggle', =>
      @createProjectManagerView(state).toggle(@)
    atom.workspaceView.command 'project-manager:edit-projects', =>
      atom.workspaceView.open @file()
    atom.workspaceView.command 'project-manager:reload-project-settings', =>
      @loadSettings()

    atom.config.observe 'project-manager.environmentSpecificProjects',
    (newValue, obj = {}) =>
      previous = if obj.previous? then obj.previous else newValue
      unless newValue is previous
        @updateFile()
        @subscribeToProjectsFile()

  file: (update = false) ->
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

  updateFile: ->
    fs.exists @file(true), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            console.log "Error: Could not create #{@file()} - #{error}"

  subscribeToProjectsFile: ->
    PathWatcher = require 'pathwatcher'
    filePath = @file()
    @pathWatcher.close() if @pathWatcher?

    @pathWatcher = PathWatcher.watch filePath, (event, path) =>
      @loadSettings()

  loadSettings: ->
    CSON = require 'season'
    CSON.readFile @file(), (error, data) =>
      unless error
        for title, project of data
          for path in project.paths
            if path is atom.project.getPath()
              if project.settings?
                @enableSettings(project.settings)
              break

  enableSettings: (settings) ->
    _ = require 'underscore-plus'

    projectSettings = {}
    for setting, value of settings
      _.setValueForKeyPath(projectSettings, setting, value)
      atom.config.settings = _.deepExtend(
        projectSettings,
        atom.config.settings)
    atom.config.emit('updated')

  addProject: (project) ->
    CSON = require 'season'
    projects = CSON.readFileSync(@file()) || {}
    projects[project.title] = project
    CSON.writeFileSync(@file(), projects)

  openProject: ({title, paths, devMode}) ->
    atom.open options =
      pathsToOpen: paths
      devMode: devMode

    if atom.config.get('project-manager.closeCurrent')
      setTimeout ->
        atom.close()
      , 200

  createProjectManagerView: (state) ->
    unless @projectManagerView?
      ProjectManagerView = require './project-manager-view'
      @projectManagerView = new ProjectManagerView()
    @projectManagerView

  createProjectManagerAddView: (state) ->
    unless @projectManagerAddView?
      ProjectManagerAddView = require './project-manager-add-view'
      @projectManagerAddView = new ProjectManagerAddView()
    @projectManagerAddView
