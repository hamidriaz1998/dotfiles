import QtQuick
import qs.Commons
import qs.Ui
import "." as Peats

Panel {
  id: root
  moduleName: "hamid.soundpeats"
  ipcTarget: "hamid.soundpeats"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property color dimForeground: Qt.darker(contentForeground, 1.55)
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool showBattery: setting("showBattery", true) === true
  readonly property bool showMode: setting("showMode", false) === true
  property bool gesturesOpen: false

  function open() { root.controller.show() }
  function close() { root.controller.hide() }
  function toggle() { if (root.opened) root.close(); else root.open() }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function updateSetting(key, value) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings)
      if (existing !== "id") entry[existing] = root.settings[existing]
    entry[key] = value
    root.settings = entry
    if (root.hostWidget && "settings" in root.hostWidget)
      root.hostWidget.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function batteryText(key) {
    var battery = Peats.PeatsState.battery || {}
    var level = battery[key]
    return typeof level === "number" ? level + "%" : "—"
  }

  readonly property string heroMeta: {
    var state = Peats.PeatsState
    if (!state.connected) return "Not connected"
    if (!state.control) return "Connecting to controls…"
    return state.modeLabel(state.shownMode)
  }

  component Chip: Button {
    required property var modelData
    bordered: true
    foreground: root.contentForeground
    fontFamily: root.contentFontFamily
    fontSize: Style.font.bodySmall
  }

  component SettingRow: Item {
    property string label: ""
    property bool checked: false
    signal toggled()

    width: parent ? parent.width : 0
    implicitHeight: Math.max(rowLabel.implicitHeight, rowSwitch.implicitHeight)
    opacity: enabled ? 1.0 : 0.4

    Text {
      id: rowLabel
      text: parent.label
      color: root.contentForeground
      font.family: root.contentFontFamily
      font.pixelSize: Style.font.bodySmall
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
    }

    ToggleSwitch {
      id: rowSwitch
      checked: parent.checked
      foreground: root.contentForeground
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      onToggled: parent.toggled()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Math.max(Style.space(340), modeGroup.implicitWidth))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(18)

        PanelHero {
          width: parent.width
          title: Peats.PeatsState.deviceName || "SoundPEATS"
          meta: root.heroMeta
          detail: Peats.PeatsState.control ? Peats.PeatsState.firmwareVersion : ""
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
          iconOpacity: Peats.PeatsState.control ? 1.0 : 0.5
          iconComponent: Component {
            Text {
              text: Peats.PeatsState.modeGlyph(Peats.PeatsState.shownMode)
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.display
              renderType: Text.NativeRendering
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: Peats.PeatsState.connected

          PanelSectionHeader {
            width: parent.width
            text: "Battery"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
          }

          Row {
            id: batteryRow
            width: parent.width
            spacing: Style.space(18)

            Repeater {
              model: [
                { label: "Left", key: "left" },
                { label: "Right", key: "right" },
                { label: "Case", key: "case" }
              ]

              delegate: Column {
                required property var modelData
                width: (batteryRow.width - batteryRow.spacing * 2) / 3
                spacing: Style.space(2)

                Text {
                  text: modelData.label
                  color: root.dimForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                }

                Text {
                  text: root.batteryText(modelData.key)
                  color: root.contentForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.body
                }
              }
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: Peats.PeatsState.control

          PanelSectionHeader {
            width: parent.width
            text: "Noise control"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
          }

          Row {
            id: modeGroup
            spacing: Style.spacing.md

            Repeater {
              model: Peats.PeatsState.modes
              Chip {
                text: modelData.glyph + "  " + modelData.label
                selected: modelData.value === Peats.PeatsState.shownMode
                onClicked: Peats.PeatsState.setMode(modelData.value)
              }
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: Peats.PeatsState.control

          PanelSectionHeader {
            width: parent.width
            text: "Controls"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
          }

          Repeater {
            model: Peats.PeatsState.switchList
            SettingRow {
              required property var modelData
              visible: typeof Peats.PeatsState.switches[modelData.value] === "boolean"
              label: modelData.label
              checked: Peats.PeatsState.switches[modelData.value] === true
              onToggled: Peats.PeatsState.setSwitch(modelData.value, !checked)
            }
          }

          Item {
            width: parent.width
            height: Style.spacing.controlHeight
            visible: Peats.PeatsState.promptVolume !== null

            Text {
              id: promptLabel
              text: "Prompt volume"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
            }

            PanelSlider {
              id: promptSlider
              bar: root.bar
              anchors.left: promptLabel.right
              anchors.leftMargin: Style.space(12)
              anchors.right: promptValue.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              minimum: 0
              maximum: 100
              step: 6.25
              value: Peats.PeatsState.promptVolume || 0
              onReleased: function(v) { Peats.PeatsState.setPromptVolume(v) }
            }

            Text {
              id: promptValue
              width: Style.space(36)
              horizontalAlignment: Text.AlignRight
              text: Math.round(promptSlider.dragging ? promptSlider.liveValue : (Peats.PeatsState.promptVolume || 0)) + "%"
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: Peats.PeatsState.control && Object.keys(Peats.PeatsState.keys).length > 0

          // Gestures rarely change, so the list starts collapsed.
          PanelSectionHeader {
            width: parent.width
            text: (root.gesturesOpen ? "▾ " : "▸ ") + "Gestures"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.gesturesOpen = !root.gesturesOpen
            }
          }

          Repeater {
            model: root.gesturesOpen ? Peats.PeatsState.gestureList : []
            Item {
              required property var modelData
              width: parent.width
              height: Style.spacing.controlHeight

              Text {
                text: modelData.label
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Dropdown {
                width: Style.space(170)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                showLabel: false
                fontFamily: root.contentFontFamily
                options: Peats.PeatsState.actionList
                value: Peats.PeatsState.keys[modelData.value] || ""
                onChanged: function(action) {
                  // Selecting assigns value directly, which breaks the binding.
                  value = Qt.binding(function() { return Peats.PeatsState.keys[modelData.value] || "" })
                  if (action !== Peats.PeatsState.keys[modelData.value])
                    Peats.PeatsState.setKey(modelData.value, action)
                }
              }
            }
          }

          // Factory gestures differ from what the app shows as defaults, so
          // ask twice before resetting.
          Button {
            id: resetButton
            visible: root.gesturesOpen
            property bool armed: false
            text: armed ? "Click again to reset gestures" : "Reset gestures to factory"
            bordered: true
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
            fontSize: Style.font.bodySmall
            onClicked: {
              if (armed) {
                armed = false
                Peats.PeatsState.resetKeys()
              } else {
                armed = true
                disarm.restart()
              }
            }
            Timer {
              id: disarm
              interval: 3000
              onTriggered: resetButton.armed = false
            }
          }
        }

        Column {
          width: parent.width
          spacing: Style.space(6)

          PanelSectionHeader {
            width: parent.width
            text: "Bar"
            foreground: root.contentForeground
            fontFamily: root.contentFontFamily
          }

          SettingRow {
            label: "Battery percent"
            checked: root.showBattery
            onToggled: root.updateSetting("showBattery", !root.showBattery)
          }

          SettingRow {
            label: "Mode name"
            checked: root.showMode
            onToggled: root.updateSetting("showMode", !root.showMode)
          }
        }
      }
    }
  }
}
