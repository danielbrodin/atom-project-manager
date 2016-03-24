utils = require './utils';
db = require '../lib/db';
db.updateFilepath(utils.dbPath());
ProjectsListView = require '../lib/projects-list-view'
{$} = require 'atom-space-pen-views'
path = require 'path'

describe "List View", ->
  [listView, workspaceElement, list, filterEditorView] = []

  beforeEach ->
    spyOn(db, 'readFile').andCallFake (callback) ->
      existingPath = path.join(__dirname)
      data =
        one:
          title: 'project one'
          group: 'Test'
          paths: ['/Does/not/exist']
        two:
          title: 'project two'
          icon: 'icon-bug'
          paths: [existingPath]
          template: 'two'
        three:
          title: 'a first'
          group: 'a group'
          paths: ['/Does/not/exist/again']

      callback(data)

    workspaceElement = atom.views.getView(atom.workspace)
    listView = new ProjectsListView()
    {list, filterEditorView} = listView

  it "will list all projects", ->
    listView.toggle()
    expect(list.find('li').length).toBe 3

  it "will let you know if a path is not available", ->
    listView.toggle()
    expect(list.find('li').eq(0).data('pathMissing')).toBe true
    expect(list.find('li').eq(1).data('pathMissing')).toBe false

  it "will add the correct icon to each project", ->
    listView.toggle()
    icon1 = list.find('li[data-project-id="one"]').find('.icon')
    icon2 = list.find('li[data-project-id="two"]').find('.icon')
    expect(icon1.attr('class')).toContain 'icon-chevron-right'
    expect(icon2.attr('class')).toContain 'icon-bug'

  describe "When the text of the mini editor changes", ->
    beforeEach ->
      listView.toggle()
      listView.isOnDom = -> true # Fix this somehow

    it "will only list projects with the correct title", ->
      filterEditorView.getModel().setText('title:one')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe 'title'
      expect(listView.getFilterQuery()).toBe 'one'
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
      filterEditorView.getModel().setText('template:two')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe 'template'
      expect(listView.getFilterQuery()).toBe 'two'
      expect(list.find('li').length).toBe 1

    it "will fall back to default filter key if it's not valid", ->
      filterEditorView.getModel().setText('test:one')
      window.advanceClock(listView.inputThrottle)

      expect(listView.getFilterKey()).toBe listView.defaultFilterKey
      expect(listView.getFilterQuery()).toBe 'one'
      expect(list.find('li').length).toBe 1

  describe "It sorts the projects in correct order", ->
    it "sorts after title", ->
      atom.config.set('project-manager.sortBy', 'title')
      listView.toggle()
      expect(list.find('li:eq(0)').data('projectId')).toBe "three"

    it "sort after group", ->
      atom.config.set('project-manager.sortBy', 'group')
      listView.toggle()
      expect(list.find('li:eq(0)').data('projectId')).toBe "three"
