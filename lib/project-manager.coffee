ProjectManagerView = require './project-manager-view'
{exec} = require 'child_process'

module.exports =
  projectManagerView: null

  activate: (state) ->
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)

    atom.workspaceView.command 'project-manager:add', => @addProject('Test')
    atom.workspaceView.command 'project-manager:list', => @listProjects()
    atom.workspaceView.command 'project-manager:open', => @openProject('Test')

  deactivate: ->
    @projectManagerView.destroy()

  serialize: ->
    projectManagerViewState: @projectManagerView.serialize()

  addProject: (title) ->
    projectPath = atom.project?.getPath()
    atom.config.set("project-manager.#{title}", projectPath) if projectPath?
    # atom.config.set("project-manager.#{title}.title", "#{title}") if projectPath?
    # atom.config.set("project-manager.#{title}.path", projectPath) if projectPath?

  getProjects: =>
    atom.config.get("project-manager")

  listProjects: ->
    for project, path of @getProjects()
      console.log "#{projecte} - #{path}"

  openProject: (title) ->
    projects = @getProjects

    for project, path of @getProjects()
      if project is title
        open = exec "open -a Atom.app #{path}"
