Dialog = require './dialog'
Project = require './project'
path = require 'path'

module.exports =
class SaveDialog extends Dialog
  filePath: null

  constructor: () ->
    firstPath = atom.project.getPaths()[0]
    title = path.basename(firstPath)

    super
      prompt: 'Enter name of project'
      input: title
      select: true
      iconClass: 'icon-arrow-right'

  onConfirm: (title) ->
    if title
      properties =
        title: title
        paths: atom.project.getPaths()

      project = new Project(properties)
      project.save()

      @close()
    else
      @showError('You need to specify a name for the project')