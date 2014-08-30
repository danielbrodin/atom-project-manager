{$, $$, View, EditorView} = require 'atom'

module.exports =
class ProjectPathView extends View
  @content: ->
    @div =>
      @subview 'pathField', new EditorView(mini: true)

  initialize: (path) ->
    @pathField.setText(path)
