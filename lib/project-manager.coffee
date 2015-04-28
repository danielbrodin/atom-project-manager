###
:Manager:
settings = db.find()...
project = Project(settings)

::Save project::
- Dialog


:DB:
NEDB - https://github.com/louischatriot/nedb


:Project:
::Create::
project.save()

::Update::
project.paths = atom.project.getPaths()
project.save()

::Delete::
project.remove()



::TODO::
- Add notifications
- Edit projects view

###

Manager = require './manager'
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

  manager: null
  projectsListView: null

  activate: (state) ->
    @manager = new Manager()

    # Add commands
    atom.commands.add 'atom-workspace',
      'project-manager:toggle': =>
        @createProjectListView().toggle()

      'project-manager:save-project': ->
        SaveDialog ?= require './save-dialog'
        saveDialog = new SaveDialog()
        saveDialog.attach()

      # 'project-manager:edit-projects': =>
        # atom.workspace.open @file()
        # Edit projects view

      'project-manager:reload-project-settings': =>
        @loadCurrentProject()

  createProjectListView: ->
    unless @projectListView?
      ProjectsListView = require './projects-list-view'
      @projectsListView = new  ProjectsListView()
    @projectsListView