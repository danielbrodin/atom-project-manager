{TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class ProjectManagerAddView extends View
  projectManager: null

  @content: ->
    @div class: 'project-manager', =>
      @label 'Enter the name of the project', class: 'icon icon-plus'
      @subview 'editor', new TextEditorView(mini: true)

  initialize: ->
    atom.commands.add @element,
      'core:confirm': => @confirm(@editor.getText())
      'core:cancel': => @hide()
    @editor.on 'blur', @hide

  cancelled: =>
    @hide()

  confirm: (title) =>
    project =
      title: title
      paths: atom.project.getPaths()

    @projectManager.addProject(project) if project.title
    @hide() if project.title

  hide: =>
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'focus')
    @panel.hide()

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    firstPath = atom.project.getPaths()[0]
    basename = path.basename(firstPath)

    @editor.getModel().setText(basename)
    @editor.focus()
    @editor.select()

  toggle: (projectManager) ->
    @projectManager = projectManager
    if @panel?.isVisible()
      @hide()
    else
      @show()
