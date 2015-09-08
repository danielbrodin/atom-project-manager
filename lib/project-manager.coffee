{CompositeDisposable} = require 'atom'

Projects = null
Project = null
SaveDialog = null
DB = null
ProjectsListView = null

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

  projects: null
  project: null
  projectsListView: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'project-manager:list-projects': ->
        ProjectsListView ?= require './projects-list-view'
        projectsListView = new ProjectsListView()
        projectsListView.toggle()

      'project-manager:save-project': ->
        SaveDialog ?= require './save-dialog'
        saveDialog = new SaveDialog()
        saveDialog.attach()

      'project-manager:edit-projects': ->
        DB ?= require './db'
        db = new DB()
        atom.workspace.open db.file()

      'project-manager:reload-project-settings': =>
        @loadProject()

    atom.project.onDidChangePaths @updatePaths

    @loadProject()

  loadProject: =>
    Projects ?= require './projects'
    @projects = new Projects()
    @projects.getCurrent (project) =>
      if project
        @project = project
        @project.load()

  updatePaths: =>
    paths = atom.project.getPaths()
    if @project and paths.length
      @project.set('paths', paths)

  provideProjects: ->
    projects: new Projects()

  deactivate: ->
    @subscriptions.dispose()