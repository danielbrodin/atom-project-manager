helper =
  settingsPath: "#{__dirname}/projects.test.cson"
  savedProjects: null


  readFile: (callback) ->
    callback(helper.projects)

  writeFile: (projects, callback) ->
    helper.projects = projects
    callback?()

  projects:
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

helper.savedProjects = Object.keys(helper.projects).length

module.exports = helper