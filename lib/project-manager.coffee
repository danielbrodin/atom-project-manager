ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'
{exec} = require 'child_process'

module.exports =
  projectManagerView: null
  projectManagerAddView: null

  activate: (state) ->
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)
    @projectManagerAddView = new ProjectManagerAddView(state.projectManagerAddViewState)

    atom.workspaceView.command 'project-manager:save-project', => @projectManagerAddView.toggle(@)
    atom.workspaceView.command 'project-manager:toggle', => @projectManagerView.toggle(@)

  createFile: ->
    packagePath = atom.getPackageDirPaths

  addProject: (title) ->
    projectPath = atom.project?.getPath()

    for project, path of @getProjects()
      if path is projectPath
        return # Project is already saved

    atom.config.set("project-manager.#{title}", projectPath) if projectPath?

  getProjects: =>
    atom.config.get("project-manager")

  openProject: (title) ->
    path = @getProjects()[title]
    open = exec "open -a Atom.app #{path}" if path?
