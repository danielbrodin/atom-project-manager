ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'
CSON = require 'season'

module.exports =
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

    if not CSON.resolve(@file)
      projects = {}
      CSON.writeFileSync(@file, projects)

    # Move saved projects to the new file
    if atom.config.get('project-manager')
      for title, path of atom.config.get('project-manager')
        if typeof path is 'string'
          atom.config.set("project-manager.#{title}", null)
          moveProject =
            title: title
            path: [path]
          @addProject(moveProject)

  addProject: (project) ->
    projects = CSON.readFileSync(@file)
    projects[project.title] = project
    CSON.writeFileSync(@file, projects)

  openProject: (title) ->
    project = CSON.readFileSync(@file)
    paths = project[title].path

    atom.open options =
      pathsToOpen: paths
