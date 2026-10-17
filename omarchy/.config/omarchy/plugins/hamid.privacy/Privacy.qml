import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Port of Waybar's privacy module: one icon per category while any app is
// sharing the screen, recording audio or playing audio; hidden otherwise.
// Reads PipeWire through `pw-dump --monitor` instead of Quickshell's Pipewire
// service, which needs `state` (not exposed there) and can destabilize when
// unbound node properties are read.
//
// shell.json entry settings (defaults mirror the old waybar config):
//   modules:       ["screenshare", "camera", "audio-out", "audio-in"]  order + which to show
//   ignoreMonitor: true                                      skip stream.monitor streams
//   ignore:        [{ "type": "audio-in", "name": "cava" }]  match on node.name
//                  (camera entries match the process name)
BarWidget {
  id: root
  moduleName: "hamid.privacy"

  readonly property var categories: ({
    "screenshare": { icon: "󰹑", title: "Screen sharing", alert: true },
    "camera": { icon: "󰄀", title: "Camera in use", alert: true },
    "audio-in": { icon: "󰍬", title: "Microphone in use", alert: true },
    "audio-out": { icon: "󰕾", title: "Playing audio", alert: false }
  })

  readonly property var config: ({
    modules: setting("modules", ["screenshare", "camera", "audio-out", "audio-in"]),
    ignoreMonitor: setting("ignoreMonitor", true),
    ignore: setting("ignore", [{ type: "audio-in", name: "cava" }, { type: "screenshare", name: "obs" }])
  })

  property var nodes: ({})
  // Processes holding /dev/video*; PipeWire doesn't see apps using v4l2 directly.
  property var cameraApps: []

  // apps/shown change only when the visible summary does: pw-dump emits many
  // updates per second (streams flip idle <-> running), and rebuilding the
  // Repeater on each one is the pattern that has crashed Quickshell before.
  property var apps: ({ "screenshare": [], "camera": [], "audio-in": [], "audio-out": [] })
  property var shown: []
  property string summaryKey: ""

  function recompute() {
    var next = Model.activeApps(nodes, config)
    next["camera"] = cameraApps.filter(function(name) {
      return !config.ignore.some(function(rule) { return rule.type === "camera" && rule.name === name })
    })
    var list = []
    for (var i = 0; i < config.modules.length; i++) {
      var type = config.modules[i]
      if (categories[type] && next[type] && next[type].length > 0) list.push(type)
    }
    var key = JSON.stringify([list, next])
    if (key === summaryKey) return
    summaryKey = key
    apps = next
    shown = list
  }

  onNodesChanged: recompute()
  onCameraAppsChanged: recompute()
  onConfigChanged: recompute()

  // hamid.bar: paint our own accent island beside the center pill. The bar
  // leaves this slot out of the center pill; the leading gap here is its
  // islandPadding (7) + islandGap (8), so the two pills sit one islandGap apart.
  readonly property bool ownIsland: true
  readonly property int leadingGap: Style.space(15)
  readonly property int pillPadding: Style.space(7)
  readonly property color ink: bar ? bar.background : Color.background
  // Pulse only for mic/screen capture; plain playback shows a calm pill.
  readonly property bool alerting: shown.some(function(type) { return categories[type].alert })

  visible: shown.length > 0
  implicitWidth: vertical ? barSize : leadingGap + pill.width
  implicitHeight: vertical ? leadingGap + pill.height : barSize

  onVisibleChanged: if (visible) appear.restart()
  NumberAnimation { id: appear; target: pill; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.OutCubic }

  // ponytail: one pw-dump per bar instance (one per monitor); move to a
  // shared service if that ever shows up in CPU usage.
  Process {
    id: dump
    command: ["pw-dump", "--monitor", "--raw", "--no-colors"]
    stdout: SplitParser {
      onRead: function(line) {
        try {
          root.nodes = Model.applyUpdate(root.nodes, JSON.parse(line))
        } catch (e) {
          console.warn("hamid.privacy: unparsable pw-dump line:", e)
        }
      }
    }
    onRunningChanged: if (!running) {
      root.nodes = ({})
      restart.start()
    }
  }

  // Start only once stdout is attached, or the initial dump can be lost.
  Component.onCompleted: dump.running = true

  // v4l2 hands the device to a process, not a service we could watch, so poll.
  Process {
    id: cameraProbe
    command: ["bash", String(Qt.resolvedUrl("camera-users.sh")).replace(/^file:\/\//, "")]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var names = text.split("\n").filter(function(name) { return name !== "" })
        if (JSON.stringify(names) !== JSON.stringify(root.cameraApps)) root.cameraApps = names
      }
    }
  }

  Timer {
    interval: 3000
    repeat: true
    triggeredOnStart: true
    running: root.config.modules.indexOf("camera") !== -1
    onTriggered: if (!cameraProbe.running) cameraProbe.running = true
  }

  // pw-dump exits if PipeWire restarts; reconnect.
  Timer {
    id: restart
    interval: 2000
    onTriggered: dump.running = true
  }

  Rectangle {
    id: pill
    x: root.vertical ? 0 : root.leadingGap
    y: root.vertical ? root.leadingGap : 0
    width: root.vertical ? root.barSize : grid.implicitWidth + root.pillPadding * 2 + dot.width
    height: root.vertical ? grid.implicitHeight + root.pillPadding * 2 + dot.height : root.barSize
    radius: Math.min(width, height) / 2
    color: Color.accent

    // Slow "on air" pulse, so a glance says something is live.
    Rectangle {
      id: dot
      width: Style.space(6)
      height: width
      radius: width / 2
      color: root.ink
      x: root.vertical ? (pill.width - width) / 2 : root.pillPadding
      y: root.vertical ? root.pillPadding : (pill.height - height) / 2

      SequentialAnimation on opacity {
        running: root.visible && root.alerting
        loops: Animation.Infinite
        onRunningChanged: if (!running) dot.opacity = 1
        NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
      }
    }
  }

  Grid {
    id: grid
    x: root.vertical ? 0 : pill.x + root.pillPadding + dot.width
    y: root.vertical ? pill.y + root.pillPadding + dot.height : 0
    opacity: pill.opacity
    columns: root.vertical ? 1 : Math.max(1, root.shown.length)
    spacing: 0

    Repeater {
      model: root.shown

      BarIconButton {
        required property string modelData
        readonly property var category: root.categories[modelData]

        bar: root.bar
        text: category.icon
        foreground: root.ink
        slotSize: Style.space(22)
        tooltipText: category.title + "\n" + root.apps[modelData].join("\n")
        onPressed: function(b) {
          if (modelData === "audio-in" || modelData === "audio-out") root.bar.run("omarchy-shell shell toggle omarchy.audio")
        }
      }
    }
  }
}
