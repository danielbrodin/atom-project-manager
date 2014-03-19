ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'
{exec} = require 'child_process'

module.exports =
  projectManagerView: null
  projectManagerAddView: null

  activate: (state) ->
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)
    @projectManagerAddView = new ProjectManagerAddView(state.projectManagerAddViewState)

    atom.workspaceView.command 'project-manager:save-project', => @projectManagerAddView.toggle(this)
    atom.workspaceView.command 'project-manager:toggle', => @projectManagerView.toggle(this)

  deactivate: ->
    @projectManagerView.destroy()

  serialize: ->
    projectManagerViewState: @projectManagerView.serialize()

  createFile: ->
    packagePath = atom.getPackageDirPaths

  addProject: (title) ->
    projects = @getProjects()
    projectPath = atom.project?.getPath()

    for project, path of projects
      if path is projectPath
        console.log 'Project already saved'
        return

    console.log 'Add project #{title} - #{projectPath}'
    atom.config.set("project-manager.#{title}", projectPath) if projectPath?

  getProjects: =>
    atom.config.get("project-manager")

  openProject: (title) ->
    console.log "open #{title}"

    for project, path of @getProjects()
      if project is title
        open = exec "open -a Atom.app #{path}"
