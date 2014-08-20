{$, ScrollView} = require 'atom'
ProjectView = require './project-view'
CSON = null

module.exports =
class SettingsView extends ScrollView
  @projectManager: null

  @content: ->
    @div class: 'project-manager-settings-view  pane-item', =>
      @div class: 'panel', =>
        @div class: 'panel-heading', =>
          @h1 'Edit Projects'
        @div class: 'panel-body', outlet: 'projectsList'

  getTitle: -> 'Project Manager Settings'

  initialize: ({@projectManager})->
    super
    @projectViews = []
    @loadProjects()
    @on 'keyup', =>
      @saveProjects()
      true

  loadProjects: () ->
    CSON = require 'season'
    CSON.readFile @projectManager.file(), (error, data) =>
      for title, project of data
        @appendProject(title: title, project: project)

  appendProject: (options) ->
    projectView = new ProjectView(options)
    @projectViews.push(projectView)
    @projectsList.append(projectView)

  saveProjects: () ->
    projectData = {}
    for projectView in @projectViews
      data = projectView.serializeSettings()
      projectData[data.title] = data

    CSON.writeFile @projectManager.file(), projectData, (error, data) =>
      @projectManager.loadSettings()
