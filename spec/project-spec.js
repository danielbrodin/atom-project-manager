const Project = require('../lib/models/Project');

const packagePaths = atom.packages.getPackageDirPaths();
const packagePath = `${packagePaths}/project-manager`;

describe('Project', () => {
  describe('properties', () => {
    it('return all props including defaults when calling getProps', () => {
      const project = new Project({
        title: 'text',
        paths: [packagePath],
        group: 'test',
        someThingNew: 'awesome',
      });

      const props = project.getProps();
      const defaultProps = Project.defaultProps;

      expect(props.someThingNew).toBeDefined();

      Object.keys(defaultProps).forEach((key) => {
        expect(props[key]).toBeDefined();
      });
    });

    it('only returns changed props when calling getChangedProps', () => {
      const project = new Project({
        title: 'text',
        paths: [packagePath],
        group: 'test',
      });

      const changedProps = project.getChangedProps();

      expect(changedProps.group).toBe('test');
      expect(changedProps.icon).not.toBeDefined();
    });

    it('can update its properties', () => {
      const project = new Project({
        title: 'text',
        paths: [packagePath],
      });

      expect(project.getProps().group).toBe('');
      expect(project.someThingNew).not.toBeDefined();

      project.updateProps({
        group: 'test',
        someThingNew: 'awesome',
      });

      expect(project.getProps().group).toBe('test');
      expect(project.getProps().someThingNew).toBeDefined();
    });
  });
});
