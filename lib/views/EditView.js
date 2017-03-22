/** @babel */
/** @jsx etch.dom */

import { CompositeDisposable } from 'atom';
import etch from 'etch';
import changeCase from 'change-case';
import path from 'path';
import { EDIT_URI } from './view-uri';
import manager from '../Manager';
import Project from '../models/Project';

const disposables = new CompositeDisposable();

etch.setScheduler(atom.views);

export default class EditView {
  constructor(props, children) {
    this.props = props;
    this.children = children;
    etch.initialize(this);

    this.storeFocusedElement();

    this.setFocus();

    this.element.addEventListener('click', (event) => {
      if (event.target === this.refs.save) {
        this.saveProject();
      }
    });

    disposables.add(atom.commands.add(this.element, {
      'core:save': () => this.saveProject(),
      'core:confirm': () => this.saveProject(),
    }));

    disposables.add(atom.commands.add('atom-workspace', {
      'core:cancel': () => this.close(),
    }));
  }

  getFocusElement() {
    return this.refs.title;
  }

  setFocus() {
    const focusElement = this.getFocusElement();

    if (focusElement) {
      setTimeout(() => {
        focusElement.focus();
      }, 0);
    }
  }

  storeFocusedElement() {
    this.previouslyFocusedElement = document.activeElement;
  }

  restoreFocus() {
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus();
    }
  }

  close() {
    this.destroy();
  }

  async destroy() {
    const pane = atom.workspace.paneForURI(EDIT_URI);
    if (pane) {
      const item = pane.itemForURI(EDIT_URI);
      pane.destroyItem(item);
    }

    disposables.dispose();
    await etch.destroy(this);
  }

  saveProject() {
    const projectProps = {
      title: this.refs.title.value,
      paths: atom.project.getPaths(),
      group: this.refs.group.value,
      icon: this.refs.icon.value,
      devMode: this.refs.devMode.checked,
    };
    let message = `${projectProps.title} has been saved.`;

    if (this.props.project) {
      // Paths should already be up-to-date, so use
      // the current paths as to not break possible relative paths.
      projectProps.paths = this.props.project.getProps().paths;
    }

    // many stuff will break if there is no root path,
    // so we don't continue without a root path
    if (!projectProps.paths.length) {
      atom.notifications.addError('You must have at least one folder in your project before you can save !');
    } else {
      manager.saveProject(projectProps);

      if (this.props.project) {
        message = `${this.props.project.title} has been updated.`;
      }
      atom.notifications.addSuccess(message);

      this.close();
    }
  }

  update(props, children) {
    this.props = props;
    this.children = children;
  }

  getTitle() {
    if (this.props.project) {
      return `Edit ${this.props.project.title}`;
    }

    return 'Save Project';
  }

  getIconName() { // eslint-disable-line class-methods-use-this
    return 'gear';
  }

  getURI() { // eslint-disable-line class-methods-use-this
    return EDIT_URI;
  }

  render() {
    const defaultProps = Project.defaultProps;
    const rootPath = atom.project.getPaths()[0];
    let props = defaultProps;

    if (atom.config.get('project-manager.prettifyTitle')) {
      props.title = changeCase.titleCase(path.basename(rootPath));
    }

    if (this.props.project && this.props.project.source === 'file') {
      const projectProps = this.props.project.getProps();
      props = Object.assign({}, props, projectProps);
    }

    const wrapperStyle = {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    };

    const style = {
      width: '500px',
    };

    return (
      <div style={wrapperStyle} className="project-manager-edit padded native-key-bindings">
        <div style={style}>
          <h1 className="block section-heading">{this.getTitle()}</h1>

          <div className="block">
            <label className="input-label">Title</label>
            <input ref="title" type="text" className="input-text" value={props.title} tabIndex="0" />
          </div>

          <div className="block">
            <label className="input-label">Group</label>
            <input ref="group" type="text" className="input-text" value={props.group} tabIndex="1" />
          </div>

          <div className="block">
            <label className="input-label">Icon</label>
            <input ref="icon" type="text" className="input-text" value={props.icon} tabIndex="2" />
          </div>

          <div className="block">
            <label className="input-label" for="devMode">Development mode</label>
              <input
                ref="devMode"
                id="devMode"
                name="devMode"
                type="checkbox"
                className="input-toggle"
                checked={props.devMode}
                tabIndex="3"
              />
          </div>

          <div className="block" style={{ textAlign: 'right' }}>
            <button ref="save" className="btn btn-primary" tabIndex="4">Save</button>
          </div>
        </div>
      </div>
    );
  }
}
