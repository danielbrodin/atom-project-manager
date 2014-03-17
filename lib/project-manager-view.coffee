{View} = require 'atom'

module.exports =
class ProjectManagerView extends View
  @content: ->
    @div class: 'project-manager overlay from-top', =>
      @div "The ProjectManager package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "project-manager:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "ProjectManagerView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
