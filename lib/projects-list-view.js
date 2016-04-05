'use babel';

import {SelectListView, $$} from 'atom-space-pen-views';
import _ from 'underscore-plus';
import projects from './projects';

export default class ProjectsListView extends SelectListView {
  initialize() {
    super.initialize();
    this.addClass('project-manager');
  }

  activate() {
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
    const input = this.filterEditorView.getText();
    const inputArr = input.split(':');
    const isFilterKey = _.contains(this.possibleFilterKeys, inputArr[0]);
    let filter = this.defaultFilterKey;

    if (inputArr.length > 1 && isFilterKey) {
      filter = inputArr[0];
    }

    return filter;
  }

  getFilterQuery() {
    const input = this.filterEditorView.getText();
    const inputArr = input.split(':');
    let filter = input;

    if (inputArr.length > 1) {
      filter = inputArr[1];
    }

    return filter;
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
      projects.getAll((projects) => this.show(projects));
    }
  }

  show(projects) {
    if (this.panel == null) {
      this.panel = atom.workspace.addModalPanel({item: this});
    }

    let items = [];
    for (let project of projects) {
      const item = _.clone(project.props);
      item.project = project;
      items.push(item);
    }

    this.panel.show();
    items = this.sortItems(items);
    this.setItems(items);
    this.focusFilterEditor();
  }

  confirmed(item) {
    if (item && item.project.stats) {
      item.project.open();
      this.close();
    }
  }

  close() {
    if (this.panel) {
      this.panel.destroy();
      this.panel = null;
    }

    atom.workspace.getActivePane().activate();
  }

  cancelled() {
    this.close();
  }

  viewForItem({_id, title, group, icon, devMode, paths, project}) {
    const showPath = this.showPath;
    const projectMissing = project.stats ? false : true;

    return $$(function () {
      this.li({class: 'two-lines'},
      {'data-project-id': _id, 'data-path-missing': projectMissing}, () => {
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
          if (projectMissing) {
            this.div({class: 'icon icon-alert'}, 'Path is not available');
          } else if (showPath) {
            let path;
            for (path of paths) {
              this.div({class: 'no-icon'}, path);
            }
          }
        });
      });
    });
  }

  sortItems(items) {
    const key = this.sortBy;
    if (key === 'default') {
      return items;
    } else if (key === 'last modified') {
      items.sort((a, b) => {
        a = a.project.lastModified.getTime();
        b = b.project.lastModified.getTime();

        return a > b ? -1 : 1;
      });
    } else {
      items.sort((a, b) => {
        a = (a[key] || '\uffff').toUpperCase();
        b = (b[key] || '\uffff').toUpperCase();

        return a > b ? 1 : -1;
      });
    }

    return items;
  }
}
