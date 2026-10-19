import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "." as Peats

BarWidget {
  id: root
  moduleName: "hamid.soundpeats"

  readonly property bool showBattery: setting("showBattery", true) === true
  readonly property bool showMode: setting("showMode", false) === true
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color barForeground: bar ? bar.barForeground : Color.foreground
  readonly property bool present: Peats.PeatsState.connected
  readonly property bool showsPercent: showBattery && Peats.PeatsState.lowestBattery >= 0 && !button.vertical
  readonly property bool showsMode: showMode && Peats.PeatsState.shownMode !== "" && !button.vertical

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function toggle() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function tooltip() {
    var state = Peats.PeatsState
    var name = state.deviceName || "SoundPEATS"
    if (!state.control) return name + " · connecting…"
    return name + " · " + state.modeLabel(state.shownMode) + " · right-click to switch"
  }

  // Keep the root visible so the bar can measure the button; collapse the
  // slot instead while no SoundPEATS buds are connected.
  visible: true
  implicitWidth: present ? button.implicitWidth : 0
  implicitHeight: present ? button.implicitHeight : 0
  opacity: present ? 1 : 0

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "hamid.soundpeats"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function cycle(): void { Peats.PeatsState.cycleMode() }
    function mode(value: string): void { Peats.PeatsState.setMode(value) }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    labelVisible: false
    hasVisualContent: true
    keepSpace: root.present
    dimmed: !Peats.PeatsState.control
    fixedWidth: vertical ? -1 : barContent.implicitWidth + scaledHorizontalMargin * 2
    fixedHeight: vertical ? Style.bar.iconSlot : -1
    tooltipText: root.tooltip()
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
      else if (buttonCode === Qt.RightButton) Peats.PeatsState.cycleMode()
    }

    Row {
      id: barContent
      anchors.centerIn: parent
      spacing: Style.space(5)

      Text {
        text: Peats.PeatsState.modeGlyph(Peats.PeatsState.shownMode)
        color: root.barForeground
        font.family: root.fontFamily
        font.pixelSize: Style.bar.iconFont
        renderType: Text.NativeRendering
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        visible: root.showsMode
        text: Peats.PeatsState.modeLabel(Peats.PeatsState.shownMode)
        color: root.barForeground
        font.family: root.fontFamily
        font.pixelSize: Style.bar.iconFont
        renderType: Text.NativeRendering
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        visible: root.showsPercent
        text: Peats.PeatsState.lowestBattery + "%"
        color: root.barForeground
        font.family: root.fontFamily
        font.pixelSize: Style.bar.iconFont
        renderType: Text.NativeRendering
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }
}
