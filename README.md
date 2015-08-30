# Project Manager

Get easy access to all your projects and manage them with project specific settings and options.

![Project Manager](https://raw.github.com/danielbrodin/atom-project-manager/master/project-manager.gif)

Boost my creativity, [![Paypal Donations](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DR4XQWAZV6M2A&lc=SE&item_name=Project%20Manager&item_number=atom%2dproject%2dmanager&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted) a :beer:


## Installation
```
apm install project-manager
```

## Usage
### List projects
`ctrl-cmd-p` (mac) / `alt-shift-P` (win & linux) or `Project Manager: Toggle` in the Command Palette.

You can filter result by `title`, `group` and `template`.
`group: atom` would list all projects with the group `atom`. Default is `title`

### Save project
`Project Manager: Save Project` in the Command Palette and write the title you want to save the project as.

### Edit projects
All projects are saved in a `.cson` file which you can easily reach by searching for `Project Manager: Edit Projects` in the Command Palette.

## Project Settings
### `settings:`
Under settings you can set everything that you can have in the `config.cson` file which is what you see under the settings view.
The formatting should be as follows:
```
'settings':
  '*':
    'editor.tabLength': 4
  '.source.coffee':
    'editor.tabLength': 2
```
The settings will be updated on change, but can also manually be done from the command palette with `Project Manager: Reload Project Settings`

### `devMode:`
Will open the project in dev mode. The API for this doesn't work perfectly though so if you try to switch to a project that is already open in dev mode, a new window will open.

### `icon:`
This changes the icon displayed next to the project title in the list view. The icon is class-based, so you can either use the classes already provided by Atom like `icon-squirrel` or make your own class (target `:before`). The GitHub [octicons](https://octicons.github.com/) font is available to use, and most, if not all classes, just replace `octicon-` with `icon-`.

### `template:`
You can specify a template in the `projects.cson` file to share settings between projects. The settings will merge so you can still specify project specific settings.

### `group:`
You can specify a group that the project belongs to and then sort the projects list after group.

### Example
```
'projectmanager':
  'title': 'Project Manager'
  'devMode': true
  'group': 'Atom'
  'template': 'coffeescript-template'
  'paths': [
    '/path/to/project-manager'
  ]
  'settings':
    '*':
      'editor.tabLength': 2

'coffeescript-template':
  'icon': 'icon-coffeescript'
  'settings':
    '.source.coffee':
      'editor.tabLength': 2
      'editor.preferredLineLength': 80
```

## Package Settings
**Show Path:** Shows the path in the list view

~~**Close Current:** Closes the current window before opening the new project~~ *(Currently disabled)*

**Environment Specific Projects:** Uses `projects.[hostname].cson` instead of `projects.cson`

**Sort By:** Sorts the projects list by selected option
