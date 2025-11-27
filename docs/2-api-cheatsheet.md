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

# Next Steps

- [creating scenes](/docs/3-creating-scenes.md) - Scene patterns & examples
- [building exe](/docs/4-building-exe.md) - Building exe on windows