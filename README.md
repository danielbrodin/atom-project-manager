# Project Manager

![Project Manager](https://raw.github.com/danielbrodin/atom-project-manager/master/project-manager.gif)

A package for saving your projects for fast and easy access, similiar to the one in Sublime Text.

## Installation
```sh
apm install project-manager
```
or find it in the Packages tab under settings

## Usage
All commands can also be found in the Packages menu
### List projects
`ctrl-cmd-p` or search for **project manager** in the Command Palette `cmd-shift-p`

### Save project
Search for **save project** in the Command Palette `cmd-shift-p` and write the title of the project to save it.

### Edit projects
All projects are saved in a `.cson` file which you can easily reach by searching for **edit projects** in the Command Palette `cmd-shift-p`

### Project Specific Settings
Atom allows some editor specific settings which can now manually be added to the `projects.cson` file.
The settings currently available are `setSoftTabs`, `setSoftWrap`and `setTabLength`. After making a change to the settings they can be updated by searching for **Reload Project Settings** under the Command Palette `cmd-shift-p`

```CoffeeScript
'Project Manager':
  'title': 'Project Manager'
  'paths': [
    '/path/to/project-manager'
  ]
  'settings':
    'setSoftTabs': true  # Enable or disable soft tabs for this editor
    'setSoftWrap': true  # Enable or disable soft wrap for this editor.
    'setTabLength': 2    # Set the on-screen length of tab characters.
```

## Settings
**Show Path:** Shows the path in the list view

**Close Current:** Closes the current window before opening the new project

## Todo
- Add multiple directories to a project (Can not currently be done in Atom)
