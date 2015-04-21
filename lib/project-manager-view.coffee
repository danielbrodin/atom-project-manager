{$, $$, SelectListView, View} = require 'atom-space-pen-views'
CSON = require 'season'
_ = require 'underscore-plus'

module.exports =
class ProjectManagerView extends SelectListView
  projectManager: null
  possibleFilterKeys: ['title', 'group', 'template']
  activate: ->
    new ProjectManagerView

  initialize: (serializeState) ->
    super
    @addClass('project-manager')

  serialize: ->

  getFilterKey: ->
    filter = 'title'
    input = @filterEditorView.getText()
    inputArr = input.split(':')

    if inputArr.length > 1 and inputArr[0] in @possibleFilterKeys
      filter = inputArr[0]

    return filter

  getFilterQuery: ->
    input = @filterEditorView.getText()
    inputArr = input.split(':')

    if inputArr.length > 1
      input = inputArr[1]

    return input

  cancelled: ->
    @hide()

  confirmed: (project) ->
    pM = @projectManager
    @projectManager.getCurrentProject (currentProject) ->
      localStorage.setItem('project-manager-last-project', JSON.stringify(project))
      pM.saveWorkspace currentProject, ()->
        atom.project.setPaths project.paths
        pM.closeAllOpenFiles()
        pM.openWorkspace project,()->
          pM.setLastActive project

    @cancel()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No projects saved yet'
    else
      super

  toggle: (projectManager) ->
    @projectManager = projectManager
    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide: ->
    @panel?.hide()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    projects = []
    currentProjects = CSON.readFileSync(@projectManager.file())
    for title, project of currentProjects
      if project.template?
        project = _.deepExtend(project, currentProjects[project.template])
      projects.push(project) if project.paths?

    sortBy = atom.config.get('project-manager.sortBy')
    if sortBy isnt 'default'
      projects = @sortBy(projects, sortBy)
    @setItems(projects)
    @focusFilterEditor()

  viewForItem: ({title, paths, icon, group, devMode}) ->
    icon = icon or 'icon-chevron-right'
    $$ ->
      @li class: 'two-lines', 'data-project-title': title, =>
        @div class: 'primary-line', =>
          @span class: 'project-manager-devmode' if devMode
          @div class: "icon #{icon}", =>
            @span title
            @span class: 'project-manager-list-group', group if group?

        if atom.config.get('project-manager.showPath')
          for path in paths
            @div class: 'secondary-line', =>
              @div class: 'no-icon', path

  sortBy: (arr, key) ->
    arr.sort (a, b) ->
      (a[key] || '\uffff').toUpperCase() > (b[key] || '\uffff').toUpperCase()
