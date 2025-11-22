# Architecture

How the framework is structured and how everything fits together.

# Folder Structure

```
/engine/                -- Framework (unrestricted)
  /core/
    api.lua             -- Public API exposed to game code
    loader.lua          -- Safe module loader with FFI sandboxing
    draw.lua            -- 2D drawing (Raylib via FFI)
    input.lua           -- Input handling (Raylib via FFI)
    scene.lua           -- Scene management and switching
    window.lua          -- Window initialization and management
  /scenes/
    default.lua         -- Fallback scene if none found
  init.lua              -- Engine entry point, loads all modules

/game/                  -- Your game (sandboxed)
  /scenes/
    title.lua           -- Scene module
    game.lua            -- Scene module
  config.lua            -- Game configuration (window size, scenes, etc)

main.lua                -- Entry point (never edit this)
```

# Core Modules *(more to be added)*

## api.lua

Exports the public API that game code can access.

Contains:
- `engine.draw` - Drawing functions
- `engine.input` - Input handling
- `engine.scene` - Scene management
- `engine.window` - Window handling

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

## input.lua

Raylib input handling exposed safely.

Functions:
- `input.is_key_pressed(key)` - Key pressed this frame
- `input.is_key_down(key)` - Key held
- `input.get_mouse_pos()` - Mouse position
- `input.is_mouse_pressed(button)` - Mouse button pressed

Maps string key names to key codes automatically.

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
engine            -- Public API (draw, input, scene, window)
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
