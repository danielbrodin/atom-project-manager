Helper = require './spec-helper'
ProjectsListView = require '../lib/projects-list-view'
Project = require '../lib/project'
{$} = require 'atom-space-pen-views'

describe "List View", ->
  [listView, workspaceElement, list, filterEditorView] = []

  projects = ->
    array = []
    for key, setting of Helper.projects
      if setting.paths?
        project = new Project(setting)
        array.push(project)
    return array

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    listView = new ProjectsListView
    {list, filterEditorView} = listView

  it "will list all projects", ->
    listView.show(projects())
    expect(list.find('li').length).toBe Helper.savedProjects

  # describe "When the text of the mini editor changes", ->
  #   it "will only list projects with the correct group", ->
  #     listView.show(projects())
  #     filterEditorView.getModel().setText('group:test')
  #     window.advanceClock(listView.inputThrottle)
  #
  #     expect(listView.getFilterKey()).toBe 'group'
  #     expect(listView.getFilterQuery()).toBe 'test'
  #
  #     {list} = listView
  #
  #     expect(list.find('li').length).toBe 1
  #
  #     expect(list.find('li:eq(0)')
  #       .find('.project-manager-list-group')).toHaveText 'Test'