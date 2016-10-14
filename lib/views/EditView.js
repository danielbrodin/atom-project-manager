/** @babel */
/** @jsx etch.dom */

import { CompositeDisposable } from 'atom';
import etch from 'etch';
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

    manager.saveProject(projectProps);
    let message = `${projectProps.title} has been saved.`;
    if (this.props.project) {
      message = `${this.props.project.title} has been update.`;
    }
    atom.notifications.addSuccess(message);

    this.close();
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

  getIconName() {
    return 'gear';
  }

  getURI() {
    return EDIT_URI;
  }

  render() {
    const defaultProps = Project.defaultProps;
    let props = defaultProps;

    if (this.props.project) {
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
      <div
        style={wrapperStyle}
        className="project-manager-edit padded native-key-bindings"
      >
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
              className="input-checkbox"
              checked={props.devMode}
              tabIndex="3"
              />
          </div>

          <div className="block" style={{ textAlign: 'right' }}>
            <button ref="save" className="btn btn-primary">Save</button>
          </div>
        </div>
      </div>
    );
  }
}
