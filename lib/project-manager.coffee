fs = require 'fs'

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

  projectManagerView: null
  projectManagerAddView: null

  filepath: null

  activate: (state) ->
    fs.exists @file(), (exists) =>
      unless exists
        fs.writeFile @file(), '{}', (error) ->
          if error
            atom.notifications?.addError "Project Manager", options =
              details: "Could not create #{@file()}"
      else
        @subscribeToProjectsFile()
        @loadCurrentProject()

    atom.commands.add 'atom-workspace',
      'project-manager:toggle': =>
        @createProjectManagerView(state).toggle(@)

      'project-manager:save-project': =>
        @createProjectManagerAddView(state).toggle(@)

      'project-manager:edit-projects': =>
        atom.workspace.open @file()

      'project-manager:reload-project-settings': =>
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
          @enableSettings(project.settings) if project.settings?
      done?()

  getCurrentProject: (projects) ->
    for title, project of projects
      continue if not project.paths?
      for path in project.paths
        if path in atom.project.getPaths()
          return project
    return false

  flattenSettings: (root, dict, path) ->
    _ = require 'underscore-plus'
    for key, value of dict
      dotPath = key
      dotPath = "#{path}.#{key}" if path?
      isObject = not _.isArray(value) and _.isObject(value)
      if not isObject
        root[dotPath] = value
      else
        @flattenSettings root, dict[key], dotPath

  enableSettings: (settings) ->
    _ = require 'underscore-plus'
    flatSettings = {}
    @flattenSettings flatSettings, settings
    for setting, value of flatSettings
      if _.isArray value
        currentValue = atom.config.get setting
        value = _.union currentValue, value
      atom.config.setRawValue setting, value
    atom.config.emit 'updated'

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
