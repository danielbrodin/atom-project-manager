Projects = require '../lib/projects'

describe "Projects", ->
  projects = null

  data =
    testproject1:
      title: "Test project 1"
      paths: [
        "/Users/project-1"
      ]
    testproject2:
      title: "Test project 2"
      paths: [
        "/Users/project-2"
      ]

  beforeEach ->
    projects = new Projects()
    spyOn(projects.db, 'readFile').andCallFake (callback) ->
      callback(data)
    spyOn(projects.db, 'writeFile').andCallFake (projects, callback) ->
      data = projects
      callback()

  it "returns all projects", ->
    projects.getAll (projects) ->
      expect(projects.length).toBe 2