const FileStore = require('../lib/stores/FileStore');
const path = require('path');

const storesPath = path.resolve(__dirname, 'stores');

describe('FileStore', () => {
  it('lets you know when it is done fetching', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'array-structure.cson'));
    const fileStore = new FileStore();

    expect(fileStore.fetching).toBe(false);
    fileStore.fetch();
    expect(fileStore.fetching).toBe(true);

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.fetching).toBe(false);
    });
  });

  it('manages empty files', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'empty.cson'));
    const fileStore = new FileStore();

    fileStore.fetch();
    expect(fileStore.fetching).toBe(true);

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.fetching).toBe(false);
      expect(fileStore.data.length).toBe(0);
    });
  });

  it('manages the 1.x object structure', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'object-structure.cson'));
    const fileStore = new FileStore();

    fileStore.fetch();

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.data.length).toBe(1);
      expect(fileStore.data[0].title).toBe('bar');
    });
  });

  it('manages if no file exists', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'a-file-that-doesnt-exist.cson'));
    const fileStore = new FileStore();
    spyOn(fileStore, 'store').andCallFake(() => false);

    fileStore.fetch();

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.data.length).toBe(0);
    });
  });

  it('manages the 2.x structure', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'array-structure.cson'));
    const fileStore = new FileStore();

    fileStore.fetch();

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.data.length).toBe(2);
    });
  });

  it('separates projects and templates', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'with-template-and-project.cson'));
    const fileStore = new FileStore();

    fileStore.fetch();

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.data.length).toBe(1);
      expect(fileStore.templates.length).toBe(1);
    });
  });

  it('merges the project with the template', () => {
    spyOn(FileStore, 'getPath').andCallFake(() => path.resolve(storesPath, 'with-template-and-project.cson'));
    const fileStore = new FileStore();

    fileStore.fetch();

    waitsFor(() => fileStore.fetching === false);

    runs(() => {
      expect(fileStore.data[0].group).toBe('foobar');
    });
  });
});
