{$, $$, SelectListView, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
Projects = require './projects'

module.exports =
class ProjectsListView extends SelectListView
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
    project.open()
    @cancel()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No projects saved yet'
    else
      super

  toggle: () ->
    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide: ->
    @panel?.hide()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    projects = Projects.getAll()

    sortBy = atom.config.get('project-manager.sortBy')
    if sortBy isnt 'default'
      projects = @sortBy(projects, sortBy)
    @setItems(projects)
    @focusFilterEditor()

  viewForItem: (project) ->
    data = project.properties
    icon = icon or 'icon-chevron-right'
    $$ ->
      @li class: 'two-lines', 'data-project-title': data.title, =>
        @div class: 'primary-line', =>
          @span class: 'project-manager-devmode' if data.devMode
          @div class: "icon #{icon}", =>
            @span data.title
            @span class: 'project-manager-list-group', data.group if data.group?

        if atom.config.get('project-manager.showPath')
          for path in data.paths
            @div class: 'secondary-line', =>
              @div class: 'no-icon', path

  sortBy: (arr, key) ->
    arr.sort (a, b) ->
      (a[key] || '\uffff').toUpperCase() > (b[key] || '\uffff').toUpperCase()