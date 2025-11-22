# Engine API Cheatsheet

Quick reference for the framework, refer back to this for help. 
Access modules via `local engine = require("engine.api")`.

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

# Input

```lua
engine.input.is_key_down(key)              -- Key held down
engine.input.is_key_pressed(key)           -- Key pressed this frame
engine.input.is_mouse_down(button)         -- Mouse button held (0=left, 1=right, 2=middle)
engine.input.is_mouse_pressed(button)      -- Mouse button pressed this frame
engine.input.get_mouse_pos()               -- Returns: x, y
engine.input.get_mouse_delta()             -- Returns: dx, dy
engine.input.set_mouse_pos(x, y)           -- Set cursor position
engine.input.show_cursor()                 -- Show cursor
engine.input.hide_cursor()                 -- Hide cursor
engine.input.lock_cursor()                 -- Disable cursor movement
engine.input.unlock_cursor()               -- Enable cursor movement
```

**Key names:** `a-z`, `0-9`, `space`, `enter`, `escape`, `tab`, `arrowup`, `arrowdown`, `arrowleft`, `arrowright`, `shift`, `ctrl`, `alt`, `f1-f12`, etc.

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
