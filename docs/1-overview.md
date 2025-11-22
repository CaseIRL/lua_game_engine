# Lua Engine Project

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
    if engine.input.is_key_pressed("escape") then
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

You get: `window`, `input`, `draw`, `scene`.
You don't get: features you never asked for, endless functions with no purpose, or anything that slows you down.

# Why Bother?

I built this because nothing else fits how I actually want to work.

Everything's either bloated beyond belief, or stripped down so much I'd have to make everything myself anyway.

This is built for me first.
Code comes first. Tools when I need them. Everything else gets skipped.
It's modular enough to customize, minimal enough to understand, and small enough to not feel like a commitment.

You're welcome to fork it, mess with it, do whatever.
PRs during alpha are unlikely - I'm still figuring out how I want things structured.

## Quick Start

```bash
luajit main.lua title  # launches a scene
luajit main.lua game
luajit main.lua        # uses default scene
```

Tweak `game/config.lua` for window settings and some other stuff.
Add your scenes in `/game/scenes`.
Build whatever you want.

# Why You Might Want To Use This

* Because Unity wants your soul.
* Because Godot is heavy when you just want to code.
* Because LÖVE is gorgeous but missing tools.
* Because you know exactly what your engine should do.
* Because minimalism hits different when you're the one building it.

# Support

Something crash? 
Sandbox yelling? 
Window decided to become a black hole?

If I'm around, give me a shout. 
If not? Figure it out or sacrifice a chicken.

Support Hours: *Whenever I'm awake and not dealing with real life.*

# Next Steps

- [architecture doc](/docs/2-architecture.md) - How everything fits together
- [api doc](/docs/3-api-cheatsheet.md) - Complete API reference
- [creating scenes doc](/docs/4-creating-scenes.md) - Scene patterns & examples
