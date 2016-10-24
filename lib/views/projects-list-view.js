'use babel';

/* eslint "class-methods-use-this": ["error", {"exceptMethods": ["viewForItem"]}] */

import { SelectListView, $$ } from 'atom-space-pen-views';
import { autorun } from 'mobx';
import { each } from 'underscore-plus';
import manager, { Manager } from '../Manager';

export default class ProjectsListView extends SelectListView {
  constructor() {
    super();

    autorun('Loading projects for list view', () => {
      if (this.panel && this.panel.isVisible()) {
        this.show(manager.projects);
      }
    });
  }
  initialize() {
    super.initialize();
    this.addClass('project-manager');

    let infoText = 'shift+enter will open project in the current window';
    if (ProjectsListView.reversedConfirm) {
      infoText = 'shift+enter will open project in a new window';
    }
    const infoElement = document.createElement('div');
    infoElement.className = 'text-smaller';
    infoElement.innerHTML = infoText;
    this.error.after(infoElement);

    atom.commands.add(this.element, {
      'project-manager:alt-confirm': (event) => {
        this.altConfirmed();
        event.stopPropagation();
      },
    });
  }

  static get possibleFilterKeys() {
    return ['title', 'group', 'template'];
  }

  static get defaultFilterKey() {
    return 'title';
  }

  static get sortBy() {
    return atom.config.get('project-manager.sortBy');
  }

  static get showPath() {
    return atom.config.get('project-manager.showPath');
  }

  static get reversedConfirm() {
    return atom.config.get('project-manager.alwaysOpenInSameWindow');
  }

  getFilterKey() {
    const input = this.filterEditorView.getText();
    const inputArr = input.split(':');
    const isFilterKey = ProjectsListView.possibleFilterKeys.includes(inputArr[0]);
    let filter = ProjectsListView.defaultFilterKey;

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
    }
    return super.getEmptyMessage(itemCount, filteredItemCount);
  }

  toggle() {
    if (this.panel && this.panel.isVisible()) {
      this.cancel();
    } else {
      this.show(manager.projects);
    }
  }

  show(projects) {
    if (this.panel == null) {
      this.panel = atom.workspace.addModalPanel({ item: this });
    }

    this.storeFocusedElement();

    const sortedProjects = ProjectsListView.sortItems(projects);

    this.setItems(sortedProjects);
    this.focusFilterEditor();
  }

  confirmed(project) {
    if (project) {
      Manager.open(project, ProjectsListView.reversedConfirm);
      this.hide();
    }
  }

  altConfirmed() {
    const project = this.getSelectedItem();
    if (project) {
      Manager.open(project, !ProjectsListView.reversedConfirm);
      this.hide();
    }
  }

  hide() {
    if (this.panel) {
      this.panel.hide();
    }
  }

  cancel() {
    super.cancel();
  }

  cancelled() {
    this.hide();
  }

  viewForItem(project) {
    const { title, group, icon, devMode, paths } = project.props;
    const showPath = ProjectsListView.showPath;
    const projectMissing = !project.stats;

    return $$(function itemView() {
      this.li({ class: 'two-lines' },
      { 'data-path-missing': projectMissing }, () => {
        this.div({ class: 'primary-line' }, () => {
          if (devMode) {
            this.span({ class: 'project-manager-devmode' });
          }

          this.div({ class: `icon ${icon}` }, () => {
            this.span(title);
            if (group) {
              this.span({ class: 'project-manager-list-group' }, group);
            }
          });
        });
        this.div({ class: 'secondary-line' }, () => {
          if (projectMissing) {
            this.div({ class: 'icon icon-alert' }, 'Path is not available');
          } else if (showPath) {
            each(paths, (path) => {
              this.div({ class: 'no-icon' }, path);
            }, this);
          }
        });
      });
    });
  }

  static sortItems(items) {
    const key = ProjectsListView.sortBy;
    let sorted = items;

    if (key === 'default') {
      return items;
    } else if (key === 'last modified') {
      sorted = items.sort((a, b) => {
        const aModified = a.lastModified.getTime();
        const bModified = b.lastModified.getTime();

        return aModified > bModified ? -1 : 1;
      });
    } else {
      sorted = items.sort((a, b) => {
        const aValue = (a[key] || '\uffff').toUpperCase();
        const bValue = (b[key] || '\uffff').toUpperCase();

        return aValue > bValue ? 1 : -1;
      });
    }

    return sorted;
  }
}
