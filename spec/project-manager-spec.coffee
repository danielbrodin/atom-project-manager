ProjectManager = require '../lib/project-manager'
{WorkspaceView} = require 'atom'
fs = require 'fs'

describe "ProjectManager", ->
  activationPromise: null

  describe "Toggle Project Manager", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      activationPromise = atom.packages.activatePackage('project-manager')

    it "Shows the Project Viewer", ->
      expect(atom.workspaceView.find('.project-manager')).not.toExist()
      atom.workspaceView.trigger 'project-manager:toggle'
      expect(atom.workspaceView.find('.project-manager')).toExist()

  describe "Initiating Project Manager", ->
    beforeEach ->
      activationPromise = atom.packages.activatePackage('project-manager')

    it "Makes sure projects.cson exists", ->
      options =
        encoding: 'utf-8'
      fs.readFile ProjectManager.file, options, (err, data) ->
        expect(err).toBe null