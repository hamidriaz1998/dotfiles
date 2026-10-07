// Waybar privacy-module semantics over `pw-dump --monitor --raw` output.
// A node counts when its media.class matches exactly and its state is
// "running"; monitor streams and (type, node.name) ignore pairs are skipped.

var TYPES = {
  "Stream/Input/Video": "screenshare",
  "Stream/Input/Audio": "audio-in",
  "Stream/Output/Audio": "audio-out"
}

// Fold one pw-dump update (an array of objects) into the id -> node map.
// Removals arrive as { id, info: null }; changed objects are re-dumped, but
// keep earlier props in case an update only carries a state change.
function applyUpdate(nodes, objects) {
  var next = {}
  for (var key in nodes) next[key] = nodes[key]
  for (var i = 0; i < objects.length; i++) {
    var o = objects[i]
    if (!o || o.id === undefined) continue
    if (o.info === null) { delete next[o.id]; continue }
    if (o.type !== "PipeWire:Interface:Node" || !o.info) continue

    var prev = next[o.id] || {}
    var props = o.info.props
    next[o.id] = {
      mediaClass: props ? String(props["media.class"] || "") : prev.mediaClass,
      nodeName: props ? String(props["node.name"] || "") : prev.nodeName,
      appName: props ? String(props["application.name"] || "") : prev.appName,
      monitor: props ? props["stream.monitor"] === true || props["stream.monitor"] === "true" : prev.monitor,
      state: o.info.state !== undefined ? String(o.info.state) : prev.state
    }
  }
  return next
}

// { screenshare: [names], "audio-in": [...], "audio-out": [...] }
function activeApps(nodes, config) {
  var ignore = config.ignore || []
  var result = { "screenshare": [], "audio-in": [], "audio-out": [] }
  for (var id in nodes) {
    var n = nodes[id]
    var type = TYPES[n.mediaClass]
    if (!type || n.state !== "running") continue
    if (config.ignoreMonitor !== false && n.monitor) continue

    var ignored = false
    for (var i = 0; i < ignore.length; i++)
      if (ignore[i] && ignore[i].type === type && ignore[i].name === n.nodeName) ignored = true
    if (ignored) continue

    var name = n.appName || n.nodeName || "Unknown Application"
    name = name.charAt(0).toUpperCase() + name.slice(1)
    if (result[type].indexOf(name) < 0) result[type].push(name)
  }
  return result
}

if (typeof module !== "undefined") module.exports = { applyUpdate: applyUpdate, activeApps: activeApps }
