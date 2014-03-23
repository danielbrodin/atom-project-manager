ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'
CSON = require 'season'

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
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)
    @projectManagerAddView = new ProjectManagerAddView(state.projectManagerAddViewState)

    atom.workspaceView.command 'project-manager:save-project', => @projectManagerAddView.toggle(@)
    atom.workspaceView.command 'project-manager:toggle', => @projectManagerView.toggle(@)
    atom.workspaceView.command 'project-manager:edit-projects', => @editProjects()

    if not CSON.resolve(@file)
      projects = {}
      CSON.writeFileSync(@file, projects)

    # Migrate current projects
    if state.projectsMigrated?
      @migrate(state)

  addProject: (project) ->
    projects = CSON.readFileSync(@file)
    projects[project.title] = project
    CSON.writeFileSync(@file, projects)

  openProject: ({title, paths}) ->
    atom.open options =
      pathsToOpen: paths

    if atom.config.get('project-manager.closeCurrent')
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
