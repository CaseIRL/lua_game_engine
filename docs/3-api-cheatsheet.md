# Engine API Cheatsheet

Quick reference for the framework, refer back to this for help. 
Engine modules are loaded into game files through sandbox.
They all have access to any modules enabled within the `config.lua`

# Drawing

```lua
engine.draw.clear({ r?, g?, b?, a? })                                       -- Clear screen to color
engine.draw.line({ x1, y1, x2, y2, r?, g?, b?, a? })                        -- Draw line
engine.draw.rect({ x, y, w, h, r?, g?, b?, a? })                            -- Draw filled rectangle
engine.draw.rect_lines({ x, y, w, h, r?, g?, b?, a? })                      -- Draw rectangle outline
engine.draw.circle({ x, y, radius?, r?, g?, b?, a? })                       -- Draw filled circle
engine.draw.circle_lines({ x, y, radius?, r?, g?, b?, a? })                 -- Draw circle outline
engine.draw.triangle({ x1, y1, x2, y2, x3, y3, r?, g?, b?, a? })            -- Draw filled triangle
engine.draw.triangle_lines({ x1, y1, x2, y2, x3, y3, r?, g?, b?, a? })      -- Draw triangle outline
engine.draw.ellipse({ x, y, rx?, ry?, r?, g?, b?, a? })                     -- Draw filled ellipse
engine.draw.polygon({ x, y, sides?, radius?, rotation?, r?, g?, b?, a? })   -- Draw regular polygon
engine.draw.text({ text, x, y, size?, r?, g?, b?, a? })                     -- Draw text
```

**Colour defaults:** r=255, g=255, b=255, a=255 (white)
**Other defaults:** radius=10, size=16, sides=6, rotation=0, rx=20, ry=20

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

# Input

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

## Action mapping:
```lua
engine.actions.map_action(name, bindings)      -- Register action with key/mouse bindings
engine.actions.is_action_pressed(name)         -- Action triggered this frame
engine.actions.is_action_down(name)            -- Action held down
engine.actions.clear_actions()                 -- Unregister all actions
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

# Window

```lua
engine.window.get_size()            -- Returns: width, height
engine.window.get_dt()              -- Returns: delta time (seconds)
engine.window.get_fps()             -- Returns: current FPS
engine.window.draw_fps(x, y)        -- Draw FPS counter on screen
engine.window.toggle_fullscreen()   -- Toggle fullscreen
```

---

# Next Steps

- [creating scenes doc](/docs/4-creating-scenes.md) - Scene patterns & examples