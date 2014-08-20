{$, $$, View, EditorView} = require 'atom'

module.exports =
class ProjectSettingView extends View
  @content: ->
    @div class: 'row', =>
      @div class: 'col-lg-6', =>
        @subview 'settingNameEditor', new EditorView({ mini: true })
      @div class: 'col-lg-6', =>
        @div class: 'input-group', =>
          @subview 'settingValueEditor', new EditorView({ mini: true })
          @div class: 'input-group-btn', =>
            @button class: 'btn btn-default', outlet: 'removePathButton', =>
              @span class: 'icon icon-dash'

  initialize: ({settingName, settingValue}) ->
    @settingNameEditor.setPlaceholderText('package-name.settingName')
    @settingValueEditor.setPlaceholderText('right, true, 1, eggs ...')
    @settingNameEditor.setText(settingName) if settingName
    @settingValueEditor.setText(settingValue) if settingValue

    @removePathButton.on 'click', =>
      @parent().view().removeSetting(@)
