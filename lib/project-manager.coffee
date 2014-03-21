ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'

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

  addProject: (project) ->
    projectPath = project.path
    projectTitle = project.title

    for project, path of @getProjects()
      if path is projectPath
        return # Project is already saved
    atom.config.set("project-manager.#{projectTitle}", projectPath) if projectPath?

  getProjects: =>
    atom.config.get("project-manager")

  openProject: (title) ->
    paths = @getProjects()[title].split(',')
    atom.open options =
      pathsToOpen: paths if paths?
