Dialog = require './dialog'
Project = require './project'
projects = require './projects'
path = require 'path'
changeCase = require 'change-case'

module.exports =
class SaveDialog extends Dialog
  filePath: null

  constructor: () ->
    firstPath = atom.project.getPaths()[0]
    title = path.basename(firstPath)

    if atom.config.get('project-manager.prettifyTitle')
      title = changeCase.titleCase(title)

    super
      prompt: 'Enter name of project'
      input: title
      select: true
      iconClass: 'icon-arrow-right'

    projects.getCurrent (project) =>
      if project.props.paths[0] is firstPath
        @showError "This project is already saved as #{project.props.title}"


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
