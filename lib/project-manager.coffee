Projects = require './projects'
SaveDialog = null

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
  db: null

  activate: (state) ->
    @loadProject()

    # Add commands
    atom.commands.add 'atom-workspace',
      'project-manager:toggle': =>
        @createProjectListView().toggle()

      'project-manager:save-project': ->
        SaveDialog ?= require './save-dialog'
        saveDialog = new SaveDialog()
        saveDialog.attach()

      'project-manager:edit-projects': =>
        unless @db
          DB = require './db'
          @db = new DB()

        atom.workspace.open @db.file()

      'project-manager:reload-project-settings': =>
        @loadProject()

  loadProject: ->
    @projects = new Projects events =
      update: () =>
        @loadProject()
    @project = @projects.getCurrent()
    if @project
      @project.load()

  createProjectListView: ->
    unless @projectListView?
      ProjectsListView = require './projects-list-view'
      @projectsListView = new  ProjectsListView()
    @projectsListView