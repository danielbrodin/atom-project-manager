ProjectsListView = require '../lib/projects-list-view'
Project = require '../lib/project'
{$} = require 'atom-space-pen-views'

describe "List View", ->
  [listView, workspaceElement, list, filterEditorView] = []

  data =
    testproject1:
      title: "Test project 1"
      group: "Test"
      paths: ["/Users/project-1"]
    testproject2:
      title: "Test project 2"
      paths: ["/Users/project-2"]
      template: "test-template"
      icon: "icon-bug"

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
    listView.show(projects())

  it "will list all projects", ->
    expect(list.find('li').length).toBe 2

  it "will add the correct icon to each project", ->
    icon1 = list.find('li[data-project-title="Test project 1"]').find('.icon')
    icon2 = list.find('li[data-project-title="Test project 2"]').find('.icon')
    expect(icon1.attr('class')).toContain 'icon-chevron-right'
    expect(icon2.attr('class')).toContain 'icon-bug'

  describe "When the text of the mini editor changes", ->
    beforeEach ->
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