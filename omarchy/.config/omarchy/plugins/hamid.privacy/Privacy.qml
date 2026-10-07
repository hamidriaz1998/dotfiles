import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import "Model.js" as Model

// Port of Waybar's privacy module: one icon per category while any app is
// sharing the screen, recording audio or playing audio; hidden otherwise.
// Reads PipeWire through `pw-dump --monitor` instead of Quickshell's Pipewire
// service, which needs `state` (not exposed there) and can destabilize when
// unbound node properties are read.
//
// shell.json entry settings (defaults mirror the old waybar config):
//   modules:       ["screenshare", "audio-out", "audio-in"]  order + which to show
//   ignoreMonitor: true                                      skip stream.monitor streams
//   ignore:        [{ "type": "audio-in", "name": "cava" }]  match on node.name
BarWidget {
  id: root
  moduleName: "hamid.privacy"

  readonly property var categories: ({
    "screenshare": { icon: "󰹑", title: "Screen sharing", alert: true },
    "audio-in": { icon: "󰍬", title: "Microphone in use", alert: true },
    "audio-out": { icon: "󰕾", title: "Playing audio", alert: false }
  })

  readonly property var config: ({
    modules: setting("modules", ["screenshare", "audio-out", "audio-in"]),
    ignoreMonitor: setting("ignoreMonitor", true),
    ignore: setting("ignore", [{ type: "audio-in", name: "cava" }, { type: "screenshare", name: "obs" }])
  })

  property var nodes: ({})

  // apps/shown change only when the visible summary does: pw-dump emits many
  // updates per second (streams flip idle <-> running), and rebuilding the
  // Repeater on each one is the pattern that has crashed Quickshell before.
  property var apps: ({ "screenshare": [], "audio-in": [], "audio-out": [] })
  property var shown: []
  property string summaryKey: ""

  function recompute() {
    var next = Model.activeApps(nodes, config)
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
  onConfigChanged: recompute()

  visible: shown.length > 0
  implicitWidth: grid.implicitWidth
  implicitHeight: grid.implicitHeight

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

  // pw-dump exits if PipeWire restarts; reconnect.
  Timer {
    id: restart
    interval: 2000
    onTriggered: dump.running = true
  }

  Grid {
    id: grid
    anchors.fill: parent
    columns: root.vertical ? 1 : Math.max(1, root.shown.length)
    spacing: 0

    Repeater {
      model: root.shown

      BarIconButton {
        required property string modelData
        readonly property var category: root.categories[modelData]

        bar: root.bar
        text: category.icon
        active: category.alert
        tooltipText: category.title + "\n" + root.apps[modelData].join("\n")
        onPressed: function(b) {
          if (modelData !== "screenshare") root.bar.run("omarchy-shell shell toggle omarchy.audio")
        }
      }
    }
  }
}
