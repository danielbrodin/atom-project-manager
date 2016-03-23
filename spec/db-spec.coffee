os = require 'os'
utils = require './utils';
db = require '../lib/db';
db.updateFilepath(utils.dbPath());
projects =
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

db.writeFile projects

describe "DB", ->
  describe "::addUpdater", ->
    it "finds project from path", ->
      query =
        key: 'paths'
        value: projects.testproject2.paths
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
        found = false
        for project in projects
          found = true if project._id = 'newproject'
        expect(found).toBe true


  it "can remove a project", ->
    db.delete "testproject1", () ->
      db.find (projects) ->
        expect(projects.length).toBe 1
