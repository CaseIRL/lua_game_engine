<img width="1282" height="752" alt="image" src="https://github.com/user-attachments/assets/59b625e9-8d9a-4239-8e1d-72b5ad4f73f0" />
<img width="1282" height="752" alt="image" src="https://github.com/user-attachments/assets/3f805026-f94c-484b-8998-c76172e41a8a" />

# LuaJIT FFI Game Engine

A tiny, code-first Lua game framework that exists for one reason:
**Everything else is bloated, annoying, or forcing a workflow I don't want.**

# Alpha Release

Yes, this is alpha. Expect rough edges. Expect improvements.

The foundation is here: clean, modular, pure Lua.
No 200MB editor. No nested menus. No "Project > Settings > Advanced > Nuclear Plant > Rendering > Quantum Mode".

The plan is straight forward: make the engine I want to use.
If you like it too? Great.
If not? Fork it and build your own.

# What It Does

### Scene System

Scenes are simple Lua scripts. 
No excessive boilerplate. 
No sneaky magic.

```lua
local my_scene = {}

function my_scene:load()
    -- Called when scene loads
end

function my_scene:update(dt)
    -- Called every frame
    if engine.keyboard.is_pressed("escape") then
        engine.scene.switch("title")
    end
end

function my_scene:draw()
    -- Called every frame after update
    engine.draw.text({ text = "Hello", x = 100, y = 100, size = 20, r = 255, g = 255, b = 255 })
end

function my_scene:unload()
    -- Called when scene switches or game closes
end

return my_scene
```

Write your logic, return the module, engine handles the rest.

## Safe Sandbox Loader

All game code is sandboxed.
No filesystem access. No `os.execute`. No funny business.
Built to let mods extend the game without risk.

## Raylib FFI Backend

Lua-first, C-free. 
Just bindings for what's actually needed.
Enough to draw, handle input, and manage windows.

## Minimal API

You get pretty much just what you need.
You don't get: features you never asked for, endless functions with no purpose, or anything that slows you down.

## Prerequisites

**LuaJIT** must be installed and accessible in your PATH.

[How To Install Lua and LuaJIT](https://gist.github.com/Egor-Skriptunoff/cb952f7eaf39b7b1bf739b818ece87cd)

## Setup

```bash
# Clone repo
git clone https://github.com/yourusername/lua_game_engine.git
cd lua_game_engine

# Run a scene
luajit main.lua title
```

## Configure

Edit `game/config.lua`:

```lua
return {
    window = {
        title = "My Game",
        size = { width = 1280, height = 720 }
    },
    fps = {
        draw = true,
        target = 144
    },
    scenes = {
        title = "title",
        game = "game"
    }
}
```

## Create Scenes

Add scenes to `game/scenes/`. Each is a standalone Lua module:

```lua
-- game/scenes/title.lua
local title = {}

function title:draw()
    engine.draw.clear()
    engine.draw.text({ text = "Press SPACE", x = 100, y = 100, size = 24 })
end

function title:update(dt)
    if engine.keyboard.is_pressed("space") then
        engine.scene.switch("game")
    end
end

return title
```

Done. Engine handles loading, lifecycle, and cleanup.

# Why Bother?

I built this because nothing else fits how I actually want to work.

Everything's either bloated beyond belief, or stripped down so much I'd have to make everything myself anyway.

This is built for me first.
Code comes first. Tools when I need them. Everything else gets skipped.
It's modular enough to customize, minimal enough to understand, and small enough to not feel like a commitment.

You're welcome to fork it, mess with it, do whatever.
PRs during alpha are unlikely - I'm still figuring out how I want things structured.

# Documentation

- **[Architecture](/docs/2-architecture.md)** - How it's structured
- **[API Cheatsheet](/docs/3-api-cheatsheet.md)** - Quick reference
- **[Creating Scenes](/docs/4-creating-scenes.md)** - Patterns and examples

# Tech Stack

- **LuaJIT** - Fast JIT compilation
- **Raylib** - Lightweight graphics + input
- **FFI** - Zero-overhead C bindings
- **Pure Lua** - Everything except the Raylib DLL

# Contributing

Alpha stage. 
Major changes incoming. 
PRs during alpha are unlikely.

# Support

Something crash? 
Sandbox yelling? 
Window decided to become a black hole?

If I'm around, give me a shout. 
If not? Figure it out or sacrifice a chicken.

Support Hours: *Whenever I'm awake and not dealing with real life.*

---

**Next:** Read the [architecture doc](/docs/2-architecture.md) to understand how it all fits together.
