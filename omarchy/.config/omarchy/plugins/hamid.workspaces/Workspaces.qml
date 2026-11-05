import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

  // Omarchy's per-monitor workspaces (default/hypr/monitor-workspaces.lua):
  // each monitor owns a block of ten ids, assigned by the file Hyprland keeps.
  // This bar shows its own monitor's block, numbered 1-10, plus any workspaces
  // visiting from an unplugged monitor. Pill look is hamid's; logic is stock's.
  readonly property int slots: 10

  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""

  // Connector -> block.
  property var blocks: ({})

  function readBlocks(text) {
    var next = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
    }
    root.blocks = next
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readBlocks(text())
    onLoadFailed: root.readBlocks("")
  }

  function blockOf(id) { return Math.floor((id - 1) / root.slots) }
  function slotOf(id) { return (id - 1) % root.slots + 1 }

  readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1

  // Until Hyprland has written the file, the monitor's block is the one its
  // active workspace is in.
  readonly property int block: {
    var known = root.blocks[root.monitorName]
    if (known !== undefined) return known
    return root.activeId > 0 ? root.blockOf(root.activeId) : 0
  }

  // The first five of the monitor's own, any of the rest that exist, then guests.
  readonly property var ids: {
    var base = root.block * root.slots
    var out = [base + 1, base + 2, base + 3, base + 4, base + 5]
    var guests = []
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id <= 0) continue
      if (root.blockOf(id) === root.block) {
        if (out.indexOf(id) === -1) out.push(id)
      } else if (values[i].monitor && values[i].monitor.name === root.monitorName) {
        guests.push(id)
      }
    }
    out.sort(function(left, right) { return left - right })
    guests.sort(function(left, right) { return left - right })
    return out.concat(guests)
  }

  function dispatch(expression) {
    if (root.bar) root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  function focusWorkspace(id) {
    if (root.blockOf(id) === root.block)
      root.dispatch("o.workspaces.focus(" + root.slotOf(id) + ", \"" + root.monitorName + "\")")
    else
      root.dispatch("hl.dsp.focus({ workspace = \"" + id + "\" })")
  }

  // One notch moves one entry along the row; holds at either end.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return
    var index = root.ids.indexOf(root.activeId)
    if (index === -1) return
    var target = root.ids[Util.clamp(index - wheel.steps, 0, root.ids.length - 1)]
    if (target !== root.ids[index]) root.focusWorkspace(target)
  }

  // Quickshell credits every switch to the focused monitor and misses
  // workspaces moved between monitors, so ask Hyprland for the truth.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
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
        text: String(root.slotOf(modelData) % 10)
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
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }

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
