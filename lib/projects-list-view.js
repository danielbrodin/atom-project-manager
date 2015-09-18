'use babel';

import {SelectListView, $$} from 'atom-space-pen-views';
import Projects from './projects';
import Project from './project';

export default class ProjectsListView extends SelectListView {
  initialize() {
    super.initialize();
    this.addClass('project-manager');
    this.projects = new Projects();
  }

  activate() {
    return new ProjectListView;
  }

  get possibleFilterKeys() {
    return ['title', 'group', 'template'];
  }

  get defaultFilterKey() {
    return 'title';
  }

  get sortBy() {
    return atom.config.get('project-manager.sortBy');
  }

  get showPath() {
    return atom.config.get('project-manager.showPath');
  }

  getFilterKey() {
    let filter = this.defaultFilterKey;
    let input = this.filterEditorView.getText();
    let inputArr = input.split(':');

    if (inputArr.length > 1 && this.possibleFilterKeys.includes(inputArr[0])) {
      filter = inputArr[0];
    }

    return filter;
  }

  getFilterQuery() {
    let input = this.filterEditorView.getText();
    let inputArr = input.split(':');

    if (inputArr.length > 1) {
      input = inputArr[1];
    }

    return input;
  }

  getEmptyMessage(itemCount, filteredItemCount) {
    if (itemCount === 0) {
      return 'No projects saved yet';
    } else {
      super.getEmptyMessage(itemCount, filteredItemCount);
    }
  }

  toggle() {
    if (this.panel && this.panel.isVisible()) {
      this.close();
    } else {
      this.projects.getAll((projects) => this.show(projects));
    }
  }

  show(projects) {
    if (this.panel == null) {
      this.panel = atom.workspace.addModalPanel({item: this});
    }

    this.panel.show();

    let items = [];
    for (project of projects) {
      items.push(project.props);
    }

    items = this.sortItems(items);
    this.setItems(items);
    this.focusFilterEditor();
  }

  close() {
    if (this.panel) {
      this.panel.hide();
    }
  }

  cancelled() {
    this.close();
  }

  viewForItem({_id, title, group, icon, devMode, paths}) {
    let showPath = this.showPath;
    return $$(function() {
      this.li({class: 'two-lines'}, {'data-project-id': _id}, () => {
        this.div({class: 'primary-line'}, () => {
          if (devMode) {
            this.span({class: 'project-manager-devmode'});
          }

          this.div({class: `icon ${icon}`}, () => {
            this.span(title);
            if (group != null) {
              this.span({class: 'project-manager-list-group'}, group);
            }
          });
        });
        this.div({class: 'secondary-line'}, () => {
          console.log('Show path', showPath);
          if (showPath) {
            for (path of paths) {
              this.div({class: 'no-icon'}, path);
            }
          }
        });
      });
    });
  }

  sortItems(items) {
    let key = this.sortBy;
    if (key !== 'default') {
      items.sort((a, b) => {
        a = (a[key] || '\uffff').toUpperCase();
        b = (b[key] || '\uffff').toUpperCase();

        return a > b ? 1 : -1;
      });

    }

    return items;
  }
}
