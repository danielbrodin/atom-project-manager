DB = require '../lib/db'

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
        title: "Test project 2"
        paths: [
          "/Users/project-2"
        ]

    spyOn(db, 'readFile').andCallFake (callback) ->
      callback(data)
    spyOn(db, 'writeFile').andCallFake (projects, callback) ->
      data = projects
      callback()

  it "finds all projects when given no options", ->
    db.find (projects) ->
      expect(projects.length).toBe 2


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