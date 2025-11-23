# Architecture

How the framework is structured and how everything fits together.

# Folder Structure

```
/engine/                -- Framework (unrestricted)
  /core/
    api.lua             -- Public API exposed to game code
    loader.lua          -- Safe module loader with FFI sandboxing
    scene.lua           -- Scene management and switching
    window.lua          -- Window initialization and management
  /modules/
    audio.lua           -- Playing sounds (Ralib via FFI)
    draw.lua            -- 2D drawing (Raylib via FFI)
    mouse.lua           -- Mouse handling (Raylib via FFI)
    keyboard.lua        -- Keyboard handling (Raylib via FFI)
  /scenes/
    default.lua         -- Fallback scene if none found
  init.lua              -- Engine entry point, loads all modules

/game/                  -- Your game (sandboxed)
  /scenes/
    title.lua           -- Scene module
    game.lua            -- Scene module
  /test/                -- Used for testing things remove it  
  config.lua            -- Game configuration (window size, scenes, etc)

main.lua                -- Entry point (never edit this)
```

# Core Modules *(more to be added)*

## api.lua

Exports the public API that game code can access.

Contains:
- `engine.audio` - Audio handling
- `engine.draw` - Drawing functions
- `engine.keyboard` - Keyboard handling
- `engine.mouse` - mouse handling
- `engine.scene` - Scene management
- `engine.window` - Window handling
- `engine.image` - Image and sprite handling
- `engine.actions` - Action mapping for controls

Only this API is available to sandboxed game code.

---

## loader.lua

Loads and sandboxes game files.

Handles:
- Converting module paths to file paths
- Loading Lua files
- Creating restricted environments for game code
- Enforcing sandbox restrictions

---

## draw.lua

Raylib drawing functions exposed safely.

Functions:
- `draw.rect(opts)` - Draw rectangle
- `draw.text(opts)` - Draw text
- `draw.line(opts)` - Draw line
- `draw.circle(opts)` - Draw circle
- `draw.triangle(opts)` - Draw triangle
- And more...

All take option tables. 
All handle FFI calls internally.

---

## Inputs

Keyboard and mouse input handling.

### Keyboard
```lua
engine.keyboard.is_down(key)       -- Key currently held down
engine.keyboard.is_pressed(key)    -- Key pressed this frame (one-time trigger)
```

**Key names:** `a-z`, `0-9`, `space`, `enter`, `escape`, `tab`, `arrowup`, `arrowdown`, `arrowleft`, `arrowright`, `shift`, `ctrl`, `alt`, `f1-f12`, `home`, `end`, `pageup`, `pagedown`, `insert`, `delete`

### Mouse
```lua
engine.mouse.get_pos()             -- Returns: x, y (current position)
engine.mouse.get_delta()           -- Returns: dx, dy (movement since last frame)
engine.mouse.is_pressed(button)    -- Mouse button pressed this frame
engine.mouse.is_down(button)       -- Mouse button currently held
engine.mouse.set_pos(x, y)         -- Set cursor position
engine.mouse.show()                -- Show cursor
engine.mouse.hide()                -- Hide cursor
engine.mouse.lock()                -- Lock cursor (disable movement)
engine.mouse.unlock()              -- Unlock cursor
```

**Mouse buttons:** `0` = left, `1` = right, `2` = middle

---

## scene.lua

Manages scene lifecycle and switching.

Functions:
- `scene.load(scene_obj)` - Load a scene, unload current one
- `scene.switch(scene_name)` - Switch to named scene
- `scene.update(dt)` - Update current scene
- `scene.draw()` - Draw current scene
- `scene.set_scenes(table)` - Register available scenes

Calls scene methods: `load()`, `update(dt)`, `draw()`, `unload()`.

---

## window.lua

Raylib window management.

Handles:
- Initializing the window
- Managing FPS/timing
- Providing window size queries
- Cleanup on exit

# The Sandbox

Game code in `/game/` runs in a restricted environment created by `loader.lua`.

## What Game Code Can Access

```lua
engine            -- Public API (draw, keyboard, mouse, audio, scene, window)
math              -- Standard Lua math library
string            -- Standard Lua string library
table             -- Standard Lua table library
ipairs, pairs     -- Table iteration
type              -- Type checking
pcall, xpcall     -- Error handling
print()           -- Debug output
require()         -- Safe version to load other game files (game folder only)
```

---

## What Game Code Cannot Access

```lua
io                              -- File system
os                              -- System calls
debug                           -- Debug introspection
require() for engine modules    -- Can't load internals
File access outside /game/      -- Can't escape the folder
```

## Why?

Sandboxing lets mods extend the game without risk.
A malicious or broken mod can't destroy the player's system.
A broken mod can't crash the entire game in unpredictable ways.

# How It All Works Together

1. **main.lua** starts
2. Loads `engine/init.lua` which loads all core modules
3. Loads `game/config.lua` (sandboxed) - gets window settings and scene list
4. Initializes window via `window.lua`
5. Loads scenes via `loader.lua` (sandboxed)
6. Enters main loop:
   - Calls `scene.update(dt)`
   - Calls `scene.draw()`
   - Repeats
7. On exit, calls scene `unload()` and closes window

All FFI calls to Raylib go through module files.
All file access for game/mod code goes through `loader.lua` with sandbox restrictions.
All module loading for game/mod code goes through `loader.lua`.

---

# Extending the Engine

To add a new module:

1. Create `/engine/core/yourmodule.lua`
2. Export functions (no global state)
3. Add to `/engine/init.lua` as `engine.yourmodule = require(...)`
4. Game code accesses it as `engine.yourmodule.function()`

The sandbox automatically grants access to anything exported in `api.lua`.

---

# Tech Stack

**LuaJIT** - JIT compilation for performance.
**Raylib** - Lightweight graphics library with simple, sane C API.
**FFI** - Direct C bindings through LuaJIT. Zero wrapper overhead.
**Pure Lua** - Everything except the Raylib DLL is Lua.

---

# Next Steps

- [api doc](/docs/3-api-cheatsheet.md) - Complete API reference
- [creating scenes doc](/docs/4-creating-scenes.md) - Scene patterns & examples
