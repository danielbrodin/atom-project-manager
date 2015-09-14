Settings = require '../lib/settings'

describe "Settings", ->

  describe ".load(settings)", ->
    it "Loads the settings provided if they are flat", ->
      settings = new Settings()
      settings.load({"foo.bar.baz": 42})

      expect(atom.config.get("foo.bar.baz")).toBe 42

    it "Loads the settings provided if they are an object", ->
      settings = new Settings()
      expect(atom.config.get('foo.bar.baz')).toBe undefined
      settings.load({
        foo:
          bar:
            baz: 42
      })
      expect(atom.config.get('foo.bar.baz')).toBe 42

  describe ".load(settings) with a 'scope' option", ->
    it "Loads the settings for the scope", ->
      settings = new Settings()
      scopedSettings =
        "*":
          "foo.bar.baz": 42
        ".source.coffee":
          "foo.bar.baz": 84
      settings.load(scopedSettings)

      expect(atom.config.get("foo.bar.baz")).toBe 42
      expect(atom.config.get("foo.bar.baz", {scope:[".source.coffee"]})).toBe 84
      expect(atom.config.get("foo.bar.baz", {scope:[".text"]})).toBe 42