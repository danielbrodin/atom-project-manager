{View, EditorView} = require 'atom'

module.exports =
class ProjectManagerAddView extends View
  projectManager: null

  @content: ->
    @div class: 'project-manager overlay from-top', =>
      @div class: 'editor-container', outlet: 'editorContainer', =>
        @subview 'editor',
          new EditorView(mini: true, placeholderText: 'Project title')
        @div =>
          @span 'Path: '
          @span class: 'text-highlight', atom.project?.getPath()

  initialize: ->

  handleEvents: ->
    @editor.on 'core:confirm', @confirm
    @editor.on 'core:cancel', @remove
    @editor.find('input').on 'blur', @remove

  focus: =>
    @removeClass('hidden')
    @editorContainer.find('.editor').focus()

  confirm: =>
    project =
      title: @editor.getText()
      paths: [atom.project?.getPath()]

    @projectManager.addProject(project) if project.title
    @remove() if project.title

  remove: =>
    @editor.setText('')
    atom.workspaceView.focus() if atom.workspaceView?
    @addClass('hidden')

  toggle: (projectManager) ->
    @projectManager = projectManager
    atom.workspaceView.append(@)
    @focus()
    @handleEvents()
