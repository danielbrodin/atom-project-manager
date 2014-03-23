{$, $$, SelectListView, View} = require 'atom'
CSON = require 'season'

module.exports =
class ProjectManagerView extends SelectListView
  projectManager: null
  activate: ->
    new ProjectManagerView

  initialize: (serializeState) ->
    super
    @addClass('project-manager overlay from-top')

  serialize: ->

  getFilterKey: ->
    'title'

  destroy: ->
    @detach()

  toggle: (projectManager) ->
    @projectManager = projectManager
    if @hasParent()
      @detach()
    else
      @attach()

  attach: ->
    projects = []
    currentProjects = CSON.readFileSync(@projectManager.file)
    for project, data of currentProjects
      projects.push(data)
    @setItems(projects)

    atom.workspaceView.append(@)
    @focusFilterEditor()

  viewForItem: ({title, paths}) ->
    $$ ->
      @li class: 'two-lines', 'data-project-title': title, =>
        @div class: 'primary-line icon icon-chevron-right', title
        if atom.config.get('project-manager.showPath')
          @div class: 'secondary-line no-icon', path for path in paths

  confirmed: ({title, paths}) ->
    @cancel()
    @projectManager.openProject({title, paths})
