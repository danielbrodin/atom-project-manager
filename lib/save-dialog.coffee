Dialog = require './dialog'
manager = require './Manager';
path = require 'path'
changeCase = require 'change-case'

module.exports =
class SaveDialog extends Dialog
  filePath: null

  constructor: () ->
    activeProject = manager.activeProject;

    firstPath = atom.project.getPaths()[0]

    if activeProject
      title = activeProject.title
    else
      title = path.basename(firstPath)

      if atom.config.get('project-manager.prettifyTitle')
        title = changeCase.titleCase(title)


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
        source: 'file'

      manager.saveProject(properties)

      @close()
    else
      @showError('You need to specify a name for the project')
