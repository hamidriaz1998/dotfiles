-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Ghostty", "ghostty +new-window")
o.bind("SUPER + F1", "Toggle Gamemode", "~/.config/hypr/scripts/gamemode.sh")
o.bind("SUPER + H", "(Dis)Connect Soundpeats pods", "~/.config/hypr/scripts/bt-toggle.sh")

-- Zoom
local function zoom_in()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom * 1.1 } })
end

local function zoom_out()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = math.max(zoom * 0.9, 1) } })
end

local function zoom_reset()
  hl.config({ cursor = { zoom_factor = 1 } })
end

o.bind("SUPER + mouse_down", "Zoom in", zoom_in)
o.bind("SUPER + mouse_up", "Zoom out", zoom_out)

o.bind("SUPER + ALT + equal", "Zoom in", zoom_in, { repeating = true })
o.bind("SUPER + ALT + minus", "Zoom out", zoom_out, { repeating = true })
o.bind("SUPER + KP_ADD", "Zoom in", zoom_in, { repeating = true })
o.bind("SUPER + KP_SUBTRACT", "Zoom out", zoom_out, { repeating = true })

o.bind("SUPER + SHIFT + mouse_up", "Reset zoom", zoom_reset)
o.bind("SUPER + SHIFT + mouse_down", "Reset zoom", zoom_reset)
o.bind("SUPER + SHIFT + minus", "Reset zoom", zoom_reset)
o.bind("SUPER + SHIFT + KP_SUBTRACT", "Reset zoom", zoom_reset)
