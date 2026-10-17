import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // split-monitor-workspaces: each monitor owns a block of 10 ids (1-10, 11-20, ...).
  // Show only this bar's monitor block, labelled 1..0 like the old waybar setup.
  readonly property var monitor: QsWindow.window ? Hyprland.monitorFor(QsWindow.window.screen) : null
  readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 1
  readonly property int base: Math.floor(Math.max(activeId - 1, 0) / 10) * 10

  readonly property var ids: {
    var out = []
    for (var n = 1; n <= 5; n++) out.push(base + n)
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > base && id <= base + 10 && out.indexOf(id) === -1) out.push(id)
    }

    out.sort(function(left, right) { return left - right })
    return out
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  // Cells along the bar; the focused one stretches and the accent pill slides
  // under it.
  // Old waybar rhythm: 10px padding + 4px margin per side, 16px when active.
  readonly property int cellSize: Style.space(26)
  readonly property int activeCellSize: Style.space(40)
  readonly property int pillInset: Style.space(5)
  readonly property var activeCell: {
    var count = cells.count
    var i = root.ids.indexOf(root.activeId)
    return i >= 0 && i < count ? cells.itemAt(i) : null
  }

  implicitWidth: grid.implicitWidth
  implicitHeight: grid.implicitHeight

  Rectangle {
    visible: root.activeCell !== null
    x: root.activeCell ? root.activeCell.x + (root.vertical ? root.pillInset : 0) : 0
    y: root.activeCell ? root.activeCell.y + (root.vertical ? 0 : root.pillInset) : 0
    width: root.activeCell ? root.activeCell.width - (root.vertical ? root.pillInset * 2 : 0) : 0
    height: root.activeCell ? root.activeCell.height - (root.vertical ? 0 : root.pillInset * 2) : 0
    radius: Math.min(width, height) / 2
    color: Color.accent

    Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
  }

  Grid {
    id: grid
    columns: root.vertical ? 1 : root.ids.length

    Repeater {
      id: cells
      model: root.ids

      WidgetButton {
        id: cell
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: root.activeId === modelData

        bar: root.bar
        // The focused workspace is a dark dot on the accent pill.
        text: String(modelData % 10)
        labelVisible: !focused
        hasVisualContent: true
        foreground: root.bar ? root.bar.barForeground : Color.foreground
        opacity: focused || occupied ? 1 : 0.4

        Rectangle {
          anchors.centerIn: parent
          width: Style.space(7)
          height: width
          radius: width / 2
          color: root.bar ? root.bar.background : Color.background
          scale: cell.focused ? 1 : 0
          Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
        }
        fixedWidth: root.vertical ? root.barSize : (focused ? root.activeCellSize : root.cellSize)
        fixedHeight: root.vertical ? (focused ? root.activeCellSize : root.cellSize) : root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }

        Behavior on fixedWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on fixedHeight { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        // Hover chip on the other workspaces; the focused one has the pill.
        Rectangle {
          z: -1
          anchors.fill: parent
          anchors.margins: root.pillInset
          radius: Math.min(width, height) / 2
          color: Util.alpha(root.bar ? root.bar.barForeground : Color.foreground, 0.12)
          opacity: cell.tooltipHovered && !cell.focused ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 140 } }
        }
      }
    }
  }
}
