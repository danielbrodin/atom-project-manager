/** @babel */
/** @jsx etch.dom */

import etch from 'etch';
import { EDIT_URI } from './view-uri';
import manager from '../Manager';
import Project from '../models/Project';

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

    atom.commands.add(this.element, {
      'core:save': () => this.saveProject(),
    });
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
      props = Object.assign(props, projectProps);
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
            <input ref="title" type="text" className="input-text" value={props.title} tabIndex="-1" />
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
