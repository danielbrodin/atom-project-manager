const Settings = require('../lib/Settings');

const settings = new Settings();

describe('Settings', () => {
  it('loads settings without scope', () => {
    const config = {
      'foo.bar': 'baz',
      'bar.foo': 'baz',
    };

    settings.load(config);

    expect(atom.config.get('foo.bar')).toBe('baz');
    expect(atom.config.get('bar.foo')).toBe('baz');
  });

  it('loads settings with scope', () => {
    const config = {
      '*': {
        'foo.bar': 'baz',
      },
      '.js.source': {
        'foo.bar': 'not-baz',
      },
    };

    settings.load(config);

    expect(atom.config.get('foo.bar')).toBe('baz');
    expect(atom.config.get('foo.bar', { scope: ['.js.source'] })).toBe('not-baz');
  });

  it('loads settings with duplicate keys', () => {
    const config = {
      foo: {
        bar: {
          baz: 'overwritten',
          boo: 'not-duplicate',
        },
      },
      'foo.bar': {
        baz: 'duplicate',
      },
    };

    settings.load(config);

    expect(atom.config.get('foo.bar.boo')).toBe('not-duplicate');
    expect(atom.config.get('foo.bar.baz')).toBe('duplicate');
  });
});
