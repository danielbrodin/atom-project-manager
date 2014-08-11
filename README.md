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
**Save Project** in the Command Palette and write the title you want to save the project as.

### Edit projects
All projects are saved in a `.cson` file which you can easily reach by searching for **Edit Projects** in the Command Palette.

## Settings
### Editor `settings:`
Atom allows some editor specific settings which can now manually be added to the `projects.cson` file under a `settings` object.
The settings currently available are `setSoftTabs`, `setSoftWrap`and `setTabLength`. After making a change to the settings they can be updated by searching for **Reload Project Settings** under the Command Palette.

### List `icon:`
This changes the icon displayed next to the project title in the list view. The icon is class-based, so you can either use the classes already provided by Atom like `icon-squirrel` or make your own class (target `:before`). The GitHub [octicon](https://github.com/styleguide/css/7.0) font is available to use, and most, if not all classes, just replace `octicon-` with `icon-`.

### Example
```CoffeeScript
'Project Manager':
  'title': 'Project Manager'
  'icon': 'icon-squirrel'
  'paths': [
    '/path/to/project-manager'
  ]
  'settings':
    'setSoftTabs': true  # Enable or disable soft tabs for this editor
    'setSoftWrap': true  # Enable or disable soft wrap for this editor.
    'setTabLength': 2    # Set the on-screen length of tab characters.
```

### Atom Settings
**Show Path:** Shows the path in the list view

**Close Current:** Closes the current window before opening the new project

**Environment Specific Projects:** Use `projects.[hostname].cson` instead of `projects.cson`

**Sort By Title:** Sorts the projects list by title in ascending order

## Todo
- Add multiple directories to a project (Can not currently be done in Atom)