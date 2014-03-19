# Project Manager

![Open In](http://github.com/danielbrodin/atom-project-manager/blob/master/project-manager.gif)

I really needed a project manager for Atom, so since there wasn't one available I started making my own. Currently it's in a very basic form, i.e. you can save a project and browse through your saved projects, but I plan on making it as good as I can.

All projects are currently saved in the settings file so that you can easily change the path of a project or remove it (empty the path field). My intention was to also add the projects title as a field to the settings for the possibility to easily change it, but with the current implementation of the settings view I found it to confusing, so will wait with this.

Please let me know if you find a bug or have any idea for improvements.

## Installation
`apm install project-manager` or find it in Settings (`cmd-,`) / Packages

## Usage
`ctrl-cmd-p` or search for *"project manager"* in the Command Palette (`cmd-shift-p`) to list all projects.

Search for *"save project"* in the Command Palette (`cmd-shift-p`) and write the title of the project to save it.

To change the path of a project, go to the settings view / Project Manager and change the path in the field.


## Todo
- Change name of a project
- Add multiple directories to a project