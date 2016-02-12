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
    it "finds all projects", ->
      db.find (projects) ->
        expect(projects.length).toBe 2

  describe "::addUpdater", ->
    it "finds project from path", ->
      query =
        key: 'paths'
        value: data.testproject2.paths
      db.addUpdater 'noIdMatchButPathMatch', query, (props) =>
        expect(props._id).toBe 'testproject2'

      db.emitter.emit 'db-updated'

    it "finds project from title", ->
      query =
        key: 'title'
        value: 'Test project 1'
      db.addUpdater 'noIdMatchButTitleMatch', query, (props) =>
        expect(props.title).toBe query.value

      db.emitter.emit 'db-updated'

    it "finds project from id", ->
      query =
        key: '_id'
        value: 'testproject1'
      db.addUpdater 'shouldIdMatchButNotOnThis', query, (props) =>
        expect(props._id).toBe query.value

      db.emitter.emit 'db-updated'

    it "finds nothing if query is wrong", ->
      query =
        key: '_id'
        value: 'IHaveNoID'
      haveBeenChanged = false
      db.addUpdater 'noIdMatch', query, (props) =>
        haveBeenChanged = true

      db.emitter.emit 'db-updated'
      expect(haveBeenChanged).toBe false

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
