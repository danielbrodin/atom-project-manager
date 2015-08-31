DB = require '../lib/db'

describe "DB", ->
  db = null

  test1 = off
  test2 = off

  dataLength = 2

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

  beforeEach ->
    db = new DB()

    spyOn(db, 'readFile').andCallFake (callback) ->
      callback(data)
    spyOn(db, 'writeFile').andCallFake (projects, callback) ->
      data = projects
      callback()

  it "finds all projects when given no options", ->
    console.log data
    runs -> db.find (allProjects) ->
      expect(allProjects.length).toBe dataLength
      # test1 = on

  it "can add and delete a project", ->
    # waitsFor -> test1
    project3 =
      title: "Test project 3"
      paths: [
        "/Users/project-3"
      ]
    runs -> db.add project3, (id) ->
      expect(id).toBe 'testproject3'
      db.find (allProjects) ->
        console.log data
        expect(allProjects.length).toBe dataLength+1
        # test2 = on

  it "can delete a project", ->
    # waitsFor -> test2
    runs -> db.delete "testproject3", () ->
      db.find (allProjects) ->
        console.log data
        expect(allProjects.length).toBe dataLength