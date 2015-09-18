ProjectsListView = require '../lib/projects-list-view'
Project = require '../lib/project'
{$} = require 'atom-space-pen-views'

describe "List View", ->
  [listView, workspaceElement, list, filterEditorView] = []

  data =
    testproject1:
      _id: 'testproject1'
      title: "Test project 1"
      paths: ["/Users/project-1"]
    testproject2:
      _id: 'testproject2'
      title: "Test project 2"
      paths: ["/Users/project-2"]
      template: "test-template"
      icon: "icon-bug"
      group: "Test"

  projects = ->
    array = []
    for key, setting of data
      project = new Project(setting)
      array.push(project)
    return array

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    listView = new ProjectsListView
    {list, filterEditorView} = listView

  it "will list all projects", ->
    listView.show(projects())
    expect(list.find('li').length).toBe 2

  it "will add the correct icon to each project", ->
    listView.show(projects())
    icon1 = list.find('li[data-project-id="testproject1"]').find('.icon')
    icon2 = list.find('li[data-project-id="testproject2"]').find('.icon')
    expect(icon1.attr('class')).toContain 'icon-chevron-right'
    expect(icon2.attr('class')).toContain 'icon-bug'

  describe "When the text of the mini editor changes", ->
    beforeEach ->
      listView.show(projects())
      listView.isOnDom = -> true # Fix this somehow

    it "will only list projects with the correct title", ->
      filterEditorView.getModel().setText('title:1')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe 'title'
      expect(listView.getFilterQuery()).toBe '1'
      expect(list.find('li').length).toBe 1

    it "will only list projects with the correct group", ->
      filterEditorView.getModel().setText('group:test')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe 'group'
      expect(listView.getFilterQuery()).toBe 'test'
      expect(list.find('li').length).toBe 1
      expect(list.find('li:eq(0)')
        .find('.project-manager-list-group')).toHaveText 'Test'

    it "will only list projects with the correct template", ->
      filterEditorView.getModel().setText('template:test')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe 'template'
      expect(listView.getFilterQuery()).toBe 'test'
      expect(list.find('li').length).toBe 1

    it "will fall back to default filter key if it's not valid", ->
      filterEditorView.getModel().setText('test:1')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe listView.defaultFilterKey
      expect(listView.getFilterQuery()).toBe '1'
      expect(list.find('li').length).toBe 1

  describe "It sorts the projects in correct order", ->
    it "sorts after title", ->
      atom.config.set('project-manager.sortBy', 'title')
      listView.show(projects())
      expect(list.find('li:eq(0)').data('projectId')).toBe "testproject1"

    it "sort after group", ->
      atom.config.set('project-manager.sortBy', 'group')
      listView.show(projects())
      expect(list.find('li:eq(0)').data('projectId')).toBe "testproject2"