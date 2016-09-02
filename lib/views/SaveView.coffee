{$, TextEditorView, View} = require 'atom-space-pen-views'
manager = require '../Manager'

module.exports =
class SaveView extends View
  @content: ({prompt} = {}) ->
    @div class: 'project-manager-dialog', =>
      @h2 'Save Project', outlet: 'sectionTitle'
      @label 'Title', class: 'label'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error-message text-error', outlet: 'errorMessage'

      @label 'Group', class: 'label'
      @subview 'groupEditor', new TextEditorView(mini: true)

      @label 'Open in developer mode', class: 'input-label', =>
        @input class: 'input-checkbox', type: 'checkbox', outlet: 'devMode'


  initialize: () ->
    prompt = 'Enter name of project'
    select = true
    iconClass = 'icon-arrow-right'
    title = ''
    group = ''
    devMode = false
    firstPath = atom.project.getPaths()[0]

    sectionTitle = 'Save Project'

    activeProject = manager.activeProject;

    if activeProject
      sectionTitle = 'Edit Project'
      title = activeProject.title
      group = activeProject.group
      devMode = activeProject.props.devMode
    else
      title = path.basename(firstPath)

      if atom.config.get('project-manager.prettifyTitle')
        title = changeCase.titleCase(title)


    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()

    # Section title
    @sectionTitle.text(sectionTitle)

    # Title
    # @miniEditor.on 'blur', => @close()
    @miniEditor.getModel().onDidChange => @showError()
    @miniEditor.getModel().setText(title)

    if select
      range = [[0, 0], [0, title.length]]
      @miniEditor.getModel().setSelectedBufferRange(range)

    # Group
    @groupEditor.getModel().setText(group)

    # Devmode
    @devMode.prop('checked', devMode)
    console.log(@)

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'focus')

  showError: (message = '') ->
    @errorMessage.text(message)
    @flashError() if message

  onConfirm: ->
    props =
      title: @miniEditor.getText()
      group: @groupEditor.getText()
      devMode: @devMode[0].checked
      paths: atom.project.getPaths()

    console.log props
