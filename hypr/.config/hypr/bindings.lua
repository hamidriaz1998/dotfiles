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

-- ScreenShot
-- hl.unbind("PRINT")
-- hl.unbind("F12")
-- hl.unbind("ALT + SHIFT + 4")
--
-- o.bind("PRINT", "Screenshot", "omasnap")
-- o.bind("F12", "Screenshot", "omasnap")
-- o.bind("ALT + SHIFT + 4", "Screenshot", "omasnap")
--
-- hl.layer_rule({
-- 	match = { namespace = "^omasnap$" },
-- 	no_anim = true,
-- 	animation = "none",
-- })

hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Ghostty", "ghostty +new-window")
o.bind("SUPER + F1", "Toggle Gamemode", "~/.config/hypr/scripts/gamemode.sh")
o.bind("SUPER + H", "(Dis)Connect Soundpeats pods", "~/.config/hypr/scripts/bt-toggle.sh")

-- Lock Screen
hl.unbind("SUPER + L")
hl.unbind("SUPER + CTRL + L")
o.bind("SUPER + L", "Lock Screen", "omarchy-system-lock")
o.bind("SUPER + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Browser
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + ALT + B")
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (Private)", { omarchy = "browser --private" })

-- Cliamp
hl.unbind("SUPER + SHIFT + M")
hl.unbind("SUPER + SHIFT + ALT + M")

-- Scratchpad
hl.unbind("SUPER + S")
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Toggle Scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))

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

-- next-key:start
do
	local home = os.getenv("HOME")
	local path = home and (home .. "/.config/omarchy/plugins/next-key/hypr/shortcut-hints.lua")
	if path then
		local file = io.open(path, "r")
		if file then
			file:close()
			local ok, err = pcall(dofile, path)
			if not ok then
				io.stderr:write("next-key: " .. tostring(err) .. "\n")
			end
		end
	end
end
-- next-key:end

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = "flea --gui" })
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.
