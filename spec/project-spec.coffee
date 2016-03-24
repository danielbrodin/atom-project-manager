Project = require '../lib/project'
utils = require './utils';
db = require '../lib/db';
db.updateFilepath(utils.dbPath());

describe "Project", ->

  beforeEach ->

  it "recieves default properties", ->
    properties =
      title: "Test"
      paths: ["/Users/"]
    project = new Project(properties)

    expect(project.props.icon).toBe 'icon-chevron-right'

  it "does not validate without proper properties", ->
    properties =
      title: "Test"
    project = new Project(properties)
    expect(project.isValid()).toBe false

  it "automatically updates it's properties", ->
    props =
      title: "testAutomaticUpdates"
      paths: ["/Users/test-automatic-updates"]
    project = new Project(props)
    project.save()

    spyOn(project, 'updateProps').andCallThrough()
    expect(project.props.icon).toBe 'icon-chevron-right'

    # Overwrite the settings in db
    props.icon = 'icon-test'
    db.add(props)

    project.onUpdate () ->
      expect(project.updateProps).toHaveBeenCalled()
      expect(project.props.icon).toBe 'icon-test'

  describe "::save", ->
    it "does not save if not valid", ->
      project = new Project()
      expect(project.save()).toBe false

    it "only saves settings that isn't default", ->
      props = {
        title: 'Test'
        paths: ['/Users/test']
      }
      project = new Project(props)
      expect(project.getPropsToSave()).toEqual props

    it "saves project if _id isn't set", ->
      project = new Project({title: 'saveProjectIfIDIsntSet', paths: ['/Test/']})
      spyOn(db, 'add').andCallThrough()
      spyOn(db, 'update').andCallThrough()

      project.save()

      expect(db.add).toHaveBeenCalled()
      expect(db.update).not.toHaveBeenCalled()

    it "updates project if _id is set", ->
      props =
        title: 'updateProjectIfIDIsSet',
        paths: ['/Test/']

      spyOn(db, 'update').andCallThrough()

      db.add props, (id) ->
        props._id = id
        project = new Project(props)

        project.save()

        expect(db.update).toHaveBeenCalled()
