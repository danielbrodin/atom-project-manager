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
project.delete()



::TODO::
- Add notifications
- Edit projects view

###

Manager = require './manager'

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

  activate: (state) ->
    @manager = new Manager()

    # Add commands
    atom.commands.add 'atom-workspace',
      'project-manager:toggle': =>
        # @createProjectManagerView(state).toggle(@)

      'project-manager:save-project': =>
        # @createProjectManagerAddView(state).toggle(@)

      'project-manager:edit-projects': =>
        atom.workspace.open @file()

      'project-manager:reload-project-settings': =>
        @loadCurrentProject()

