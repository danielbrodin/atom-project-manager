DB = require '../lib/db'

describe "DB", ->
  db = null
  settingsFile = "#{__dirname}/projects.test.cson"

  test1 = off
  test2 = off

  beforeEach ->
    db = new DB()
    spyOn(db, 'file').andCallFake -> settingsFile

  it "finds all projects when given no options", ->
    runs -> db.find (projects) ->
      expect(projects.length).toBe 2
      test1 = on

  it "can add a new project", ->
    waitsFor -> test1
    test3 =
      title: "Test project 3"
      paths: [
        "/Users/project-3"
      ]
    runs -> db.add test3, (props) ->
      db.find (projects) ->
        expect(projects.length).toBe 3
        test2 = on

  it "can delete a project", ->
    waitsFor -> test2
    runs -> db.delete "testproject3", () ->
      db.find (projects) ->
        expect(projects.length).toBe 2