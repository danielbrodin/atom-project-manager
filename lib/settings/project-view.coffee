{$, $$, View, EditorView} = require 'atom'

PathView = require './project-path-view'
SettingView = require './project-setting-view'

module.exports =
class View extends View
  @content: ({settings}) ->
    @section class: 'project-manager-settings-project-view inset-panel', =>
      @div class: 'panel-heading', =>
        @subview 'projectTitle', new EditorView({mini: true})
      @div class: 'panel-body', =>
        @div outlet: 'pathsList'
        @div class: 'project-settings-panel inset-panel padded', =>
          @div class: 'panel-heading icon icon-gear', =>
            @span 'Settings'
          @div class: 'panel-body', =>
            @div outlet: 'projectSettingsList'
            @button 'Add Setting', class: 'icon icon-plus btn btn-default add-project-setting', outlet: 'addSettingButton'

  initialize: ({@project}) ->
    {title, paths, settings} = @project
    settings ||= {}
    @projectTitle.setText(title)
    @pathViews = []
    @settingViews = []
    for path in paths
      @appendPath(path)
    @addSettingButton.on 'click', => @appendSetting()
    for settingName, settingValue of @project.settings
      @appendSetting(settingName, settingValue)
    @appendSetting()

  removeSetting: (view) ->
    index = @settingViews.indexOf(view)
    @settingViews.splice(index, 1)
    view.remove()
    @parent().view().saveProjects()

  appendPath: (path) ->
    pathView = new PathView(path)
    @pathViews.push(pathView)
    @pathsList.append(pathView)
    PathView

  appendSetting: (name, value) ->
    settingView = new SettingView(settingName: name, settingValue: value)
    @settingViews.push(settingView)
    @projectSettingsList.append(settingView)
    SettingView

  serializeSettings: ->
    title: @projectTitle.getText()
    paths: @getPathsFromSubviews()
    settings: @getSettingsFromSubviews()

  getPathsFromSubviews: ->
    view.pathField.getText() for view in @pathViews

  getSettingsFromSubviews: ->
    settings = {}
    for view in @settingViews
      settingName = view.settingNameEditor.getText()
      settingValue = view.settingValueEditor.getText()
      settings[settingName] = settingValue if settingName? && settingValue?
    settings
