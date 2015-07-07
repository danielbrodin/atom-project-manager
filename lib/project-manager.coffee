{CompositeDisposable} = require 'atom'
fs = require 'fs'
Settings = null
ProjectsListView = null
ProjectsAddView = null

module.exports =
  config:
    showPath:
      type: 'boolean'
      default: true

    closeCurrent:
      type: 'boolean'
      default: false
      description:
        "Currently disabled since it's broken.
        Waiting for a better way to implement it."

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

  projectManagerAddView: null
  filepath: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @handleEvents()

    fs.exists @file(), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create #{@file()}"
      else
        @subscribeToProjectsFile()
        @loadCurrentProject()

    atom.config.observe 'project-manager.environmentSpecificProjects',
      (newValue, obj = {}) =>
        previous = if obj.previous? then obj.previous else newValue
        unless newValue is previous
          @updateFile()
          @subscribeToProjectsFile()

  handleEvents: (state) ->
    @subscriptions.add atom.commands.add 'atom-workspace',
      'project-manager:toggle': =>
        ProjectsListView ?= require './project-manager-view'
        projectsListView = new ProjectsListView()
        projectsListView.toggle(@)

      'project-manager:save-project': =>
        ProjectsAddView ?= require './project-manager-add-view'
        projectsAddView = new ProjectsAddView()
        projectsAddView.toggle(@)

      'project-manager:edit-projects': =>
        atom.workspace.open @file()

      'project-manager:reload-project-settings': =>
        @loadCurrentProject()

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
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create #{@file()}"

  subscribeToProjectsFile: ->
    @fileWatcher.close() if @fileWatcher?
    @fileWatcher = fs.watch @file(), (event, filename) =>
      @loadCurrentProject()

  loadCurrentProject: (done) ->
    CSON = require 'season'
    _ = require 'underscore-plus'
    CSON.readFile @file(), (error, data) =>
      unless error
        project = @getCurrentProject(data)
        if project
          if project.template? and data[project.template]?
            project = _.deepExtend(project, data[project.template])
          Settings ?= require './settings'
          Settings.enable(project.settings) if project.settings?
      done?()

  getCurrentProject: (projects) ->
    for title, project of projects
      continue if not project.paths?
      for path in project.paths
        if path in atom.project.getPaths()
          return project
    return false

  addProject: (project) ->
    CSON = require 'season'
    projects = CSON.readFileSync(@file()) || {}
    projects[project.title] = project
    successMessage = "#{project.title} has been added"
    errorMessage = "#{project.title} could not be saved to #{@file()}"

    CSON.writeFile @file(), projects, (err) ->
      unless err
        atom.notifications?.addSuccess successMessage
      else
        atom.notifications?.addError errorMessage

  openProject: (project) ->
    atom.open options =
      pathsToOpen: project.paths
      devMode: project.devMode

  deactivate: ->
    @subscriptions.dispose()
