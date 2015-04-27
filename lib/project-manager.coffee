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

###

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

  activate: (state) ->
    filename = @file()
    db = new Datastore({filename: filename})
    db.loadDatabase (err) ->
      # project =
      #   title: 'Project Manager'
      #   paths: atom.project.getPaths()
      #
      # db.insert(project)

      project = db.findOne {paths: atom.project.getPaths()[0]}, (err, docs) ->
        console.log docs

