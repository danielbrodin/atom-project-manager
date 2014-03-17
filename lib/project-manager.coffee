ProjectManagerView = require './project-manager-view'
{exec} = require 'child_process'

module.exports =
  projectManagerView: null

  activate: (state) ->
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)

    atom.workspaceView.command 'project-manager:add', => @addProject('Test')
    atom.workspaceView.command 'project-manager:get', => @getProjects()
    atom.workspaceView.command 'project-manager:open', => @openProject('Test')

  deactivate: ->
    @projectManagerView.destroy()

  serialize: ->
    projectManagerViewState: @projectManagerView.serialize()

  addProject: (title) ->
    projectPath = atom.project?.getPath()
    atom.config.set("project-manager.#{title}", projectPath) if projectPath?

  getProjects: ->
    projects = atom.config.get("project-manager")

    for project, path of projects
      console.log "#{project} - #{path}"

  openProject: (title) ->
    projects = atom.config.get("project-manager")

    for project, path of projects
      if project is title
        open = exec "open -a Atom.app #{path}"