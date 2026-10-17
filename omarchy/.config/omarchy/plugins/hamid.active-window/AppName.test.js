// node AppName.test.js
const fs = require("fs")
const assert = require("assert")
eval(fs.readFileSync(__dirname + "/AppName.js", "utf8").replace(".pragma library", ""))

const cases = {
  "brave-origin": "Brave",
  "brave-browser": "Brave",
  "brave-web.whatsapp.com__-Default": "Whatsapp",
  "chrome-mail.google.com__mail_u_0-Default": "Google",
  "com.mitchellh.ghostty": "Ghostty",
  "org.gnome.Nautilus": "Nautilus",
  "foot": "Foot",
  "": "",
}
for (const [id, want] of Object.entries(cases)) assert.strictEqual(prettyAppName(id), want, id)
assert.strictEqual(prettyAppName("org.gnome.Nautilus", { "org.gnome.Nautilus": "Files" }), "Files")
console.log("ok")
