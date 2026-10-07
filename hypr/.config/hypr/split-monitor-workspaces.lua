-- split-monitor-workspaces (Lua package in ~/.config/hypr/plugins, branch release/0.56.x)
-- Port of the old plugin-split-monitor-workspace.conf.
package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

smw.setup({
	workspace_count = 10,
	keep_focused = true,
	enable_persistent_workspaces = false,
	enable_notifications = false,
})

-- Rebind a key, dropping Omarchy's default first.
-- Omarchy binds digits by keycode (code:10 = 1 ... code:19 = 0), so digits must use code: too.
local function rebind(keys, desc, action)
	hl.unbind(keys)
	o.bind(keys, desc, action)
end

-- SUPER + [1..0] = switch workspace on current monitor
-- SUPER + SHIFT + [1..0] = move window to workspace on current monitor
for i = 1, 10 do
	local code = "code:" .. (i + 9)
	local label = tostring(i % 10)
	rebind("SUPER + " .. code, "Switch WS " .. label, smw.workspace(tostring(i)))
	rebind("SUPER + SHIFT + " .. code, "Move win to WS " .. label, smw.move_to_workspace(tostring(i)))
end

-- Cycle workspaces on current monitor
rebind("SUPER + TAB", "Cycle WS next", smw.cycle_workspaces("next"))
rebind("SUPER + SHIFT + TAB", "Cycle WS prev", smw.cycle_workspaces("prev"))

-- Absolute monitor focus / send window to monitor (by ID): SUPER + CTRL (+ SHIFT) + [1..5]
for id = 0, 4 do
	local code = "code:" .. (id + 10)
	rebind("SUPER + CTRL + " .. code, "Focus mon " .. id, hl.dsp.focus({ monitor = tostring(id) }))
	rebind("SUPER + CTRL + SHIFT + " .. code, "Send win to mon " .. id, hl.dsp.window.move({ monitor = tostring(id) }))
end

-- Relative monitor focus / send window left/right
rebind("SUPER + CTRL + LEFT", "Focus monitor left", hl.dsp.focus({ monitor = "l" }))
rebind("SUPER + CTRL + RIGHT", "Focus monitor right", hl.dsp.focus({ monitor = "r" }))
rebind("SUPER + CTRL + SHIFT + LEFT", "Send win to left mon", hl.dsp.window.move({ monitor = "l" }))
rebind("SUPER + CTRL + SHIFT + RIGHT", "Send win to right mon", hl.dsp.window.move({ monitor = "r" }))
