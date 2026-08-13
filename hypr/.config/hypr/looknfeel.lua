-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Animation presets migrated from looknfeel.conf.
-- Only the macOS-inspired preset below is enabled. The other presets are
-- commented reference configurations; enable one only after disabling this
-- active preset.

-- macOS-inspired animations.
hl.config({
  animations = {
    enabled = true,
  },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOut", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeInOut", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "easeInOut" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "easeInOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "default" })

-- My default: snappy animations.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("snappy", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
-- hl.curve("smooth", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
-- hl.curve("slide", { type = "bezier", points = { { 0.165, 0.84 }, { 0.44, 1 } } })
-- hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "snappy", style = "slide" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshot", style = "popin 85%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "snappy", style = "popin 85%" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "snappy" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smooth" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "smooth" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth", style = "slidefade 20%" })
-- hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "smooth", style = "popin 85%" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "snappy", style = "popin 85%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "overshot", style = "slidefade 15%" })

-- Fast and minimal.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("quick", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "quick" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "quick" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "quick" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "quick" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "quick" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "quick" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "quick", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "quick", style = "slide" })
-- hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 6, bezier = "default" })

-- GNOME-ish.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("gnome", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "gnome" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "gnome", style = "popin 95%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "gnome" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "gnome" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "gnome" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "gnome", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "gnome", style = "slide" })
-- hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 10, bezier = "default" })

-- Bouncy and playful.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("bounce", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "bounce" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "bounce", style = "popin 80%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "bounce" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "bounce" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "bounce" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "bounce", style = "slidefade 25%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "bounce", style = "slidefade 20%" })
-- hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "default" })

-- KDE style.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("plasma", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
-- hl.curve("plasmaFast", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "plasma" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "plasma", style = "popin 93%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "plasmaFast" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "plasma" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "plasma" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "plasma" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "plasmaFast" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "plasma", style = "slidevert" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "plasma", style = "slidevert" })
-- hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 10, bezier = "default" })

-- Floating glass.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("glass", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "glass" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "glass", style = "popin 96%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "glass", style = "popin 98%" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "glass" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "glass" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "glass" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "glass" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "glass", style = "slidefade 10%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "glass", style = "slidefade 10%" })
-- hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "default" })

-- iPadOS.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("ipad", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "ipad" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "ipad", style = "popin 90%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "ipad" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "ipad" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "ipad" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "ipad" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 5, bezier = "ipad" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "ipad", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 7, bezier = "ipad", style = "slide" })
-- hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 10, bezier = "default" })

-- Workspace-centric.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("ws", { type = "bezier", points = { { 0.18, 1 }, { 0.22, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "ws" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "ws" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "ws" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "ws" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "ws" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "ws" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "ws" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "ws", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 8, bezier = "ws", style = "slide" })
-- hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 6, bezier = "default" })

-- Retro CRT.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("retro", { type = "bezier", points = { { 0.55, 0 }, { 0.1, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "retro" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "retro", style = "popin 70%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "retro", style = "popin 70%" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "retro" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "retro" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "retro" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "retro" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "retro", style = "slidefade 40%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "retro", style = "slidefade 40%" })
-- hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })

-- Everything floats.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("floaty", { type = "bezier", points = { { 0.34, 1.4 }, { 0.64, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "floaty" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 7, bezier = "floaty", style = "popin 85%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "floaty" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 8, bezier = "floaty" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "floaty" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "floaty" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 5, bezier = "floaty" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "floaty", style = "slidefade 15%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "floaty", style = "slidefade 15%" })
-- hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "default" })

-- Overdamped physics.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("damped", { type = "bezier", points = { { 0.2, 0.9 }, { 0.3, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "damped" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 7, bezier = "damped", style = "popin 95%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "damped" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 7, bezier = "damped" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "damped" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "damped" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 5, bezier = "damped" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "damped", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 7, bezier = "damped", style = "slide" })
-- hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 12, bezier = "default" })

-- Maximum dopamine.
-- hl.config({ animations = { enabled = true } })
-- hl.curve("insane", { type = "bezier", points = { { 0.34, 1.8 }, { 0.64, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 8, bezier = "insane" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 8, bezier = "insane", style = "popin 65%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "insane", style = "popin 65%" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 8, bezier = "insane" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "insane" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "insane", style = "slidefade 35%" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 8, bezier = "insane", style = "slidefade 35%" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 6, bezier = "insane", style = "popin 70%" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "insane" })
-- hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 16, bezier = "default" })
