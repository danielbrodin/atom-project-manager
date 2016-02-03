# Changelog

## 2.7.6
Fix [#195](https://github.com/danielbrodin/atom-project-manager/issues/195)

## 2.7.5
Bugfix

## 2.7.4
Now adds back focus to editor when closing the project list view.

## 2.7.3
Fixes [#143](https://github.com/danielbrodin/atom-project-manager/issues/143)

## 2.7.2
Fixes [#185](https://github.com/danielbrodin/atom-project-manager/issues/185) and [#182](https://github.com/danielbrodin/atom-project-manager/issues/182)

## 2.7.1
Fixes [#180](https://github.com/danielbrodin/atom-project-manager/issues/180)

## 2.7.0
- The option to close the current window when opening a new project is now back. Still not a great implementation but the old one seems to work again.
- The project listing will now warn you if a projects path is not available.

## 2.6.5
Fixes [#163](https://github.com/danielbrodin/atom-project-manager/issues/163)

## 2.6.4
[#161](https://github.com/danielbrodin/atom-project-manager/issues/161) should now be fixed for real thanks to [@douggr](https://github.com/douggr) :)

## 2.6.3
Should fix [#161](https://github.com/danielbrodin/atom-project-manager/issues/161)

## 2.6.2
Fixed [#160](https://github.com/danielbrodin/atom-project-manager/issues/160)

## 2.6.1
Fixed bug that happened when there where no settings on a project

## 2.6.0
Package now use ES6 mostly. Still some views done in CoffeeScript.
A restart of Atom could be needed for it to work after the update.

## 2.5.2
Now shows a notification if the `projects.cson` file isn't correctly formatted.

## 2.5.1
- Fixes a bug that would not update a project if the key had changed manually in the `projects.cson`. Not a 100% fix, but will hopefully work for now until a prettier one is around :)
- Added a notification with a link to a fix for when the `projects.cson` file can't be watched.

## 2.5.0
- Updated READ ME to be a bit more clear
- Added cleaning of package commands on deactivation.

## 2.4.0
Now automatically updates a project and its settings if it's the active project when it has been updated in the `projects.cson` file

## 2.3.0
Added services to let other packages get access to the saved projects. Look through the API section of the read me and let me know if you have any questions or you find any bugs with it.

And also fixed some bugs :)

## 2.2.1
Fixed bug where the list view would sort projects wrong if there were to many

## 2.2.0
Added back the menu under Packages

## 2.1.0
Renamed `Project Manager: Toggle` to `Project Manager: List Projects` to make it clearer what it does.

## 2.0.1
Fixed an issue where the projects file would be added to late.

## 2.0.0
No noticeable changes, just a rewrite of the package to make it easier to add new features and take in pull requests. Please let me know if you find any bugs :)

## 1.16.0
Added support for scoped settings. Thanks to [@benjic](https://github.com/benjic)

## 1.15.11
Fixes issue where projects couldn't be listed because template didn't exist. Thanks to  [@coopermaruyama](https://github.com/coopermaruyama)

## 1.15.10
A issue with enabling project settings turned up with an updated to Atom.
Did a fix that got rid of the error, but might need an improved fix.

## 1.15.9
- Fixes sorting when more than 10 projects are saved
- Updated dependencies
- Now shows an error notification if the projects file isn't valid

## 1.15.8
Updated the save project dialog

## 1.15.7
Here just because apm got messed up and thought it published 1.15.6
but it did not and now I have to publish 1.15.7 instead. Weird and annoying.
Anyone know how to fix this?

## 1.15.6
Bugfix

## 1.15.5
Performance fix

## 1.15.4
Update deprecated calls

## 1.15.3
Updated readme with new keybinding

## 1.15.2
Windows seems to be case sensitive so now using `alt-shift-P`

## 1.15.1
Changed keybindings on windows and linux to `alt-shift-p`.

## 1.15.0
Fixed deprecated calls. Thanks to [@tswaters](https://github.com/tswaters)

## 1.14.1
Added notifications

## 1.14.0
Added filters for project listing, ex: `group: atom`

## 1.13.0
- Improved loading of settings
- Fixed deprecated warnings
- Added tests for most things

Big thanks to [@alvaromartin](https://github.com/alvaromartin)

## 1.12.0
Now using the new commands API

## 1.11.1
Fixed link to octicons in readme

## 1.11.0
`Project Manager: Save Project` now automatically fills in the title field with the current directory name

## 1.10.2
Disabled **Close Current** since it currently breaks in Atom. Will enable it again as soon as there is a good solution to fix it.

## 1.10.1
Bugfix

## 1.10.0
- You can now add a `group:` setting on a project and sort the projects list by group.
- Added a marker for projects with `devMode: true` to the projects list to make it more clear that it will open in developer mode

## 1.9.3
Did a fix that might fix an error that sometimes came up when updating to latest version.
If an error still comes up, try updating to latest version of Atom, currently 0.135

## 1.9.2
Bug fix

## 1.9.1
Now using the updated config system. If you were using "sort by title" you will have to set it again with the new sort by option.

## 1.9.0
- You can now add templates in the projects file.

## 1.8.2
Now using FS instead of pathwatcher for monitoring changes in the projects file.

## 1.8.1
- **Project Manager: Edit Projects** will now open file in the current window instead of a new one
- Added possibility to open project in dev mode with `devMode: true`

## 1.8.0
Changed the way settings work which mean that if you have used any of the old settings, you have to redo them. This way all settings that can be set from the settings view/config.cson can be project specific.

```CoffeeScript
# Old way
'settings':
  'setTabLength': 2

# New way
'settings':
  'editor.tabLength': 2
  'editor.showIndentGuide': true
  'project-manager.showPath': true
```

## 1.7.6
Miss read the updated Atom::open() API so going back to the old way of closing
the current window, but with a fix to it.

## 1.7.5
Now use the updated Atom::open() API

## 1.7.4
- Removed Project Manager from the context menu since it has nothing todo with the interface.
- Some code cleanup and fix

## 1.7.3
- Fixed inconsistency in filename in README and CHANGELOG.
- Added brackets around hostname in `projects.[hostname].cson` to make it clearer that that part will change to use the hostname of the environment.

## 1.7.2
- Updated changelog

## 1.7.1
- Updated readme

## 1.7
*Something seems to have happend during publish so 1.6 was skipped*
- Project path now shows when saving a project

## 1.5
This update adds an option for **environment specific project** files which are based on your hostname to be able to sync the atom folder between environments without ignoring `projects.cson`.
Enabling this option will create a `projects.[hostname].cson` file.

After enabling this option you will have to manually move the contents of `projects.cson` to the new `projects.[hostname].cson` file. After this `projects.cson`can be delete or left alone.

## 1.4
- Added option to sort by title.
- Added changelog
