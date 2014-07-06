fs = require 'fs'

module.exports =
  configDefaults:
    showPath: false
    closeCurrent: false
    sortByTitle: false

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
    atom.workspaceView.command 'project-manager:reload-project-settings', =>
      @loadSettings()

    fs.exists @file, (exists) =>
      unless exists
        fs.writeFile @file, '{}', (error) ->
          if error
            console.log "Error: Could not create the file projects.cson - #{error}"
      else
        @loadSettings()

  loadSettings: ->
    CSON = require 'season'
    CSON.readFile @file, (error, data) =>
      unless error
        for title, project of data
          for path in project.paths
            if path is atom.project.getPath()
              if project.settings?
                @enableSettings(project.settings)
              break

  enableSettings: (settings) ->
    for setting, value of settings
      atom.workspace.eachEditor (editor) ->
        editor[setting](value)

  addProject: (project) ->
    CSON = require 'season'
    projects = CSON.readFileSync(@file) || {}
    projects[project.title] = project
    CSON.writeFileSync(@file, projects)

  openProject: ({title, paths}) ->
    unless atom.config.get('project-manager.closeCurrent')
      # Short-circuit and just open another project.
      atom.open options =
        pathsToOpen: paths

      if not atom.project.getPath()
        atom.close()

      return

    # Serialize and set the state of each component
    atom.state.syntax = atom.syntax.serialize()
    atom.state.project = atom.project.serialize()
    atom.state.workspace = atom.workspace.serialize()
    atom.packages.deactivatePackage "tree-view"
    atom.state.packageStates = atom.packages.packageStates

    # Save our state.
    atom.saveSync()

    # Decode the load settings
    settings = JSON.parse(decodeURIComponent(location.search.substr(14)))

    # Change the initial path
    settings.initialPath = paths[0]

    # Encode and set the "load" settings
    search = "?loadSettings=" + encodeURIComponent(JSON.stringify(settings))
    uri = window.location.origin + window.location.pathname + search
    window.history.replaceState({}, "", uri)
    delete atom.constructor.loadSettings
    atom.state = atom.constructor.loadState "editor"

    # "Switch" to the new project.
    atom.project.destroy()
    delete atom.project
    atom.deserializeProject()
    atom.deserializePackageStates()

    # Load the new project in the tree view
    atom.packages.activatePackage "tree-view"

    # Load all stored buffers of the new project
    pane = atom.workspace.paneContainer.root
    for buffer in atom.project.buffers
      editor = atom.project.buildEditorForBuffer buffer
      pane.addItem editor

    # Activate the last-active buffer
    pane.activateItemForUri atom.state.workspace.paneContainer.root.activeItemUri

  editProjects: ->
    config =
      title: 'Config'
      paths: [@file]
    @openProject(config)

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
