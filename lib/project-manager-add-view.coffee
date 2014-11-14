{View, EditorView} = require 'atom'
path = require 'path'

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
    basename = path.basename(atom.project.getPath())
    @editor.setText(basename)
    range = [[0], [basename.length]]
    @editor.getEditor().setSelectedBufferRange(range)

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
    atom.workspaceView.focus() if atom.workspaceView?
    @addClass('hidden')

  toggle: (projectManager) ->
    @projectManager = projectManager
    atom.workspaceView.append(@)
    @focus()
    @handleEvents()
