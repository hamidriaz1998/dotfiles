.pragma library

// Turn a Wayland appId into a short app name for the bar.
//   brave-origin                      -> Brave
//   brave-web.whatsapp.com__-Default  -> Whatsapp   (Chromium web app)
//   com.mitchellh.ghostty             -> Ghostty
//   foot                              -> Foot
function prettyAppName(appId, names) {
  var id = String(appId || "")
  if (!id) return ""
  if (names && names[id]) return String(names[id])

  var webApp = id.match(/^(?:brave|chrome|chromium|google-chrome|msedge)-(.+?)__/)
  var name
  if (webApp) {
    var labels = webApp[1].split(".")
    name = labels.length > 1 ? labels[labels.length - 2] : labels[0]
  } else {
    if (/^(com|org|io|dev|net|app)\./.test(id)) id = id.split(".").pop()
    name = id.split("-")[0]
  }
  return name.charAt(0).toUpperCase() + name.slice(1)
}
