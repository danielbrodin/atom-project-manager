# Project Manager
[![Build status](https://travis-ci.org/danielbrodin/atom-project-manager.svg?branch=master)](https://travis-ci.org/danielbrodin/atom-project-manager/)
[![apm](https://img.shields.io/apm/dm/project-manager.svg)](https://atom.io/packages/project-manager)
[![apm](https://img.shields.io/apm/v/project-manager.svg)]()

![Project Manager](https://raw.github.com/danielbrodin/atom-project-manager/master/project-manager.gif)


Get easy access to all your projects and manage them with project specific settings and options.


## Install
```
$ apm install project-manager
```
or open Atom and go to Preferences > Install and search for `project-manager`


## Use
### List Projects
`ctrl-cmd-p` (mac) / `alt-shift-P` (win & linux) or `Project Manager: List Projects` in the Command Palette.

You can filter projects by `title`, `group` and `template`.
`group: atom` would list all projects with the group `atom`. Default is `title`

### Save Project
`Project Manager: Save Project` in the Command Palette and write the title you want to save the project as.

### Edit Projects
All projects are saved in a `.cson` file which you can easily reach by searching for `Project Manager: Edit Projects` in the Command Palette.

## Project Settings

setting    | Type      | Description                                                                                                                                           | Default               
-----------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------
`title`    | `string`  | Projects title. Used in the projects list                                                                                                | `''`                  
`paths`    | `array`   | The folders that will open in the tree view. First path is the main one that counts as the project.                                                   | `[]`                  
`settings` | `Object`  | Enables you to set project specific settings. Everything that goes in the `config.cson` file can go here. It also supports scoped settings.           | `{}`                  
`icon`     | `string`  | Icon that shows in the projects list. It's class-based so can either be a class already provided by Atom like `icon-squirell` or a class of your own. | `'icon-chevron-right'`
`devMode`  | `boolean` | `true` if project should open in dev mode                                                                                                             | `false`               
`group`    | `string`  | Adds a group to the projects list that can be used to group and filter projects                                                                       | `null`                
`template` | `string`  | If you add a project in the `projects.cson` file without `paths` it will count as a template. This way you can easily share settings between projects | `null`                


### Example
```
projectmanager:
  title: 'Project Manager'
  devMode: true
  group: 'Atom'
  template: 'coffeescript-template'
  paths: [
    '/path/to/project-manager'
  ]
  settings:
    '*':
      'editor.tabLength': 4

'coffeescript-template':
  icon: 'icon-coffeescript'
  settings:
    '.source.coffee':
      'editor.tabLength': 2
      'editor.preferredLineLength': 80
```

## Package Settings
Name                          | Setting                                       | Default     | Description                                                                                                                                      
------------------------------|-----------------------------------------------|-------------|------------
Show Path                     | `project-manager.showPath`                    | `true`      | Shows each projects paths in the projects list                                                                                                   
Environment Specific Projects | `project-manager.environmentSpecificProjects` | `false`     | If you share your `.atom` folder between computers but don't use the same projects. Will create a `projects.[hostname].cson` for each environment
Sort By                       | `project-manager.sortBy`                      | `'default'` | Will sort the projects list by selected option. Default sorting is the order in which the are                                                    
Close Current                 | `project-manager.closeCurrent`                | `false`     | Closes the current window before opening a new project.


## API
The project manager provides a service that you can use in your own Atom packages. To use it, include `project-manager` in the `consumedServices` section of your package.json.

```
"consumedServices": {
    "project-manager": {
      "versions": {
        "^2.2.1": "consumeProjectManager"
      }
    }
  }
```
Then in your package's main module, call methods on the service
```
module.exports =
  doSomethingWithTheCurrentProject: (project) ->

  consumeProjectManager: (PM) ->
    PM.projects.getCurrent (project) =>
      if project
        @doSomethingWithTheCurrentProject(project)
```

### Methods
#### `{Projects}`
- `::getAll`
  - `{Function} callback` - Callback that receives an `Array` of `{Project}`'s
- `::getCurrent`
  - `{Function} callback` - Callback that receives the current `{Project}` or `false` if there is none active
- `::onUpdate`
  - `{Function} callback` - Will be called each time a project have been updated

#### `{Project}`
- `{props}` - Contains all properties of the project like `title`, `paths` and `settings`
- `::open` - Will open the project
- `::isCurrent` - Returns `true` if it's the current project
- `::onUpdate`
  - `{Function} callback` - Will be called when the project have been updated
- `::set` - Will set the property on the project
  - `{String} key`
  - `{Mixed} value`
- `::unset` - Will remove the property from the project
  - `{String} key`


Please let me know if you make something out of it :)

## Contribute
If you would like to contribute to the project manager, be it new features or bugs,
please do the following:

1. Fork the repository
2. Create a new topic branch off the master branch that describe what it does
3. Commit and push the branch
4. Make a pull request describing what you have done
5. Now it will hopefully get merged :)

All PR's should:
- Pass the [jscs](https://atom.io/packages/linter-jscs) linter
- Pass the [jshint](https://atom.io/packages/linter-jshint) linter
- Add a test when it makes sense, which should be most of the time

--------

[![Paypal Donations](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DR4XQWAZV6M2A&lc=SE&item_name=Project%20Manager&item_number=atom%2dproject%2dmanager&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted) a :beer: if you enjoy using the [project manager](https://github.com/danielbrodin/atom-project-manager) :)
