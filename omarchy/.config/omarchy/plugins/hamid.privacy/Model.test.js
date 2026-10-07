// Run: node Model.test.js
const assert = require("assert")
const { applyUpdate, activeApps } = require("./Model.js")

const node = (id, cls, name, app, state, extra) => ({
  id, type: "PipeWire:Interface:Node",
  info: { state, props: Object.assign({ "media.class": cls, "node.name": name, "application.name": app }, extra || {}) }
})
const cfg = { ignoreMonitor: true, ignore: [{ type: "audio-in", name: "cava" }, { type: "screenshare", name: "obs" }] }

let nodes = applyUpdate({}, [
  node(1, "Stream/Output/Audio", "spotify", "spotify", "running"),
  node(2, "Stream/Input/Audio", "cava", "cava", "running"),                         // ignored by name
  node(3, "Stream/Input/Audio", "firefox", "Firefox", "idle"),                      // not running
  node(4, "Stream/Input/Audio/Internal", "bluez_capture", "", "running"),           // class not exact
  node(5, "Stream/Input/Audio", "pavucontrol", "pavucontrol", "running", { "stream.monitor": "true" }), // monitor
  node(6, "Stream/Input/Video", "xdph", "", "running"),                             // falls back to node.name
  { id: 7, type: "PipeWire:Interface:Client", info: { props: {} } }                 // not a node
])
assert.deepStrictEqual(activeApps(nodes, cfg), { "screenshare": ["Xdph"], "audio-in": [], "audio-out": ["Spotify"] })

// State-only update keeps props; removal drops the node.
nodes = applyUpdate(nodes, [{ id: 3, type: "PipeWire:Interface:Node", info: { state: "running" } }, { id: 1, info: null }])
assert.deepStrictEqual(activeApps(nodes, cfg), { "screenshare": ["Xdph"], "audio-in": ["Firefox"], "audio-out": [] })

// ignoreMonitor: false lets monitor streams through.
assert.deepStrictEqual(activeApps(nodes, { ignoreMonitor: false, ignore: [] })["audio-in"].sort(), ["Cava", "Firefox", "Pavucontrol"])
console.log("ok")
