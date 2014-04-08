AtomProjectManager = require '../lib/project-manager'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ProjectManager", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('projectManager')

  describe "when the project-manager:toggle event is triggered", ->
    it "attaches the view", ->
      expect(atom.workspaceView.find('.project-manager')).toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'project-manager:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.project-manager')).not.toExist()
        atom.workspaceView.trigger 'project-manager:toggle'
        expect(atom.workspaceView.find('.project-manager')).toExist()
