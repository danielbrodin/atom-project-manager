# Project Manager

![Project Manager](https://raw.github.com/danielbrodin/atom-project-manager/master/project-manager.gif)

A package for saving your projects for fast and easy access.

## Installation
```sh
apm install project-manager
```
or find it in the Packages tab under settings

## Usage
All commands can also be found in the Packages menu
### List projects
`ctrl-cmd-p` (mac) / `ctrl-shift-alt-p` (win & linux) or **Project Manager** in the Command Palette.

### Save project
**Project Manager: Save Project** in the Command Palette and write the title you want to save the project as.

### Edit projects
All projects are saved in a `.cson` file which you can easily reach by searching for **Project Manager: Edit Projects** in the Command Palette.

## Project Settings
### `settings:`
Under settings you can set everything that you can have in the `config.cson` file which is what you see under the settings view.
The formatting should be as follows:
```
'settings':
  'editor.tabLength': 2
  'project-manager.showPath': true
```
The settings will be updated on change, but can also manually be done from the command palette with **Project Manager: Reload Project Settings**

### `devMode:`
Will open the project in dev mode. The API for this doesn't work perfectly though so if you try to switch to a project that is already open in dev mode, a new window will open.

### `icon:`
This changes the icon displayed next to the project title in the list view. The icon is class-based, so you can either use the classes already provided by Atom like `icon-squirrel` or make your own class (target `:before`). The GitHub [octicon](https://github.com/styleguide/css/7.0) font is available to use, and most, if not all classes, just replace `octicon-` with `icon-`.

### Example
```CoffeeScript
'Project Manager':
  'title': 'Project Manager'
  'icon': 'icon-squirrel'
  'devMode': true
  'paths': [
    '/path/to/project-manager'
  ]
  'settings':
    'editor.tabLength': 2
    'editor.showIndentGuide': false
    'project-manager:showPath': true
```

## Package Settings
**Show Path:** Shows the path in the list view

**Close Current:** Closes the current window before opening the new project

**Environment Specific Projects:** Use `projects.[hostname].cson` instead of `projects.cson`

**Sort By Title:** Sorts the projects list by title in ascending order