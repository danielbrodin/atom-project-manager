ProjectManagerView = require './project-manager-view'
ProjectManagerAddView = require './project-manager-add-view'
CSON = require 'season'

module.exports =
  projectManagerView: null
  projectManagerAddView: null
  projectFilename: 'projects.cson'
  projectFileDir: atom.getConfigDirPath()

  activate: (state) ->
    @projectManagerView = new ProjectManagerView(state.projectManagerViewState)
    @projectManagerAddView = new ProjectManagerAddView(state.projectManagerAddViewState)

    atom.workspaceView.command 'project-manager:save-project', => @projectManagerAddView.toggle(@)
    atom.workspaceView.command 'project-manager:toggle', => @projectManagerView.toggle(@)

  addProject: (project) ->
    if not CSON.resolve("#{@projectFileDir}/#{@projectFilename}")
      projects = {}
    else
      projects = CSON.readFileSync("#{@projectFileDir}/#{@projectFilename}") ? {}

    projects[project.title] = project
    console.log projects
    CSON.writeFileSync("#{@projectFileDir}/#{@projectFilename}", projects)

  getProjects: =>
    CSON.readFileSync("#{@projectFileDir}/#{@projectFilename}")

  openProject: (title) ->
    project = CSON.readFileSync("#{@projectFileDir}/#{@projectFilename}")
    paths = project[title].path

    atom.open options =
      pathsToOpen: paths