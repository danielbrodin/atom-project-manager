{$} = require 'atom-space-pen-views'
ProjectManager = require '../lib/project-manager'
workspaceElement = null
fs = require 'fs'

describe "ProjectManager", ->
  activationPromise: null

  describe "Toggle Project Manager", ->

    beforeEach ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)
      ProjectManager.projectManagerView = null
      @settingsFile = "#{__dirname}/projects.test.cson"
      spyOn(ProjectManager, 'file').andCallFake => @settingsFile
      waitsForPromise -> atom.packages.activatePackage('project-manager')

    it "Shows the Project Viewer", ->
      atom.commands.dispatch workspaceElement, 'project-manager:toggle'
      list = $(workspaceElement).find('.project-manager .list-group li')
      expect(list.length).toBe 1
      expect(list.first().find('.primary-line').text()).toBe 'Test01'

  describe "Initiating Project Manager", ->

    beforeEach ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)
      @settingsFile = "#{__dirname}/projects.test.cson"
      spyOn(ProjectManager, 'file').andCallFake => @settingsFile
      waitsForPromise -> atom.packages.activatePackage('project-manager')

    it "Makes sure projects.cson exists", ->
      options =
        encoding: 'utf-8'
      fs.readFile ProjectManager.file(), options, (err, data) ->
        expect(err).toBe null

    it "getCurrentPath existential operator issue is fixed", ->
      projects = test: paths: atom.project.getPaths()
      result = ProjectManager.getCurrentProject projects
      expect(result).not.toBe false
      projects = test: {}
      result = ProjectManager.getCurrentProject projects
      expect(result).toBe false

  describe "Loading Settings", ->

    beforeEach ->
      @settingsFile = "#{__dirname}/projects.test.cson"
      CSON = require 'season'
      CSON.readFile @settingsFile, (error, data) =>
        @projects = data
        @projects.Test01.paths = [__dirname]
      ProjectManager.projectManagerView = null
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)
      spyOn(ProjectManager, 'file').andCallFake => @settingsFile
      waitsForPromise -> atom.packages.activatePackage('project-manager')

    describe "without scopes", ->
      beforeEach ->
        spyOn(ProjectManager, 'getCurrentProject').andCallFake => @projects.Test01

      it "Overwrites existing settings", ->
        atom.config.setRawValue 'tree-view.showOnRightSide', off
        expect(atom.config.get('tree-view.showOnRightSide')).toBe off
        done = off
        runs -> ProjectManager.loadCurrentProject -> done = on
        waitsFor -> done
        runs -> expect(atom.config.get('tree-view.showOnRightSide')).toBe on

      it "Extends existing array settings", ->
        atom.config.setRawValue 'fuzzy-finder.ignoredNames', ['a', 'b', 'c']
        expect(atom.config.get('fuzzy-finder.ignoredNames').length).toBe 3
        done = off
        runs -> ProjectManager.loadCurrentProject -> done = on
        waitsFor -> done
        runs -> expect(atom.config.get('fuzzy-finder.ignoredNames').length).toBe 6

      it "Doesn't overwrite the user's config file after loading settings", ->
        done = off
        runs -> ProjectManager.loadCurrentProject -> done = on
        waitsFor -> done
        runs -> expect(atom.config.save).not.toHaveBeenCalled()

    describe 'with scopes', ->
      beforeEach ->
        spyOn(ProjectManager, 'getCurrentProject').andCallFake => @projects.Test02

      it "Updates global scope", ->
        done = off
        runs -> ProjectManager.loadCurrentProject -> done = on
        waitsFor -> done
        runs -> expect(atom.config.get 'editor.tabLength').toBe 2

      it "Updates a specific scope", ->
        done = off
        runs -> ProjectManager.loadCurrentProject -> done = on
        waitsFor -> done
        runs -> expect(atom.config.get 'editor.tabLength', scope: [".source.coffee"]).toBe 4
