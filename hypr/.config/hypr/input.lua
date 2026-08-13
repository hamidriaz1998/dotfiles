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

--------------------------------------------------------------------
-- Vertical swipe -> volume / brightness
--------------------------------------------------------------------

local function make_axis(cfg)
	local a = {
		px_per_step = cfg.px_per_step,
		deadzone = cfg.deadzone or 12,
		max_steps = cfg.max_steps or 100,
		apply = cfg.apply,
		pos = 0,
		applied = 0,
	}

	function a:reset()
		self.pos, self.applied = 0, 0
	end

	function a:update(dy)
		-- e.delta.y is the per-event increment; y grows downward,
		-- so swiping up must raise the value
		self.pos = self.pos - (dy or 0)

		local eff = 0
		if self.pos > self.deadzone then
			eff = self.pos - self.deadzone
		elseif self.pos < -self.deadzone then
			eff = self.pos + self.deadzone
		end

		local target = math.floor(eff / self.px_per_step + 0.5)
		if target > self.max_steps then
			target = self.max_steps
		elseif target < -self.max_steps then
			target = -self.max_steps
		end

		local step = target - self.applied
		if step ~= 0 then
			self.applied = target
			self.apply(step) -- one command carrying the whole delta
		end
	end

	return a
end

local volume = make_axis({
	px_per_step = 8,
	apply = function(step)
		hl.exec_cmd("omarchy-audio-output-volume " .. (step > 0 and ("+" .. step) or tostring(step)))
	end,
})

local brightness = make_axis({
	px_per_step = 10,
	apply = function(step)
		local cmd = step > 0 and ("+" .. step .. "%") or (math.abs(step) .. "%-")
		hl.exec_cmd("omarchy-brightness-display " .. cmd)
	end,
})

local function bind(fingers, axis)
	hl.gesture({
		fingers = fingers,
		direction = "vertical",
		action = {
			start = function(e)
				axis:reset()
				axis:update(e.delta and e.delta.y)
			end,
			update = function(e)
				axis:update(e.delta and e.delta.y)
			end,
		},
	})
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

-- bind(3, volume)

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

-- bind(4, brightness)

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
