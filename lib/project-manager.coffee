fs = require 'fs'

module.exports =
  configDefaults:
    showPath: false
    closeCurrent: false

  projectManagerView: null
  projectManagerAddView: null
  filename: 'projects.cson'
  fileDir: atom.getConfigDirPath()
  file: null

  activate: (state) ->
    @file = "#{@fileDir}/#{@filename}"

    atom.workspaceView.command 'project-manager:save-project', =>
      @createProjectManagerAddView(state).toggle(@)
    atom.workspaceView.command 'project-manager:toggle', =>
      @createProjectManagerView(state).toggle(@)
    atom.workspaceView.command 'project-manager:edit-projects', =>
      @editProjects()

    fs.exists @file, (exists) =>
      unless exists
        fs.writeFile @file, '{}', (err) ->
          # Migrate current project
          if not err and state.projectsMigrated?
            @migrate(state)

  addProject: (project) ->
    CSON = require 'season'
    projects = CSON.readFileSync(@file) || {}
    projects[project.title] = project
    CSON.writeFileSync(@file, projects)

  openProject: ({title, paths}) ->
    atom.open options =
      pathsToOpen: paths

    if atom.config.get('project-manager.closeCurrent') or not atom.project.getPath()
      atom.close()

  editProjects: ->
    config =
      title: 'Config'
      paths: [@file]
    @openProject(config)

  migrate: (state) ->
    state.projectsMigrated = true
    for title, path of atom.config.get('project-manager')
      if typeof path is 'string'
        atom.config.set("project-manager.#{title}", null)
        moveProject =
          title: title
          paths: [path]
        @addProject(moveProject)

  createProjectManagerView: (state) ->
    unless @projectManagerView?
      ProjectManagerView = require './project-manager-view'
      @projectManagerView = new ProjectManagerView(state.projectManagerViewState)
    @projectManagerView

  createProjectManagerAddView: (state) ->
    unless @projectManagerAddView?
      ProjectManagerAddView = require './project-manager-add-view'
      @projectManagerAddView = new ProjectManagerAddView(state.projectManagerAddViewState)
    @projectManagerAddView
