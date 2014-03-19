{View, EditorView} = require 'atom'

module.exports =
class ProjectManagerAddView extends View
  projectManager: null

  @content: ->
    @div class: 'project-manager overlay from-top', =>
      @div class: 'editor-container', outlet: 'editorContainer', =>
        @span 'Project title:'
        @subview 'editor', new EditorView(mini: true)

  initialize: ->

  handleEvents: ->
    @editor.on 'core:confirm', @confirm
    @editor.on 'core:cancel', @remove
    @editor.find('input').on 'blur', @remove

  focus: =>
    @removeClass('hidden')
    @editorContainer.find('.editor').focus()

  confirm: =>
    @value = @editor.getText()
    @projectManager.addProject(@value)
    @remove()

  remove: =>
    atom.workspaceView.focus() if atom.workspaceView?
    @addClass('hidden')

  toggle: (projectManager) ->
    @projectManager = projectManager # Better fix for this
    atom.workspaceView.append(@)
    @focus()
    @handleEvents()