# Changelog

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