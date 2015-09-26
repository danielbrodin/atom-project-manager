Project = require '../lib/project'

describe "Project", ->
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
      _id: 'test'
      title: "Test"
      paths: ["/Users/test"]
    project = new Project(props)

    spyOn(project, 'updateProps').andCallThrough()
    spyOn(project.db, 'readFile').andCallFake (callback) ->
      props =
        test:
          _id: 'test'
          title: "Test"
          paths: ["/Users/test"]
          icon: 'icon-test'
      callback(props)

    project.db.emitter.emit 'db-updated'

    expect(project.updateProps).toHaveBeenCalled()
    expect(project.props.icon).toBe 'icon-test'

  it "automatically updates it's properties even though key have changed", ->
    props =
      _id: 'test'
      title: "Test"
      paths: ["/Users/test"]
    project = new Project(props)

    spyOn(project, 'updateProps').andCallThrough()
    spyOn(project.db, 'readFile').andCallFake (callback) ->
      props =
        testtest:
          _id: 'testtest'
          title: "Test"
          paths: ["/Users/test"]
          icon: 'icon-test'
      callback(props)

    expect(project.db.searchKey).toBe '_id'
    expect(project.db.searchValue).toBe 'test'
    project.db.emitter.emit 'db-updated'

    expect(project.updateProps).toHaveBeenCalled()
    expect(project.props._id).toBe 'testtest'
    expect(project.props.icon).toBe 'icon-test'
    expect(project.db.searchKey).toBe '_id'
    expect(project.db.searchValue).toBe 'testtest'


  describe "::set/::unset", ->
    project = null

    beforeEach ->
      project = new Project()
      spyOn(project.db, 'add').andCallFake (props, callback) ->
        id = props.title.replace(/\s+/g, '').toLowerCase()
        callback?(id)
      spyOn(project.db, 'update').andCallFake (props, callback) ->
        callback?()

    it "sets and unsets the value", ->
      expect(project.props.title).toBe ''
      project.set('title', 'test')
      expect(project.props.title).toBe 'test'

      project.unset('title')
      expect(project.props.title).toBe ''


  describe "::save", ->
    project = null

    beforeEach ->
      project = new Project()
      spyOn(project.db, 'add').andCallFake (props, callback) ->
        id = props.title.replace(/\s+/g, '').toLowerCase()
        callback?(id)
      spyOn(project.db, 'update').andCallFake (props, callback) ->
        callback?()

    it "does not save if not valid", ->
      expect(project.save()).toBe false

    it "only saves settings that isn't default", ->
      props = {
        title: 'Test'
        paths: ['/Users/test']
      }
      project = new Project(props)
      expect(project.getPropsToSave()).toEqual props

    it "saves project if _id isn't set", ->
      project.set('title', 'Test')
      project.set('paths', ["/Users/"])

      expect(project.save()).toBe true
      expect(project.db.add).toHaveBeenCalled()
      expect(project.props._id).toBe 'test'

    it "updates project if _id is set", ->
      project.set('title', 'Test')
      project.set('paths', ["/Users/"])
      project.props._id = 'test'

      expect(project.save()).toBe true
      expect(project.db.update).toHaveBeenCalled()