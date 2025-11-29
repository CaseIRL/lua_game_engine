# Engine API Cheatsheet

Quick reference for the framework, refer back to this for help. 
Engine modules are loaded into game files through sandbox.
They all have access to any modules enabled within the `config.lua`

# Actions

Allows for mapping input controls.

```lua
engine.actions.map_action(name, bindings)      -- Map an action name to key/mouse bindings
engine.actions.is_action_pressed(name)         -- Returns true on the frame the action is pressed
engine.actions.is_action_down(name)            -- Returns true while the action is held down
engine.actions.is_action_released(name)        -- Returns true on the frame the action is released
engine.actions.hold_time(name)                 -- Returns how long the action has been held (seconds)
engine.actions.clear_actions()                 -- Remove all mapped actions

```

**Binding formats:**
- Keyboard: `"a"`, `"space"`, `"arrowup"`, etc. (same as keyboard module)
- Mouse: `{ mouse_button = 0 }` (0=left, 1=right, 2=middle)
- Multiple bindings: `{"a", "arrowleft", { mouse_button = 0 }}`

# Audio
```lua
engine.audio.load_sound(key, path)              -- Load sound effect from file
engine.audio.load_music(key, path)              -- Load music from file
engine.audio.play_sound(key)                    -- Play sound effect
engine.audio.play_music(key, loop?)             -- Play music (loop defaults to false)
engine.audio.stop_music()                       -- Stop current music
engine.audio.pause_music()                      -- Pause current music
engine.audio.resume_music()                     -- Resume paused music
engine.audio.set_sound_volume(key, volume)      -- Set sound volume (0.0-1.0)
engine.audio.set_sound_pitch(key, pitch)        -- Set sound pitch (1.0 = normal, 0.5 = half speed, 2.0 = double)
engine.audio.set_music_volume(key, volume)      -- Set music volume (0.0-1.0)
engine.audio.set_music_pitch(key, pitch)        -- Set music pitch (1.0 = normal)
engine.audio.is_music_playing()                 -- Returns: true if music playing
engine.audio.unload_sound(key)                  -- Unload sound effect
engine.audio.unload_music(key)                  -- Unload music
engine.audio.cleanup()                          -- Clean up all audio resources
```

**Audio support:** WAV, OGG (MP3 support depends on Raylib build)
**Volume range:** 0.0 (silent) to 1.0 (full volume)
**Pitch range:** 0.5 (half speed) to 2.0+ (variable speed)

# Collision
```lua
engine.collision.point_in_rect({ point, rect })                    -- Is point inside rectangle?
engine.collision.point_in_circle({ point, center, radius })       -- Is point inside circle?
engine.collision.rects_overlap({ rect1, rect2 })                  -- Do two rectangles overlap?
engine.collision.circles_overlap({ c1_center, c1_radius, c2_center, c2_radius }) -- Do two circles overlap?
engine.collision.distance_between({ p1, p2 })                     -- Distance between two points
```

**Point format:** `{ x, y }`
**Rect format:** `{ x, y, width, height }`
**Circle format:** center `{ x, y }` and `radius`

# Drawing

You can use `colour` or `color`; just bugs me having to remember both since English.
```lua
engine.draw.clear({ colour? })                                                          -- Clear screen to colour
engine.draw.line({ x1, y1, x2, y2, colour? })                                           -- Draw line
engine.draw.rect({ x, y, w, h, colour?, roundness?, segments? })                        -- Draw filled rectangle (now supports roundness)
engine.draw.rect_lines({ x, y, w, h, colour?, roundness?, segments?, line_thick? })     -- Draw rectangle outline (now supports roundness)
engine.draw.circle({ x, y, radius?, colour? })                                          -- Draw filled circle
engine.draw.circle_lines({ x, y, radius?, colour? })                                    -- Draw circle outline
engine.draw.triangle({ x1, y1, x2, y2, x3, y3, colour? })                               -- Draw filled triangle
engine.draw.triangle_lines({ x1, y1, x2, y2, x3, y3, colour? })                         -- Draw triangle outline
engine.draw.ellipse({ x, y, rx?, ry?, colour? })                                        -- Draw filled ellipse
engine.draw.polygon({ x, y, sides?, radius?, rotation?, colour? })                      -- Draw regular polygon
engine.draw.text({ text, x, y, size?, colour? })                                        -- Draw text
```

**Colour format:** `{ R, G, B, A }` array (0-255)
**Colour defaults:** `{ 255, 255, 255, 255 }` (white)
**Other defaults:** radius=10, size=16, sides=6, rotation=0, rx=20, ry=20

# Filesystem
```lua
engine.filesystem.exists(path)              -- Returns: true if a file or directory exists in save/
engine.filesystem.create_directory(path)    -- Create a directory inside save/ (auto-creates nested dirs)
engine.filesystem.serialize(table)          -- Returns: Lua-formatted string of a serialized table
engine.filesystem.save(path, data)          -- Save a Lua table to save/path as a .lua file
engine.filesystem.load(path)                -- Returns: loaded table from save/path or nil, error
engine.filesystem.delete(path)              -- Delete a file inside save/ directory
```

# Images
```lua
engine.image.load({ type, key, path, frame_width?, frame_height?, animations? })                -- Load image or sprite
engine.image.draw({ key, x, y, scale?, tint? })                                                 -- Draw image
engine.image.draw_sprite({ key, anim, frame, x, y, scale? })                                    -- Draw sprite with animation
engine.image.draw_frame({ key, x, y, frame_width, frame_height, frame_x, frame_y, scale? })     -- Draw specific frame
engine.image.unload(key)                                                                        -- Unload image
engine.image.cleanup()                                                                          -- Unload all images
```

Image load options:
- type: "image" or "sprite"
- key: Unique identifier
- path: File path to image/spritesheet
- animations: Table of { name = { x, y, frames }, ... } for sprites

**Draw defaults:** scale = 1.0, tint = white (optional)

# Inputs

## Keyboard
```lua
engine.keyboard.is_down(key)           -- Key held down
engine.keyboard.is_pressed(key)        -- Key pressed this frame
```

## Mouse
```lua
engine.mouse.is_down(button)           -- Mouse button held (0=left, 1=right, 2=middle)
engine.mouse.is_pressed(button)        -- Mouse button pressed this frame
engine.mouse.get_pos()                 -- Returns: x, y
engine.mouse.get_delta()               -- Returns: dx, dy
engine.mouse.set_pos(x, y)             -- Set cursor position
engine.mouse.show()                    -- Show cursor
engine.mouse.hide()                    -- Hide cursor
engine.mouse.lock()                    -- Disable cursor movement
engine.mouse.unlock()                  -- Enable cursor movement
```

**Key names:** `a-z`, `0-9`, `space`, `enter`, `escape`, `tab`, `arrowup`, `arrowdown`, `arrowleft`, `arrowright`, `shift`, `ctrl`, `alt`, `f1-f12`, etc.
**Mouse buttons:** `0` = left, `1` = right, `2` = middle

# UI

## Style
```lua
engine.ui.style.set_theme(name)            -- Set the active theme by name
engine.ui.style.get_theme()                -- Returns: current active theme table
engine.ui.style.get(key)                   -- Returns: specific style value from current theme
```

**Available themes:** `default`

**Style properties:**
- Fonts: `header_font`, `text_font`
- Border radius: `border_radius_outer`, `border_radius_inner`, `border_radius_small`
- Backgrounds: `bg_main`, `bg_panel`, `bg_hover`, `bg_overlay`
- Text colours: `text_primary`, `text_secondary`, `text_tertiary`
- Accents: `accent`, `accent2`, `accent3`, `accent4`
- Borders: `border_dark`, `border_light`, `border_accent`, `border_dashed`, `border_transparent`
- Shadows: `shadow_soft`, `shadow_medium`, `shadow_large`
- Text shadows: `text_shadow_hard`
- Scrollbars: `scrollbar_track`, `scrollbar_thumb`

**Border/Shadow format:** `{ colour = {R, G, B, A}, thickness = N }` or `{ offset_x, offset_y, blur, {R, G, B, A} }`

## Button
```lua
local btn = engine.ui.button.new({ x, y, w, h, text?, on_click?, roundness?, segments? })   -- Create button instance (now supports roundness)
btn:update(mouse_x, mouse_y, mouse_pressed)                                                 -- Update button state each frame
btn:draw()                                                                                  -- Draw button
btn:is_hovered(mouse_x, mouse_y)                                                            -- Returns: true if mouse over button
```

**Button properties:**
- `x, y, w, h` - Position and size
- `text` - Button label text
- `on_click` - Callback function when clicked
- `roundness`, `segments` - Determines if the button is drawn with rounded corners
- `hovered` - Current hover state (read-only)
- `active` - Currently pressed state (read-only)
- `enabled` - Whether button responds to input (can be set)

**Button defaults:** w=100, h=40, text="", on_click=nil, roundness=nil

# Scenes
```lua
engine.scene.set_scenes(table)     -- Register scenes from config
engine.scene.switch(name)          -- Switch to scene by name
engine.scene.update(dt)            -- Update current scene (called by engine)
engine.scene.draw()                -- Draw current scene (called by engine)
```

**Scene structure:**
```lua
local scene = {}

function scene:load() end              -- Called when scene starts
function scene:update(dt) end          -- Called each frame
function scene:draw() end              -- Called each frame
function scene:unload() end            -- Called when switching away

return scene
```

# Mods & Hooks

The mod system allows you to create hook-based extensions that listen to game events.
You can use these functions to register, fire, and listen to events between game code and mods.
*(mod file structure will change, for now its a test)*

```lua
engine.hooks.register(name, description)        -- Register a new hook type (e.g., "player_damage")
engine.hooks.listen(name, callback)             -- Add a function to execute when a hook fires
engine.hooks.fire(name, data)                   -- Trigger the hook, running all listening functions
engine.hooks.unlisten(name, callback)           -- Remove a specific function listener
engine.hooks.clear(name)                        -- Remove all listeners for a specific hook
engine.hooks.clear_all()                        -- Remove all listeners from all hooks
engine.hooks.list()                             -- Get a list of all registered hook names
```

# Window
```lua
engine.window.get_size()                            -- Returns: width, height
engine.window.get_dt()                              -- Returns: delta time (seconds)
engine.window.get_fps()                             -- Returns: current FPS
engine.window.draw_fps(x, y)                        -- Draw FPS counter on screen
engine.window.toggle_fullscreen()                   -- Toggle fullscreen
engine.window.get_position()                        -- Returns: x, y screen position of the window
engine.window.set_position(x, y)                    -- Move window to screen position (x, y)
engine.window.minimize()                            -- Minimize the window
engine.window.toggle_flag(flag_name, enabled)       -- Enable/disable a specific window flag (e.g. "resizable", "topmost")
engine.window.set_borderless(enabled)               -- Enable/disable borderless windowed mode
engine.window.set_topmost(enabled)                  -- Enable/disable always-on-top mode
engine.window.set_resizable(enabled)                -- Enable/disable window resizing
engine.window.set_decorated(enabled)                -- Enable/disable window decorations (title bar / borders)
engine.window.is_flag_enabled(flag_name)            -- Returns: true if the given window flag is active
```

# Networking

TCP/UDP networking; setup a simple server relay and connect, send, receive.

```lua
engine.network.connect(ip, port)                -- Returns object containing tcp and udp sockets
engine.network.send(conn, msg, force_udp)       -- Returns true if the message was sent
engine.network.receive(conn, size)              -- Returns table with tcp and udp arrays containing received messages
engine.network.close(conn)                      -- Connection object
engine.network.cleanup()                        -- Clean up winsock resources
```

---

# Maths

Mathematics library for games: core math, easing, geometry, matrices, probability, statistics, and vectors.

## Core Math
```lua
engine.math.round(number, decimals)           -- Round number to N decimal places
engine.math.clamp(value, min, max)            -- Clamp value between min and max
engine.math.lerp(a, b, t)                     -- Linear interpolation (t: 0.0-1.0)
engine.math.deg_to_rad(degrees)               -- Convert degrees to radians
engine.math.rad_to_deg(radians)               -- Convert radians to degrees
engine.math.factorial(n)                      -- Calculate factorial of n
```

## Easing Functions

Commonly used animation easing curves. Parameter `t` should be 0.0-1.0.

```lua
engine.math.linear(t)                         -- Linear (no curve)
engine.math.in_quad(t)                        -- Quadratic ease-in
engine.math.out_quad(t)                       -- Quadratic ease-out
engine.math.in_out_quad(t)                    -- Quadratic ease-in-out
engine.math.in_cubic(t)                       -- Cubic ease-in
engine.math.out_cubic(t)                      -- Cubic ease-out
engine.math.in_out_cubic(t)                   -- Cubic ease-in-out
engine.math.out_elastic(t)                    -- Elastic ease-out
```

## Geometry 2D
```lua
engine.math.distance_2d(p1, p2)                                                -- Distance between two 2D points
engine.math.angle_between_points(p1, p2)                                       -- Angle between two points (degrees)
engine.math.circle_circumference(radius)                                       -- Circumference of circle
engine.math.circle_area(radius)                                                -- Area of circle
engine.math.triangle_area(p1, p2, p3)                                          -- Area of triangle from 3 vertices
engine.math.is_point_in_rect(point, rect)                                      -- Is point inside rectangle?
engine.math.is_point_in_circle(point, center, radius)                          -- Is point inside circle?
engine.math.is_point_on_line_segment(point, start, end_point, tolerance?)      -- Is point on line segment?
engine.math.do_circles_intersect(c1, r1, c2, r2)                               -- Do two circles intersect?
engine.math.do_lines_intersect(l1_start, l1_end, l2_start, l2_end)             -- Do two lines intersect?
engine.math.line_intersects_circle(start, end_point, center, radius)           -- Does line intersect circle?
engine.math.does_rect_intersect_line(rect, start, end_point)                   -- Does rectangle intersect line?
engine.math.closest_point_on_line_segment(point, start, end_point)             -- Closest point on line to point
engine.math.project_point_on_line(point, start, end_point)                     -- Project point onto line
engine.math.calculate_slope(p1, p2)                                            -- Slope of line (nil if vertical)
engine.math.is_point_in_convex_polygon(point, polygon)                         -- Is point in convex polygon?
engine.math.rotate_point_around_point_2d(point, pivot, degrees)                -- Rotate point around pivot
```

**Format notes:**
- `point` = `{ x, y }`
- `rect` = `{ x, y, width, height }`
- `polygon` = `[{ x, y }, { x, y }, ...]`

## Geometry 3D
```lua
engine.math.distance_3d(p1, p2)                                            -- Distance between two 3D points
engine.math.midpoint(p1, p2)                                               -- Midpoint between two 3D points
engine.math.angle_between_3_points(p1, p2, p3)                             -- Angle at p2 between p1 and p3 (degrees)
engine.math.triangle_area_3d(p1, p2, p3)                                   -- Area of triangle in 3D space
engine.math.is_point_in_box(point, box)                                    -- Is point inside 3D box?
engine.math.is_point_in_sphere(point, center, radius)                      -- Is point inside sphere?
engine.math.do_spheres_intersect(c1, r1, c2, r2)                           -- Do two spheres intersect?
engine.math.distance_point_to_plane(point, plane_point, plane_normal)      -- Distance to plane
```

**Format notes:**
- `point` = `{ x, y, z }`
- `box` = `{ x, y, z, width, height, depth }`
- `plane_normal` must be normalized

## Matrix 4x4 (Transformations)
```lua
-- Constructors
engine.math.mat4.translate(x, y, z)                                    -- Translation matrix
engine.math.mat4.rotate_euler(rx, ry, rz)                              -- Rotation from Euler angles (degrees)
engine.math.mat4.rotate_axis(axis, angle)                              -- Rotation around axis (angle in degrees)
engine.math.mat4.scale(sx, sy, sz)                                     -- Scale matrix
engine.math.mat4.perspective(fov, aspect, near, far)                   -- Perspective projection
engine.math.mat4.orthographic(left, right, bottom, top, near, far)     -- Orthographic projection
engine.math.mat4.look_at(eye, target, up)                              -- Look-at matrix (camera)

-- Methods
local result = matrix1:multiply(matrix2)        -- Multiply with another matrix
local result = matrix1 * matrix2                -- Multiply (using * operator)
local vector = matrix:multiply_vec3(vec)        -- Transform 3D vector
local transposed = matrix:transpose()           -- Transpose matrix
local inverted = matrix:invert()                -- Invert matrix (returns nil if singular)
local pos = matrix:get_translation()            -- Extract translation from matrix
local scale = matrix:get_scale()                -- Extract scale from matrix
```

**Format notes:**
- `axis` = `{ x, y, z }` (should be normalized)
- Returns `nil` on operations that fail (e.g., inverting singular matrices)

## Probability & Random
```lua
engine.math.set_seed(seed)                    -- Set random seed for reproducibility
engine.math.random_between(min, max)          -- Random float in range
engine.math.random_int(min, max)              -- Random integer (inclusive)
engine.math.chance(probability)               -- True if event with probability (0.0-1.0) occurs
engine.math.percent_chance(percentage)        -- True if event with percentage (0-100) occurs
engine.math.random_choice(table)              -- Pick random element from table
engine.math.weighted_choice(table)            -- Pick element from {option=weight} table
engine.math.shuffle(table)                    -- Shuffle table in-place (Fisher-Yates)
engine.math.random_normal(mean?, stddev?)     -- Random from normal distribution
engine.math.random_exponential(lambda)        -- Random from exponential distribution
engine.math.random_uniform(min, max)          -- Random from uniform distribution
```

## Statistics
```lua
engine.math.mean(numbers)                                  -- Average of numbers
engine.math.median(numbers)                                -- Middle value of numbers
engine.math.mode(numbers)                                  -- Most common value (nil if no clear mode)
engine.math.variance(numbers, population?)                 -- Variance (sample by default)
engine.math.standard_deviation(numbers, population?)       -- Standard deviation
engine.math.range(numbers)                                 -- Max - Min
engine.math.min(numbers)                                   -- Minimum value
engine.math.max(numbers)                                   -- Maximum value
engine.math.sum(numbers)                                   -- Sum of all values
engine.math.quantile(numbers, q)                           -- Quantile at position q (0.0-1.0)
engine.math.linear_regression(points)                      -- Linear regression, returns {slope, intercept, r_squared}
engine.math.correlation(x, y)                              -- Pearson correlation (-1 to 1)
engine.math.covariance(x, y, population?)                  -- Covariance between datasets
```

**Format notes:**
- `numbers` = `[1, 2, 3, ...]` array
- `points` = `[{x=1, y=2}, {x=3, y=4}, ...]` for regression

## Vector 3D
```lua
-- Constructors
local v = engine.math.vec3(x, y, z)           -- Create vector
local v = engine.math.vec3()                  -- Create zero vector (0, 0, 0)

-- Methods (can use operators)
local v3 = v1:add(v2)                          -- Add vectors (or v1 + v2)
local v3 = v1:sub(v2)                          -- Subtract vectors (or v1 - v2)
local v3 = v1:scale(scalar)                    -- Scale vector (or v1 * scalar)
local v3 = v1 * 2                              -- Scale using * operator
local v3 = v1 / 2                              -- Divide by scalar
local dot = v1:dot(v2)                         -- Dot product
local v3 = v1:cross(v2)                        -- Cross product
local length = v1:length()                     -- Magnitude
local length_sq = v1:length_squared()          -- Magnitude squared (faster)
local v2 = v1:normalize()                      -- Unit vector
local is_zero = v1:is_zero()                   -- Is vector effectively zero?
local distance = v1:distance(v2)               -- Distance to another vector
local distance_sq = v1:distance_squared(v2)    -- Squared distance (faster)
local v3 = v1:lerp(v2, t)                      -- Linear interpolation (0.0-1.0)
local str = tostring(v1)                       -- Vector formatted as "vec3(x, y, z)"
```

---

# Runtime 

Game runtime tools for managing state, events, timers, cooldowns, and deterministic randomness.

## Timers

Schedule delayed and repeating functions.

```lua
local id = engine.runtime.timers.set_timer(delay, callback)                 -- Run callback once after delay (seconds)
local id = engine.runtime.timers.repeat_timer(interval, callback, count)    -- Repeat callback every interval, N times (-1 = infinite)
engine.runtime.timers.cancel_timer(id)                                      -- Cancel timer by ID
engine.runtime.timers.clear_all_timers()                                    -- Cancel all active timers
engine.runtime.timers.update_timer(dt)                                      -- Update timers (call once per frame)
```

**Usage in scene:**
```lua
function scene:update(dt)
    engine.runtime.timers.update_timer(dt)
    -- ... rest of update
end
```

## Cooldowns

Track cooldowns for abilities, actions, or any time-based restrictions.

```lua
engine.runtime.cooldowns.add_cooldown(id, type, duration)                       -- Start cooldown (duration in seconds)
local is_active = engine.runtime.cooldowns.check_cooldown(id, type)             -- Is cooldown still active?
local remaining = engine.runtime.cooldowns.cooldown_time_remaining(id, type)    -- Seconds left (0 if expired)
engine.runtime.cooldowns.clear_cooldown(id, type)                               -- Manually clear specific cooldown
engine.runtime.cooldowns.clear_all_cooldowns(id)                                -- Clear all cooldowns for an id
engine.runtime.cooldowns.clear_expired_cooldowns()                              -- Cleanup expired (call periodically)
```

## State Manager

Named state scopes with persistent key-value storage.

```lua
engine.runtime.state.use_state(name)           -- Switch to named state (creates if missing)
engine.runtime.state.current_state()           -- Returns current state name
engine.runtime.state.set_state(key, value, scope?) -- Set value in state
engine.runtime.state.get_state(key, fallback?, scope?) -- Get value from state
engine.runtime.state.clear_state(key, scope?)  -- Delete single key from state
engine.runtime.state.clear_all(scope?)         -- Clear all keys from state
engine.runtime.state.dump_state(scope?)        -- Returns entire state table
engine.runtime.state.delete_state(name)        -- Delete entire named state
engine.runtime.state.list_states()             -- Returns array of all state names
engine.runtime.state.with_state(scope, fn)     -- Run function in another state scope temporarily
engine.runtime.state.data                      -- Direct proxy access: state.data.key = value
```

## Callbacks

Lightweight event/callback registration system.

```lua
engine.runtime.callbacks.register_callback(name, fn, overwrite?) -- Register callback
engine.runtime.callbacks.trigger_callback(name, ...)  -- Call callback with args, returns result or nil
engine.runtime.callbacks.unregister_callback(name)    -- Remove callback
engine.runtime.callbacks.callback_exists(name)        -- Does callback exist?
engine.runtime.callbacks.get_each_callback()          -- Iterate callbacks (returns iterator)
```

## RNG (Deterministic Random)

Deterministic random number generator using Linear Congruential Generator. Useful for replays and seeded gameplay.

```lua
engine.runtime.rng.set_rng_seed(seed)          -- Set RNG seed for reproducibility
engine.runtime.rng.get_rng_seed()              -- Get current seed
engine.runtime.rng.random_rng()                -- Random float 0.0-1.0
engine.runtime.rng.get_rng_state()             -- Get internal RNG state (for snapshots)
engine.runtime.rng.set_rng_state(state)        -- Restore RNG to previous state
```

---

# Logging

Colour coded logger with history buffer and level filtering.

```lua
engine.log.debug(msg, data?)                   -- Log debug message
engine.log.info(msg, data?)                    -- Log info message
engine.log.success(msg, data?)                 -- Log success message (green)
engine.log.warn(msg, data?)                    -- Log warning message (yellow)
engine.log.error(msg, data?)                   -- Log error message (red)
engine.log.fatal(msg, data?)                   -- Log fatal error and exit
engine.log.print(level, msg, data?)            -- Log with explicit level
engine.log.set_level(level)                    -- Set minimum log level to show
engine.log.use_colour(enabled?)                -- Force colors on/off (nil = auto-detect)
engine.log.get_history()                       -- Returns array of all logged messages
```

**Log levels:** `"debug"`, `"info"`, `"success"`, `"warn"`, `"error"`, `"fatal"`

---

# Strings

Text manipulation utilities beyond standard Lua string functions.

```lua
engine.string.capitalize(str)                           -- Title case each word
engine.string.split(str, delimiter)                     -- Split into array by delimiter
engine.string.trim(str)                                 -- Remove leading/trailing whitespace
engine.string.random_string(length)                     -- Generate random alphanumeric string
engine.string.starts_with(str, prefix)                  -- Check if string starts with prefix
engine.string.ends_with(str, suffix)                    -- Check if string ends with suffix
engine.string.replace(str, old, new)                    -- Replace first occurrence
engine.string.replace_all(str, old, new)                -- Replace all occurrences
engine.string.reverse(str)                              -- Reverse string
engine.string.repeat_string(str, count)                 -- Repeat string N times
engine.string.truncate(str, max_length, suffix?)        -- Shorten with suffix (default: "...")
engine.string.is_empty(str)                             -- Is string empty or whitespace?
engine.string.lowercase(str)                            -- Convert to lowercase
engine.string.uppercase(str)                            -- Convert to uppercase
engine.string.count(str, substring)                     -- Count substring occurrences
engine.string.pad_left(str, length, char?)              -- Pad left side (default: space)
engine.string.pad_right(str, length, char?)             -- Pad right side (default: space)
engine.string.contains(str, substring)                  -- Check if contains substring
engine.string.between(str, start_delim, end_delim)      -- Extract between delimiters
```

---

# Tables

Table utilities for debugging, searching, and deep operations.

```lua
engine.table.print(tbl, indent?)               -- Debug print nested table with indentation
engine.table.contains(tbl, value)              -- Check if table contains value (searches nested tables)
engine.table.deep_copy(tbl)                    -- Create deep recursive copy with metatables preserved
engine.table.deep_compare(t1, t2)              -- Check deep structural equality between two tables
```

---

# Timestamps

Date and time utilities for working with UNIX timestamps and date formatting.

```lua
engine.timestamp.now()                         -- Get current UNIX timestamp
engine.timestamp.convert_timestamp(ts?)        -- Convert timestamp to {date, time, both}
engine.timestamp.now_formatted()               -- Get current date/time as strings
engine.timestamp.format_timestamp(ts, format)  -- Format timestamp with custom format
engine.timestamp.parse_date(date_str, time_str?) -- Parse "YYYY-MM-DD" to timestamp
engine.timestamp.date_difference(start, end)   -- Days between two dates
engine.timestamp.timestamp_difference(ts1, ts2) -- Seconds between timestamps
engine.timestamp.add_days_to_date(date, days)  -- Add days to date string
engine.timestamp.add_seconds(ts, seconds)      -- Add seconds to timestamp
engine.timestamp.add_minutes(ts, minutes)      -- Add minutes to timestamp
engine.timestamp.add_hours(ts, hours)          -- Add hours to timestamp
engine.timestamp.day_of_week(ts?)              -- Get day of week (1=Sun, 7=Sat)
engine.timestamp.day_name(ts?)                 -- Get day name (e.g., "Monday")
engine.timestamp.month_name(ts?)               -- Get month name (e.g., "January")
engine.timestamp.is_leap_year(year)            -- Is year a leap year?
engine.timestamp.days_in_month(year, month)    -- Days in given month
engine.timestamp.is_past(ts)                   -- Is timestamp in the past?
engine.timestamp.is_future(ts)                 -- Is timestamp in the future?
engine.timestamp.format_duration(seconds)      -- Format seconds to "Xh Ym Zs"
```

---

# Next Steps

- [creating scenes](/docs/3-creating-scenes.md) - Scene patterns & examples
- [building exe](/docs/4-building-exe.md) - Building exe on windows