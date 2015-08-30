Helper = require './spec-helper'
DB = require '../lib/db'

describe "DB", ->
  db = null

  test1 = off
  test2 = off

  beforeEach ->
    db = new DB()
    spyOn(db, 'file').andCallFake -> Helper.settingsPath

  it "finds all projects when given no options", ->
    runs -> db.find (projects) ->
      expect(projects.length).toBe Helper.savedProjects
      test1 = on

  it "can add a new project", ->
    waitsFor -> test1
    project3 =
      title: "Test project 3"
      paths: [
        "/Users/project-3"
      ]
    runs -> db.add project3, (id) ->
      expect(id).toBe 'testproject3'
      db.find (projects) ->
        expect(projects.length).toBe Helper.savedProjects+1
        test2 = on

  it "can delete a project", ->
    waitsFor -> test2
    runs -> db.delete "testproject3", () ->
      db.find (projects) ->
        expect(projects.length).toBe Helper.savedProjects