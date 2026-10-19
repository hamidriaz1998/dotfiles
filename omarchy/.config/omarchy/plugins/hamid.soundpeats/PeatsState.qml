pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// One `peats watch` backend shared by every bar. It holds the buds' single
// SPP channel and prints a JSON state line per change. Install it with
// `go install github.com/hamidriaz1998/peats@latest`.
Item {
  id: root

  property bool connected: false
  property bool control: false
  property string address: ""
  property string deviceName: ""
  property string firmware: ""
  property string mode: ""
  property string pendingMode: ""
  property var switches: ({})
  property var keys: ({})
  property var promptVolume: null
  property var battery: ({})
  property var headset: null
  property bool lowBatteryNotified: false
  property bool criticalBatteryNotified: false

  readonly property int lowBatteryPercent: 20
  readonly property int criticalBatteryPercent: 10
  readonly property int lowBatteryClearPercent: 30
  readonly property string helperCommand: Quickshell.env("HOME") + "/go/bin/peats"

  // "ZKLXT3PRO_20250428_v0.0.31" -> "v0.0.31"
  readonly property string firmwareVersion: {
    var parts = firmware.split("_")
    return parts[parts.length - 1]
  }

  // Mode the UI should show: the requested one until the buds confirm it.
  readonly property string shownMode: pendingMode !== "" ? pendingMode : mode

  readonly property int lowestBattery: {
    var levels = []
    var b = root.battery || {}
    if (typeof b.left === "number") levels.push(b.left)
    if (typeof b.right === "number") levels.push(b.right)
    if (!levels.length && typeof root.headset === "number") levels.push(root.headset)
    return levels.length ? Math.min.apply(null, levels) : -1
  }

  readonly property var modes: [
    { value: "off", label: "Normal", glyph: "󱡑" },
    { value: "anc", label: "ANC", glyph: "󱡏" },
    { value: "transparency", label: "Transparent", glyph: "󰟅" }
  ]

  readonly property var switchList: [
    { value: "game", label: "Game mode (low latency)" },
    { value: "movie", label: "Movie mode" },
    { value: "dynamic-eq", label: "Dynamic EQ" },
    { value: "touch-lock", label: "Disable touch" }
  ]

  readonly property var gestureList: [
    { value: "tap-left", label: "Tap left" },
    { value: "tap-right", label: "Tap right" },
    { value: "double-left", label: "Double tap left" },
    { value: "double-right", label: "Double tap right" },
    { value: "triple-left", label: "Triple tap left" },
    { value: "triple-right", label: "Triple tap right" },
    { value: "hold-left", label: "Hold left" },
    { value: "hold-right", label: "Hold right" }
  ]

  readonly property var actionList: [
    { value: "volume-up", label: "Volume up" },
    { value: "volume-down", label: "Volume down" },
    { value: "play-pause", label: "Play / pause" },
    { value: "previous", label: "Previous track" },
    { value: "next", label: "Next track" },
    { value: "anc", label: "Noise control" },
    { value: "game-mode", label: "Game mode" },
    { value: "assistant", label: "Voice assistant" }
  ]

  function modeLabel(value) {
    for (var i = 0; i < modes.length; i++)
      if (modes[i].value === value) return modes[i].label
    return value ? value : "—"
  }

  function modeGlyph(value) {
    for (var i = 0; i < modes.length; i++)
      if (modes[i].value === value) return modes[i].glyph
    return "󱡑"
  }

  function send(line) {
    if (!watch.running) return
    watch.write(line + "\n")
  }

  function setMode(value) {
    if (!control) return
    pendingMode = value
    pendingTimeout.restart()
    send("mode " + value)
  }

  function cycleMode() {
    if (!control) return
    var index = -1
    for (var i = 0; i < modes.length; i++)
      if (modes[i].value === shownMode) index = i
    setMode(modes[(index + 1) % modes.length].value)
  }

  function setSwitch(name, on) {
    if (!control) return
    var next = Object.assign({}, switches)
    next[name] = on
    switches = next
    send(name + (on ? " on" : " off"))
  }

  function setKey(gesture, action) {
    if (!control) return
    var next = Object.assign({}, keys)
    next[gesture] = action
    keys = next
    send("key " + gesture + " " + action)
  }

  function resetKeys() {
    if (control) send("keys reset")
  }

  function setPromptVolume(percent) {
    if (control) send("prompt-volume " + Math.round(percent))
  }

  function applyStatus(text) {
    var data
    try {
      data = JSON.parse(text)
    } catch (error) {
      return
    }
    connected = data.connected === true
    control = connected && data.control === true
    address = connected ? (data.address || "") : ""
    deviceName = connected ? (data.name || "") : ""
    firmware = connected ? (data.firmware || "") : ""
    mode = control && data.mode ? data.mode : ""
    switches = control && data.switches ? data.switches : ({})
    keys = control && data.keys ? data.keys : ({})
    promptVolume = control && typeof data.promptVolume === "number" ? data.promptVolume : null
    battery = connected && data.battery ? data.battery : ({})
    headset = connected && typeof data.headset === "number" ? data.headset : null
    if (pendingMode !== "" && (mode === pendingMode || !control)) {
      pendingMode = ""
      pendingTimeout.stop()
    }
    checkLowBattery()
  }

  function checkLowBattery() {
    var lowest = connected ? lowestBattery : -1
    if (lowest < 0 || lowest > lowBatteryClearPercent) {
      lowBatteryNotified = false
      criticalBatteryNotified = false
      return
    }
    if (lowest <= criticalBatteryPercent && !criticalBatteryNotified) {
      criticalBatteryNotified = true
      lowBatteryNotified = true
      notifyBattery("critical", lowest)
    } else if (lowest <= lowBatteryPercent && !lowBatteryNotified) {
      lowBatteryNotified = true
      notifyBattery("normal", lowest)
    }
  }

  function notifyBattery(urgency, level) {
    var omarchy = Quickshell.env("OMARCHY_PATH") || "/usr/share/omarchy"
    Quickshell.execDetached([
      omarchy + "/bin/omarchy-notification-send",
      "--app-name", "SoundPEATS",
      "-u", urgency,
      "-g", "󱡏",
      "-t", "8000",
      (deviceName || "SoundPEATS") + " battery low",
      level + "% left"
    ])
  }

  Timer {
    id: pendingTimeout
    interval: 4000
    onTriggered: root.pendingMode = ""
  }

  Process {
    id: watch
    command: [root.helperCommand, "watch"]
    running: true
    stdinEnabled: true
    stdout: SplitParser { onRead: function(line) { root.applyStatus(line) } }
    onExited: {
      root.connected = false
      root.control = false
      restart.start()
    }
  }

  Timer {
    id: restart
    interval: 2000
    onTriggered: watch.running = true
  }
}
