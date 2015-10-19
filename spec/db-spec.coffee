DB = require '../lib/db'
os = require 'os'

describe "DB", ->
  db = null
  data = null

  beforeEach ->
    db = new DB()

    data =
      testproject1:
        title: "Test project 1"
        group: "Test"
        paths: [
          "/Users/project-1"
        ]
      testproject2:
        _id: 'testproject2'
        title: "Test project 2"
        paths: [
          "/Users/project-2"
        ]

    spyOn(db, 'readFile').andCallFake (callback) ->
      callback(data)
    spyOn(db, 'writeFile').andCallFake (projects, callback) ->
      data = projects
      callback()

  describe "::Find", ->
    it "finds all projects when given no query", ->
      db.find (projects) ->
        expect(projects.length).toBe 2

    it "finds project from path", ->
      db.setSearchQuery 'paths', ['/Users/project-2']
      expect(db.searchKey).toBe 'paths'
      expect(db.searchValue).toEqual ['/Users/project-2']
      db.find (project) ->
        expect(project.title).toBe 'Test project 2'

    it "finds project from title", ->
      db.setSearchQuery 'title', 'Test project 1'
      db.find (project) ->
        expect(project.title).toBe 'Test project 1'

    it "finds project from id", ->
      db.setSearchQuery '_id', 'testproject2'
      db.find (project) ->
        expect(project.title).toBe 'Test project 2'

    it "finds nothing if query is wrong", ->
      db.setSearchQuery '_id', 'noproject'
      db.find (project) ->
        expect(project).toBe false

  it "can add a project", ->
    newProject =
      title: "New Project"
      paths: [
        "/Users/new-project"
      ]
    db.add newProject, (id) ->
      expect(id).toBe 'newproject'
      db.find (projects) ->
        expect(projects.length).toBe 3


  it "can remove a project", ->
    db.delete "testproject1", () ->
      db.find (projects) ->
        expect(projects.length).toBe 1

  describe "Environment specific settings", ->
    it "loads a generic file if not set", ->
      atom.config.set('project-manager.environmentSpecificProjects', false);
      filedir = atom.getConfigDirPath();
      expect(db.file()).toBe "#{filedir}/projects.cson"

    it "loads a environment specific file is set to true", ->
      atom.config.set('project-manager.environmentSpecificProjects', true);
      hostname = os.hostname().split('.').shift().toLowerCase();
      filedir = atom.getConfigDirPath();

      expect(db.file()).toBe "#{filedir}/projects.#{hostname}.cson"
