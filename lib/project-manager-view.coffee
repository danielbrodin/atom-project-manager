{$, $$, SelectListView, View} = require 'atom'

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
    currentPath = atom.project?.getPath()
    for title, path of @projectManager.getProjects()
      if path isnt currentPath
        projects.push({title, path}) if path?
    @setItems(projects)

    atom.workspaceView.append(@)
    @focusFilterEditor()

  viewForItem: ({title, path}) ->
    $$ ->
      @li 'data-project-title': title, =>
        @div class: 'icon icon-chevron-right', title

  confirmed: ({title}) ->
    @cancel()
    @projectManager.openProject(title)