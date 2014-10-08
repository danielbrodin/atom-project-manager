fs = require 'fs'

module.exports =
  config:
    showPath:
      type: 'boolean'
      default: true

    closeCurrent:
      type: 'boolean'
      default: false

    environmentSpecificProjects:
      type: 'boolean'
      default: false

    sortBy:
      type: 'string'
      description: 'Default sorting is the order in which the projects are'
      default: 'default'
      enum: [
        'default'
        'title'
        'group'
      ]

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
        @loadCurrentProject()

    atom.workspaceView.command 'project-manager:save-project', =>
      @createProjectManagerAddView(state).toggle(@)
    atom.workspaceView.command 'project-manager:toggle', =>
      @createProjectManagerView(state).toggle(@)
    atom.workspaceView.command 'project-manager:edit-projects', =>
      atom.workspaceView.open @file()
    atom.workspaceView.command 'project-manager:reload-project-settings', =>
      @loadCurrentProject()

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
    @fileWatcher.close() if @fileWatcher?
    @fileWatcher = fs.watch @file(), (event, filename) =>
      @loadCurrentProject()

  loadCurrentProject: ->
    CSON = require 'season'
    _ = require 'underscore-plus'
    CSON.readFile @file(), (error, data) =>
      unless error
        project = @getCurrentProject(data)
        if project
          if project.template? and data[project.template]?
            project = _.deepExtend(project, data[project.template])
          @enableSettings(project.settings) if project.settings?

  getCurrentProject: (projects) ->
    for title, project of projects
      for path in project.paths
        if path is atom.project.getPath()
          return project
    return false

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
