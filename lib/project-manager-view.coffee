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
      @cancel()
    else
      @attach()

  attach: ->
    projects = []
    currentProjects = CSON.readFileSync(@projectManager.file)
    for title, project of currentProjects
      projects.push(project)
    @setItems(projects)

    atom.workspaceView.append(@)
    @focusFilterEditor()

  viewForItem: ({title, paths, icon}) ->
    icon = icon or 'icon-chevron-right'
    $$ ->
      @li class: 'two-lines', 'data-project-title': title, =>
        @div class: "primary-line icon #{icon}", title
        if atom.config.get('project-manager.showPath')
          @div class: 'secondary-line no-icon', path for path in paths

  confirmed: ({title, paths}) ->
    @cancel()
    @projectManager.openProject({title, paths})
