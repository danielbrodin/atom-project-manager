Helper = require './spec-helper'
Projects = require '../lib/projects'

describe "Projects", ->
  projects = null

  beforeEach ->
    projects = new Projects()
    spyOn(projects.db, 'readFile').andCallFake(Helper.readFile)
    spyOn(projects.db, 'writeFile').andCallFake(Helper.writeFile)

  it "returns all projects", ->
    projects.getAll (projects) ->
      expect(projects.length).toBe Helper.savedProjects