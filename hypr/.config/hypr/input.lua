-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
	input = {
		-- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
		-- kb_layout = "us,dk,eu",
		-- kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",

		-- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
		-- kb_variant = "intl",

		-- Change speed of keyboard repeat.
		-- repeat_rate = 40,
		-- repeat_delay = 250,

		-- Start with numlock on by default.
		numlock_by_default = true,

		-- Increase sensitivity for mouse/trackpad (default: 0).
		-- sensitivity = 0.35,

		-- Turn off mouse acceleration (default: adaptive).
		-- accel_profile = "flat",

		touchpad = {
			-- Use natural (inverse) scrolling.
			natural_scroll = true,

			-- Use two-finger clicks for right-click instead of lower-right corner.
			clickfinger_behavior = true,

			-- Control the speed of your scrolling.
			scroll_factor = 0.4,

			-- Enable the touchpad while typing.
			disable_while_typing = false,

			-- Left-click-and-drag with three fingers.
			-- drag_3fg = 1,
		},
	},
})
hl.device({
	name = "logitech-usb-ps/2-optical-mouse",
	sensitivity = 1,
})

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local gesture_senstivity = 0.5
local volume_remainder = 0
local function adjust_volume(delta_y)
	volume_remainder = volume_remainder - gesture_senstivity * delta_y
	local step = volume_remainder >= 0 and math.floor(volume_remainder) or math.ceil(volume_remainder)
	if step ~= 0 then
		volume_remainder = volume_remainder - step
		hl.exec_cmd("omarchy-audio-output-volume " .. (step > 0 and "+" or "") .. step)
	end
end

local brightness_remainder = 0
local function adjust_brightness(delta_y)
	brightness_remainder = brightness_remainder - gesture_senstivity * delta_y
	local step = brightness_remainder >= 0 and math.floor(brightness_remainder) or math.ceil(brightness_remainder)
	if step ~= 0 then
		brightness_remainder = brightness_remainder - step
		local command = step > 0 and ("+" .. step .. "%") or (math.abs(step) .. "%-")
		hl.exec_cmd("omarchy-brightness-display " .. command)
	end
end

local function focus_monitor(direction)
	hl.dispatch(hl.dsp.focus({ monitor = direction }))
end

local function move_window_to_monitor(direction)
	hl.dispatch(hl.dsp.window.move({ monitor = direction }))
end

local function move_window_to_workspace(workspace)
	hl.dispatch(hl.dsp.window.move({ workspace = workspace }))
end

-- Adjust volume with three-finger vertical swipes.
hl.gesture({
	fingers = 3,
	direction = "vertical",
	action = {
		start = function(e)
			volume_remainder = 0
			adjust_volume(e.delta.y)
		end,
		update = function(e)
			adjust_volume(e.delta.y)
		end,
		finish = function()
			volume_remainder = 0
		end,
	},
})

-- Focus another monitor while holding Super.
hl.gesture({
	fingers = 3,
	direction = "left",
	mods = "SUPER",
	action = function()
		focus_monitor("+1")
	end,
})
hl.gesture({
	fingers = 3,
	direction = "right",
	mods = "SUPER",
	action = function()
		focus_monitor("-1")
	end,
})

-- Move the active window to another monitor while holding Super.
hl.gesture({
	fingers = 4,
	direction = "left",
	mods = "SUPER",
	action = function()
		move_window_to_monitor("r")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "right",
	mods = "SUPER",
	action = function()
		move_window_to_monitor("l")
	end,
})

-- Move the active window with four-finger horizontal swipes.
hl.gesture({
	fingers = 4,
	direction = "left",
	action = function()
		move_window_to_workspace("+1")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "right",
	action = function()
		move_window_to_workspace("-1")
	end,
})

-- Adjust display brightness with four-finger vertical swipes.
hl.gesture({
	fingers = 4,
	direction = "vertical",
	action = {
		start = function(e)
			brightness_remainder = 0
			adjust_brightness(e.delta.y)
		end,
		update = function(e)
			adjust_brightness(e.delta.y)
		end,
		finish = function()
			brightness_remainder = 0
		end,
	},
})

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
